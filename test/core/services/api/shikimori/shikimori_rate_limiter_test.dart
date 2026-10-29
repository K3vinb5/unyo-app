// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';

import 'support/fake_rate_limiter_clock.dart';
import 'support/recording_logger.dart';

/// WP #64 subpart (d): the shared Shikimori budget.
///
/// Every test drives the limiter through its injectable clock, so the schedule
/// is proven in fake milliseconds — no test sleeps.
void main() {
  late FakeRateLimiterClock clock;
  late RecordingLogger logger;
  late ShikimoriRateLimiter limiter;

  setUp(() {
    clock = FakeRateLimiterClock();
    logger = RecordingLogger();
    limiter = ShikimoriRateLimiter(clock: clock.now, wait: clock.wait, logger: logger);
  });

  group('ShikimoriRateLimiter per-second budget', () {
    test('30 sequential requests are spaced at least 200 ms apart (<= 5 rps)', () async {
      final List<DateTime> grants = <DateTime>[];
      for (int i = 0; i < 30; i++) {
        await limiter.acquire(reason: 'burst ${i + 1}');
        grants.add(clock.now());
      }

      for (int i = 1; i < grants.length; i++) {
        final Duration gap = grants[i].difference(grants[i - 1]);
        expect(gap.inMilliseconds, greaterThanOrEqualTo(200), reason: 'gap before request ${i + 1} was ${gap.inMilliseconds} ms');
      }

      // <= 5 rps, measured on every sliding second of the burst.
      for (int i = 0; i < grants.length; i++) {
        final DateTime windowEnd = grants[i].add(const Duration(seconds: 1));
        final int inWindow = grants.where((DateTime grant) => !grant.isBefore(grants[i]) && grant.isBefore(windowEnd)).length;
        expect(inWindow, lessThanOrEqualTo(5), reason: 'window starting at request ${i + 1} held $inWindow grants');
      }

      expect(limiter.totalGrants, 30);
      expect(clock.waited.inMilliseconds, greaterThanOrEqualTo(29 * 200));
    });

    test('concurrent callers share the one budget instead of firing together', () async {
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 5; i++) limiter.acquire(reason: 'parallel ${i + 1}'),
      ]);

      expect(limiter.totalGrants, 5);
      expect(clock.waited.inMilliseconds, greaterThanOrEqualTo(4 * 200));
    });
  });

  group('ShikimoriRateLimiter per-minute budget', () {
    test('the 90th request fits the window and the 91st waits for it to slide', () async {
      final DateTime windowStart = clock.now();
      for (int i = 0; i < ShikimoriRateLimiter.perMinuteLimit; i++) {
        await limiter.acquire(reason: 'minute ${i + 1}');
      }
      final Duration waitedBefore = clock.waited;
      final DateTime ninetieth = clock.now();

      await limiter.acquire(reason: 'request 91');

      expect(limiter.totalGrants, 91);
      expect(
        clock.now().difference(windowStart),
        greaterThanOrEqualTo(ShikimoriRateLimiter.minuteWindow),
        reason: 'the 91st grant must land after the first one left the minute window',
      );
      expect(
        clock.waited - waitedBefore,
        greaterThanOrEqualTo(const Duration(seconds: 42)),
        reason: '90 grants at 200 ms spacing fill 17.8 s, so the 91st waits ~42.2 s',
      );
      expect(clock.now().isAfter(ninetieth), isTrue);
    });

    test('the budget refills once the old grants leave the window', () async {
      for (int i = 0; i < 30; i++) {
        await limiter.acquire(reason: 'fill ${i + 1}');
      }
      final int grantsBefore = limiter.totalGrants;

      await clock.wait(ShikimoriRateLimiter.minuteWindow);

      await limiter.acquire(reason: 'after an idle minute');
      expect(limiter.totalGrants, grantsBefore + 1);
      expect(clock.waited.inMilliseconds, lessThan((30 * 200) + ShikimoriRateLimiter.minuteWindow.inMilliseconds + 200));
    });
  });

  group('ShikimoriRateLimiter logging', () {
    test('a delayed request logs one DEBUG line with the delay in ms', () async {
      await limiter.acquire(reason: 'first');
      expect(logger.debugLines, isEmpty, reason: 'the first request is not delayed');

      await limiter.acquire(reason: 'second');

      expect(logger.debugLines, hasLength(1));
      expect(logger.debugLines.single, contains('Shikimori request delayed by 200 ms'));
      expect(logger.debugLines.single, contains('second'));
    });
  });
}
