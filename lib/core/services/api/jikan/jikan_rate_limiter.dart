// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';

/// The request budget for **Jikan** reads (WP #166).
///
/// Jikan is not MyAnimeList and does not share `MalRateLimiter`'s budget: it
/// publishes its own limits (**60 requests per
/// minute**, 3 per second) and answers a throttled request with **HTTP 429**.
/// Since WP #166's amended map, Jikan serves the calendar, the catalog feeds
/// MAL v2 cannot filter and the advanced search, so every `api.jikan.moe` call
/// acquires from exactly one instance of this class.
///
/// `MalRateLimiter`'s algorithm fits (strict spacing instead of a burst: two
/// instant grants can trip a per-second throttle while averaging under the
/// limit), but its constants and its "one budget for all MyAnimeList traffic"
/// contract do not, so the shape is mirrored here instead of bending that
/// class: **500 ms spacing** (~2 rps, the gentle pace the SPEC asks for) plus a
/// sliding 60 s window of [perMinuteLimit] grants, which is what actually caps
/// a sustained run at Jikan's 60/min.
///
/// Calls are also **serialized**: `acquire()` chains on the previous grant, so
/// two callers can never pass the gate together (Jikan's limit is enforced
/// before the request; it is not a retry loop). A 429 is the caller's signal to
/// [backoff] once and retry, or degrade to an empty page — this class paces, it
/// does not react to the response.
class JikanRateLimiter {
  /// Minimum distance between two grants: ~2/s, spread out instead of bursty.
  static const Duration minSpacing = Duration(milliseconds: 500);

  /// Sliding-window cap: Jikan's documented 60 requests per minute.
  static const int perMinuteLimit = 60;

  /// Width of the sliding window the cap applies to.
  static const Duration minuteWindow = Duration(minutes: 1);

  /// How long a caller waits after a 429 before its single retry.
  static const Duration throttleBackoff = Duration(seconds: 1);

  /// Injectable clock and sleep so tests can prove the schedule without
  /// spending real minutes.
  final DateTime Function() _clock;
  final Future<void> Function(Duration) _wait;
  final Logger _logger;

  /// Grant timestamps, ascending, pruned to [minuteWindow].
  final List<DateTime> _grants = <DateTime>[];
  DateTime? _lastGrantAt;
  int _totalGrants = 0;

  /// Tail of the serialization chain: every [acquire] runs after the previous
  /// one finished its pacing wait.
  Future<void> _tail = Future<void>.value();

  JikanRateLimiter({
    DateTime Function()? clock,
    Future<void> Function(Duration)? wait,
    Logger? logger,
  })  : _clock = clock ?? DateTime.now,
        _wait = wait ?? ((Duration duration) => Future<void>.delayed(duration)),
        _logger = logger ?? sl<Logger>();

  /// Grants taken since construction — the tests read this to prove that every
  /// Jikan request went through the budget.
  int get totalGrants => _totalGrants;

  /// Blocks until a request may be sent under Jikan's budget, then records the
  /// grant. [reason] only labels the DEBUG delay line so a runtime drive can
  /// attribute a stall to the endpoint that queued for it.
  Future<void> acquire({String reason = 'request'}) {
    final Future<void> next = _tail.then((_) => _grant(reason));
    // Keep the chain alive after a failed grant; the *caller* still sees the
    // error through `next`.
    _tail = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  /// Waits out a 429 window once. The retry that follows takes a fresh grant,
  /// so it is also spaced from this backoff.
  Future<void> backoff({String reason = 'request'}) async {
    _logger.w("Jikan throttled $reason; backing off ${throttleBackoff.inMilliseconds} ms");
    _lastGrantAt = _clock().add(throttleBackoff).subtract(minSpacing);
    await _wait(throttleBackoff);
  }

  Future<void> _grant(String reason) async {
    final DateTime startedAt = _clock();
    while (true) {
      final DateTime now = _clock();
      _prune(now);
      final Duration waitFor = _waitFor(now);
      if (waitFor > Duration.zero) {
        await _wait(waitFor);
        continue;
      }
      _grants.add(now);
      _lastGrantAt = now;
      _totalGrants++;

      final Duration held = now.difference(startedAt);
      if (held > Duration.zero) {
        _logger.d(
          "Jikan request delayed by ${held.inMilliseconds} ms "
          "($reason, ${_grants.length}/$perMinuteLimit in the last minute)",
        );
      }
      return;
    }
  }

  /// How long [now] must wait for both constraints, or [Duration.zero] when the
  /// budget allows a grant right now.
  Duration _waitFor(DateTime now) {
    Duration waitFor = Duration.zero;
    if (_grants.length >= perMinuteLimit) {
      final Duration minuteWait = _grants.first.add(minuteWindow).difference(now);
      if (minuteWait > waitFor) waitFor = minuteWait;
    }
    final DateTime? lastGrantAt = _lastGrantAt;
    if (lastGrantAt != null) {
      final Duration spacingWait = lastGrantAt.add(minSpacing).difference(now);
      if (spacingWait > waitFor) waitFor = spacingWait;
    }
    return waitFor;
  }

  void _prune(DateTime now) {
    _grants.removeWhere((DateTime grant) => now.difference(grant) >= minuteWindow);
  }
}
