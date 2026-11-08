// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/mal/mal_rate_limiter.dart';

import '../shikimori/support/fake_rate_limiter_clock.dart';
import '../shikimori/support/recording_logger.dart';

/// WP #156: the shared MyAnimeList budget (≤ 2 req/s — MAL answers **403**, not
/// 429, when throttled, so the limiter is the only defence).
///
/// Every test drives the limiter through its injectable clock, so the schedule
/// is proven in fake milliseconds — no test sleeps. The fake only advances
/// [FakeRateLimiterClock.step] (50 ms) per wait, so a 500 ms pacing delay takes
/// ten turns of the limiter's loop: the re-check path is always exercised, and
/// a limiter that does not *await* its wait never sees the clock move (its spin
/// guard then throws instead of hanging the isolate).
void main() {
  late FakeRateLimiterClock clock;
  late RecordingLogger logger;
  late MalRateLimiter limiter;

  setUp(() {
    clock = FakeRateLimiterClock();
    logger = RecordingLogger();
    limiter = MalRateLimiter(clock: clock.now, wait: clock.wait, logger: logger);
  });

  group('MalRateLimiter per-second budget', () {
    test('10 sequential requests are spaced at least 500 ms apart (<= 2 rps)', () async {
      final List<DateTime> grants = <DateTime>[];
      for (int i = 0; i < 10; i++) {
        await limiter.acquire(reason: 'burst ${i + 1}');
        grants.add(clock.now());
      }

      for (int i = 1; i < grants.length; i++) {
        final Duration gap = grants[i].difference(grants[i - 1]);
        expect(gap.inMilliseconds, greaterThanOrEqualTo(500),
            reason: 'gap before request ${i + 1} was ${gap.inMilliseconds} ms');
      }

      // <= 2 rps, measured on every sliding second of the burst.
      for (int i = 0; i < grants.length; i++) {
        final DateTime windowEnd = grants[i].add(const Duration(seconds: 1));
        final int inWindow = grants
            .where((DateTime grant) => !grant.isBefore(grants[i]) && grant.isBefore(windowEnd))
            .length;
        expect(inWindow, lessThanOrEqualTo(2),
            reason: 'window starting at request ${i + 1} held $inWindow grants');
      }

      expect(limiter.totalGrants, 10);
      expect(clock.waited.inMilliseconds, greaterThanOrEqualTo(9 * 500));
    });

    test('concurrent callers are serialized onto the one budget, never granted together', () async {
      final List<DateTime> grantedAt = <DateTime>[];
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 4; i++)
          limiter.acquire(reason: 'parallel ${i + 1}').then((_) => grantedAt.add(clock.now())),
      ]);

      expect(limiter.totalGrants, 4);
      expect(grantedAt, hasLength(4));

      final List<DateTime> distinct = grantedAt.toSet().toList()..sort();
      expect(distinct, hasLength(4), reason: 'two callers passed the gate together: $grantedAt');
      for (int i = 1; i < distinct.length; i++) {
        expect(distinct[i].difference(distinct[i - 1]), MalRateLimiter.minSpacing,
            reason: 'grants $i and ${i + 1} were ${distinct[i].difference(distinct[i - 1]).inMilliseconds} ms apart');
      }
    });

    test('the pacing wait suspends the caller, so queued work runs during it', () async {
      await limiter.acquire(reason: 'first');

      final List<String> ranDuringWait = <String>[];
      Timer(Duration.zero, () => ranDuringWait.add('timer'));

      await limiter.acquire(reason: 'second');

      expect(ranDuringWait, hasLength(1), reason: 'the event loop was starved for the whole 500 ms pacing wait');
      expect(clock.waited, MalRateLimiter.minSpacing);
      expect(clock.chunks, greaterThanOrEqualTo(10));
    });
  });

  group('MalRateLimiter per-minute budget', () {
    test('the 120th request fits the window and the 121st is held until it slides', () async {
      final DateTime windowStart = clock.now();
      for (int i = 0; i < MalRateLimiter.perMinuteLimit; i++) {
        await limiter.acquire(reason: 'minute ${i + 1}');
      }
      final Duration waitedBefore = clock.waited;

      await limiter.acquire(reason: 'request 121');

      expect(limiter.totalGrants, 121);
      expect(
        clock.now().difference(windowStart),
        greaterThanOrEqualTo(MalRateLimiter.minuteWindow),
        reason: 'the 121st grant must land at least a minute after the first one',
      );
      expect(
        clock.waited - waitedBefore,
        greaterThanOrEqualTo(MalRateLimiter.minSpacing),
        reason: 'the 121st is held by the window/spacing constraints instead of firing immediately',
      );
    });

    test('the budget refills once the old grants leave the window', () async {
      for (int i = 0; i < 10; i++) {
        await limiter.acquire(reason: 'fill ${i + 1}');
      }
      final int grantsBefore = limiter.totalGrants;
      final Duration waitedBefore = clock.waited;

      await clock.idle(MalRateLimiter.minuteWindow);

      await limiter.acquire(reason: 'after an idle minute');
      expect(limiter.totalGrants, grantsBefore + 1);
      expect(clock.waited, waitedBefore, reason: 'an emptied window grants immediately, with no stall');
    });
  });

  group('MalRateLimiter logging', () {
    test('a delayed request logs one DEBUG line with the delay in ms', () async {
      await limiter.acquire(reason: 'first');
      expect(logger.debugLines, isEmpty, reason: 'the first request is not delayed');

      await limiter.acquire(reason: 'second');

      expect(logger.debugLines, hasLength(1));
      expect(logger.debugLines.single, contains('MyAnimeList request delayed by 500 ms'));
      expect(logger.debugLines.single, contains('second'));
    });
  });
}
