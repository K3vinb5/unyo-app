// External dependencies
import 'dart:async';

/// A clock that only moves when something waits on it.
///
/// [ShikimoriRateLimiter] asks "what time is it" and "wait this long", so
/// feeding it this class proves a schedule (200 ms spacing, 90/minute window)
/// in milliseconds instead of spending real seconds asleep.
///
/// A wait advances the clock by at most [step] and then returns — after a real
/// event-loop turn — so a full 200 ms pacing delay takes several turns of the
/// limiter's loop (WP #64(d) finding 4). Every test therefore exercises the
/// re-check path, and a limiter that does not *await* its wait never sees the
/// clock move at all.
class FakeRateLimiterClock {
  FakeRateLimiterClock([
    DateTime? start,
    this.step = const Duration(milliseconds: 50),
  ]) : _now = start ?? DateTime.utc(2026, 10, 29, 12);

  /// How much the clock moves per event-loop turn.
  final Duration step;

  /// How many waits at one instant are tolerated before the limiter is judged
  /// to be spinning. A correct limiter issues at most one wait per concurrent
  /// caller per instant; a synchronous pacing loop issues thousands.
  static const int maxWaitsPerInstant = 16;

  DateTime _now;
  int _waitsAtThisInstant = 0;

  /// Total time the limiter asked to wait, summed — the proof that a request
  /// was actually held back rather than sent immediately.
  Duration waited = Duration.zero;

  /// Number of pacing waits the limiter issued, and how many of them actually
  /// moved the clock. A busy-spinning limiter racks up waits with no chunks.
  int waitCalls = 0;
  int chunks = 0;

  DateTime now() => _now;

  /// Blocks the limiter for up to [step] of [duration]. Synchronous on
  /// purpose: when the spin guard trips it throws straight into the caller's
  /// loop, which is the only way to stop a busy-spin from hanging the test
  /// isolate forever (an error on a discarded future could not).
  Future<void> wait(Duration duration) {
    waitCalls++;
    _waitsAtThisInstant++;
    if (_waitsAtThisInstant > maxWaitsPerInstant) {
      throw StateError(
        'busy-spin detected: $waitCalls waits issued at ${_now.toIso8601String()} '
        'without the clock advancing — the limiter is not awaiting its pacing '
        'wait (WP #64(d) finding 1)',
      );
    }
    return _advance(duration < step ? duration : step);
  }

  /// Advances the clock by the whole [duration] for test setup (an idle app),
  /// bypassing the pacing loop. Does not count as limiter-imposed waiting.
  Future<void> idle(Duration duration) async {
    await Future<void>.delayed(Duration.zero);
    _now = _now.add(duration);
    _waitsAtThisInstant = 0;
  }

  Future<void> _advance(Duration chunk) async {
    // A real event-loop turn: anything else queued runs here, which a spinner
    // would starve.
    await Future<void>.delayed(Duration.zero);
    _now = _now.add(chunk);
    waited += chunk;
    chunks++;
    _waitsAtThisInstant = 0;
  }
}
