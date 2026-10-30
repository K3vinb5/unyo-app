import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';

/// One shared request budget for **all** Shikimori traffic (WP #64 subpart (d)).
///
/// Shikimori documents a single per-IP budget of **5 requests per second and 90
/// requests per minute** (`raws/api/rest-api-doc-extracted.txt`, "Restrictions",
/// re-measured in `DIAGNOSIS.md`: a probe session stayed under 40 requests with
/// 0.4 s spacing and never saw a 429). The limit is shared by the GraphQL
/// endpoint, `/api/calendar`, `/api/v2/user_rates`, i.e. by whatever the app
/// does, not per endpoint — so there is exactly **one** instance of this class
/// in the locator, and every Shikimori call site acquires from it before it
/// sends anything:
///
/// * the shikimori-named `GraphQLService` (all list/search/details/mapping
///   queries — the five home carousels included);
/// * `GET /api/calendar` in `AnimeRepositoryShikimori`;
/// * the `/api/v2/user_rates` calls in `ShikimoriUserRateService`.
///
/// ## Algorithm
///
/// A **strict 200 ms spacing** (a one-token bucket that refills every 200 ms,
/// i.e. 5 grants/s at most, never a burst) plus a **sliding 60 s window of 90
/// grants**. Strict spacing is used instead of a 5-token bucket because a burst
/// is exactly what the budget does not model: 5 instant grants followed by a
/// 1 s stall averages under 5 rps but still fires 5 requests in the same
/// millisecond. The spacing makes the "≤ 5 rps" claim visible in a runtime log
/// (every gap is ≥ 200 ms) and costs at most 1 s of startup latency for the six
/// home-screen requests.
///
/// `acquire()` is re-entrant across concurrent callers: the wait loop re-reads
/// the shared grant list after every sleep, so N carousels firing in parallel
/// are serialized onto the same budget instead of each believing it is first.
///
/// The pacing wait is **awaited**, so the calling isolate is released for the
/// whole delay — the main isolate keeps painting while a request queues. The
/// gate check and the grant itself are one synchronous step (no `await`
/// between them), so two callers can never pass the gate together: whichever
/// one wakes second re-reads the freshly written grant and keeps pacing.
///
/// ## Scope decisions
///
/// * The OAuth **token endpoint does not take a grant**. `oauth/token` lives
///   outside `/api`, it is called at most once per access-token lifetime
///   (1 day), and gating it would make a token refresh wait behind up to a
///   minute of API traffic — the budget exists to protect the API surface, not
///   the grant endpoint. If Shikimori ever answers `429` there, route it through
///   this limiter too.
/// * A `GET` served from `HttpService`'s 20-minute response cache still takes a
///   grant: the cache lives inside the transport, one layer below the call
///   sites. That over-counts (never under-counts), so the budget can only be
///   spent faster than the network sees it, never exceeded.
/// * A transport-level retry (`SocketException`/timeout inside `HttpService`)
///   does not take a second grant. Retries exist only for transport failures,
///   not for `429`s, and are bounded to one extra attempt.
class ShikimoriRateLimiter {
  /// Minimum distance between two grants: 5/s, spread out instead of bursty.
  static const Duration minSpacing = Duration(milliseconds: 200);

  /// Sliding-window cap, matching Shikimori's documented 90 requests/minute.
  static const int perMinuteLimit = 90;

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

  ShikimoriRateLimiter({
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
  ///
  /// Every wait is awaited: the loop suspends the caller (and, on the main
  /// isolate, the event loop underneath it stays live) instead of spinning on
  /// the pacing delay.
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

      // The delay is the measured clock delta, never a sum of the individual
      // waits (which would re-count the remaining wait on every re-check).
      final Duration held = now.difference(startedAt);
      if (held > Duration.zero) {
        _logger.d(
          "Shikimori request delayed by ${held.inMilliseconds} ms "
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
