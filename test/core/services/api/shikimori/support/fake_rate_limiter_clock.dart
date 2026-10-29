// External dependencies
import 'dart:async';

/// A clock that only moves when something waits on it.
///
/// [ShikimoriRateLimiter] asks "what time is it" and "wait this long", so
/// feeding it this class proves a schedule (200 ms spacing, 90/minute window)
/// in milliseconds instead of spending real seconds asleep. `wait` advances the
/// clock by exactly the requested duration and completes on the next microtask,
/// which is what [Future.delayed] would eventually do.
class FakeRateLimiterClock {
  FakeRateLimiterClock([DateTime? start]) : _now = start ?? DateTime.utc(2026, 10, 29, 12);

  DateTime _now;

  /// Total time the limiter asked to wait, summed — the proof that a request
  /// was actually held back rather than sent immediately.
  Duration waited = Duration.zero;

  DateTime now() => _now;

  Future<void> wait(Duration duration) async {
    waited += duration;
    _now = _now.add(duration);
    await Future<void>.value();
  }
}
