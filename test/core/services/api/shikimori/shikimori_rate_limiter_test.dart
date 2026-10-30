// External dependencies
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';

import 'support/fake_rate_limiter_clock.dart';
import 'support/recording_logger.dart';

/// WP #64 subpart (d): the shared Shikimori budget.
///
/// Every test drives the limiter through its injectable clock, so the schedule
/// is proven in fake milliseconds — no test sleeps. The fake only advances
/// [FakeRateLimiterClock.step] (50 ms) per wait, so a 200 ms pacing delay takes
/// four turns of the limiter's loop: the re-check path is always exercised, and
/// a limiter that does not *await* its wait never sees the clock move (its spin
/// guard then throws instead of hanging the isolate).
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

    test('concurrent callers are serialized onto the one budget, never granted together', () async {
      final List<DateTime> grantedAt = <DateTime>[];
      await Future.wait(<Future<void>>[
        for (int i = 0; i < 5; i++)
          limiter.acquire(reason: 'parallel ${i + 1}').then((_) => grantedAt.add(clock.now())),
      ]);

      expect(limiter.totalGrants, 5);
      expect(grantedAt, hasLength(5));

      // The five callers decided "the budget is free" in the same synchronous
      // turn, so any grant taken on that stale decision would put two of them
      // at the same instant. Exactly 200 ms apart proves each grant is
      // re-checked after the await and taken atomically.
      final List<DateTime> distinct = grantedAt.toSet().toList()..sort();
      expect(distinct, hasLength(5), reason: 'two callers passed the gate together: $grantedAt');
      for (int i = 1; i < distinct.length; i++) {
        expect(
          distinct[i].difference(distinct[i - 1]),
          ShikimoriRateLimiter.minSpacing,
          reason: 'grants $i and ${i + 1} were ${distinct[i].difference(distinct[i - 1]).inMilliseconds} ms apart',
        );
      }
      expect(clock.waited, ShikimoriRateLimiter.minSpacing * 4, reason: 'four pacing waits of 200 ms, no more');
    });

    test('the pacing wait suspends the caller, so queued work runs during it', () async {
      await limiter.acquire(reason: 'first');

      final List<String> ranDuringWait = <String>[];
      // Queued before the second acquire; it can only run if acquire() hands
      // the event loop back for the whole pacing delay.
      Timer(Duration.zero, () => ranDuringWait.add('timer'));

      await limiter.acquire(reason: 'second');

      expect(ranDuringWait, hasLength(1), reason: 'the event loop was starved for the whole 200 ms pacing wait');
      expect(clock.waited, ShikimoriRateLimiter.minSpacing);
      expect(clock.chunks, greaterThanOrEqualTo(4));
    });

    test('a 200 ms pacing wait is consumed over several loop iterations', () async {
      await limiter.acquire(reason: 'first');
      final int waitsBefore = clock.waitCalls;
      final int chunksBefore = clock.chunks;

      await limiter.acquire(reason: 'second');

      expect(
        clock.waitCalls - waitsBefore,
        greaterThanOrEqualTo(3),
        reason: 'the limiter re-checked the clock after each 50 ms chunk',
      );
      expect(clock.chunks - chunksBefore, greaterThanOrEqualTo(3));
      expect(clock.waited, ShikimoriRateLimiter.minSpacing, reason: 'the chunks add up to exactly one 200 ms delay');
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

      final int waitsBefore = clock.waitCalls;
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
      expect(
        clock.waitCalls - waitsBefore,
        greaterThanOrEqualTo(3),
        reason: 'a minute-window wait is re-checked in chunks instead of spinning',
      );
      expect(clock.now().isAfter(ninetieth), isTrue);
    });

    test('the budget refills once the old grants leave the window', () async {
      for (int i = 0; i < 30; i++) {
        await limiter.acquire(reason: 'fill ${i + 1}');
      }
      final int grantsBefore = limiter.totalGrants;
      final Duration waitedBefore = clock.waited;

      await clock.idle(ShikimoriRateLimiter.minuteWindow);

      await limiter.acquire(reason: 'after an idle minute');
      expect(limiter.totalGrants, grantsBefore + 1);
      expect(clock.waited, waitedBefore, reason: 'an emptied window grants immediately, with no stall');
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

    test('the logged delay is the measured clock delta, not a sum of loop iterations', () async {
      for (int i = 0; i < ShikimoriRateLimiter.perMinuteLimit; i++) {
        await limiter.acquire(reason: 'fill ${i + 1}');
      }
      logger.debugLines.clear();

      final DateTime before = clock.now();
      // 844 loop iterations of a 50 ms chunk: the old code summed the remaining
      // wait on each one and logged millions of ms for this single request.
      await limiter.acquire(reason: 'request 91');
      final Duration held = clock.now().difference(before);

      expect(held, const Duration(milliseconds: 42200));
      expect(logger.debugLines, hasLength(1), reason: 'exactly one DEBUG line per delayed request');
      expect(
        logger.debugLines.single,
        contains('Shikimori request delayed by ${held.inMilliseconds} ms'),
      );
      expect(logger.debugLines.single, contains('request 91'));
    });
  });
}
