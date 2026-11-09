// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/jikan/jikan_rate_limiter.dart';

import '../shikimori/support/fake_rate_limiter_clock.dart';
import '../shikimori/support/recording_logger.dart';

/// WP #166: Jikan's own budget (60/min, 3/s; a throttled request answers 429).
///
/// Every test drives the limiter through its injectable clock, so the schedule
/// is proven in fake milliseconds — no test sleeps.
void main() {
  late FakeRateLimiterClock clock;
  late RecordingLogger logger;
  late JikanRateLimiter limiter;

  setUp(() {
    clock = FakeRateLimiterClock();
    logger = RecordingLogger();
    limiter = JikanRateLimiter(clock: clock.now, wait: clock.wait, logger: logger);
  });

  group('JikanRateLimiter per-second budget', () {
    test('sequential requests are spaced at least 500 ms apart (~2 rps)', () async {
      final List<DateTime> grants = <DateTime>[];
      for (int i = 0; i < 5; i++) {
        await limiter.acquire(reason: 'feed ${i + 1}');
        grants.add(clock.now());
      }

      for (int i = 1; i < grants.length; i++) {
        expect(grants[i].difference(grants[i - 1]).inMilliseconds, greaterThanOrEqualTo(500));
      }
      expect(limiter.totalGrants, 5);
      expect(clock.waited.inMilliseconds, greaterThanOrEqualTo(4 * 500));
    });

    test('concurrent callers are serialized onto the one budget', () async {
      final List<DateTime> grantedAt = <DateTime>[];
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 4; i++)
          limiter.acquire(reason: 'parallel ${i + 1}').then((_) => grantedAt.add(clock.now())),
      ]);

      expect(limiter.totalGrants, 4);
      final List<DateTime> distinct = grantedAt.toSet().toList()..sort();
      expect(distinct, hasLength(4), reason: 'two callers passed the gate together: $grantedAt');
      for (int i = 1; i < distinct.length; i++) {
        expect(distinct[i].difference(distinct[i - 1]), JikanRateLimiter.minSpacing);
      }
    });
  });

  group('JikanRateLimiter per-minute budget', () {
    test('the 60th request fits the minute and the 61st waits for the window', () async {
      final DateTime windowStart = clock.now();
      for (int i = 0; i < JikanRateLimiter.perMinuteLimit; i++) {
        await limiter.acquire(reason: 'minute ${i + 1}');
      }

      await limiter.acquire(reason: 'request 61');

      expect(limiter.totalGrants, 61);
      expect(
        clock.now().difference(windowStart),
        greaterThanOrEqualTo(JikanRateLimiter.minuteWindow),
        reason: "the 61st grant must not land inside Jikan's 60/min window",
      );
    });
  });

  group('JikanRateLimiter 429 backoff', () {
    test('a backoff holds the retry at least one second from the throttled grant', () async {
      await limiter.acquire(reason: 'throttled');
      final DateTime throttledAt = clock.now();

      await limiter.backoff(reason: 'throttled');
      await limiter.acquire(reason: 'retry');

      expect(
        clock.now().difference(throttledAt),
        greaterThanOrEqualTo(JikanRateLimiter.throttleBackoff),
        reason: 'the retry must wait out the throttle, not just the 500 ms spacing',
      );
      expect(logger.warningLines.single, contains('Jikan throttled'));
    });
  });

  group('JikanRateLimiter logging', () {
    test('a delayed request logs one DEBUG line with the delay in ms', () async {
      await limiter.acquire(reason: 'first');
      expect(logger.debugLines, isEmpty, reason: 'the first request is not delayed');

      await limiter.acquire(reason: 'second');

      expect(logger.debugLines, hasLength(1));
      expect(logger.debugLines.single, contains('Jikan request delayed by 500 ms'));
      expect(logger.debugLines.single, contains('second'));
    });
  });
}
