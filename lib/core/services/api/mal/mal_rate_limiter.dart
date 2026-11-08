import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';

/// One shared request budget for **all** MyAnimeList traffic (WP #156).
///
/// MAL publishes no limits; the unofficial guidance is **≤ 2 requests per
/// second** (`research/unyo-156-mal-tracker-proof/SPEC.md` §3), and a throttled
/// request answers **HTTP 403** — not `429`. The limit is shared by every
/// `api.myanimelist.net` call the app makes (list reads, profile, list-status
/// writes), so there is exactly **one** instance of this class in the locator
/// and every MAL call site acquires from it before it sends anything:
///
/// * the list reads in `UserRepositoryMal`;
/// * `GET /users/@me` and `GET /{kind}/{id}?fields=my_list_status`;
/// * the `/my_list_status` writes in `MalUserRateService`.
///
/// ## Algorithm
///
/// A strict **500 ms spacing** (a one-token bucket that refills every 500 ms,
/// i.e. 2 grants/s at most, never a burst) plus a sliding 60 s window of 120
/// grants. Copied from [ShikimoriRateLimiter]'s shape: strict spacing instead
/// of a 2-token bucket because a burst is exactly what the budget does not
/// model — two instant grants can trip a per-second throttle while averaging
/// under 2 rps.
///
/// `acquire()` is re-entrant across concurrent callers and the pacing wait is
/// **awaited** (the calling isolate stays live); gate check and grant are one
/// synchronous step, so two callers can never pass the gate together.
///
/// ## Scope decisions
///
/// * The OAuth **token endpoint does not take a grant** (`myanimelist.net`, not
///   `api.myanimelist.net`; at most once per access-token lifetime).
/// * A `403` is MAL's throttle signal and is **not** retried from here: this
///   class prevents it, it does not react to it. Callers surface the error and
///   degrade (no hot retry loop).
/// * A transport-level retry inside the caller does not take a second grant.
class MalRateLimiter {
  /// Minimum distance between two grants: 2/s, spread out instead of bursty.
  static const Duration minSpacing = Duration(milliseconds: 500);

  /// Sliding-window cap: 2/s × 60 s, the minute-level form of the same budget.
  static const int perMinuteLimit = 120;

  /// Width of the sliding window the cap applies to.
  static const Duration minuteWindow = Duration(minutes: 1);

  /// Injectable clock and sleep so tests can prove the schedule without
  /// spending real minutes (the limiter only ever asks "what time is it" and
  /// "wait this long").
  final DateTime Function() _clock;
  final Future<void> Function(Duration) _wait;
  final Logger _logger;

  /// Grant timestamps, ascending, pruned to [minuteWindow].
  final List<DateTime> _grants = <DateTime>[];
  DateTime? _lastGrantAt;
  int _totalGrants = 0;

  MalRateLimiter({
    DateTime Function()? clock,
    Future<void> Function(Duration)? wait,
    Logger? logger,
  })  : _clock = clock ?? DateTime.now,
        _wait = wait ?? ((Duration duration) => Future<void>.delayed(duration)),
        _logger = logger ?? sl<Logger>();

  /// Grants taken since construction — the tests read this to prove that every
  /// request in a flow went through the budget.
  int get totalGrants => _totalGrants;

  /// Blocks until a request may be sent under the shared budget, then records
  /// the grant. [reason] only labels the DEBUG delay line so a runtime drive
  /// can attribute a stall to the endpoint that queued for it.
  Future<void> acquire({String reason = 'request'}) async {
    final DateTime startedAt = _clock();
    while (true) {
      final DateTime now = _clock();
      _prune(now);
      final Duration waitFor = _waitFor(now);
      if (waitFor > Duration.zero) {
        await _wait(waitFor);
        continue;
      }
      // Check-then-grant with no suspension point in between: on a single
      // isolate no other caller can slip a grant into this window, so two
      // acquirers can never be granted together.
      _grants.add(now);
      _lastGrantAt = now;
      _totalGrants++;

      final Duration held = now.difference(startedAt);
      if (held > Duration.zero) {
        _logger.d(
          "MyAnimeList request delayed by ${held.inMilliseconds} ms "
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
