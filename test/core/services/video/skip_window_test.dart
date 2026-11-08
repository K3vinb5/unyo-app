// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/dto/aniskip/aniskip_times_entity.dart';
import 'package:unyo/core/services/video/skip_window.dart';

void main() {
  AniskipTimesResults window({double start = -1, double end = -1}) {
    final AniskipTimesResults result = AniskipTimesResults();
    result.interval.startTime = start;
    result.interval.endTime = end;
    return result;
  }

  group('activeSkipWindow', () {
    test('is none when neither provider returned a window', () {
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 30),
          opening: window(),
          ending: window(),
        ),
        SkipWindowKind.none,
      );
    });

    test('reports the opening while the playhead is strictly inside it', () {
      final AniskipTimesResults opening = window(start: 10, end: 100);

      expect(
        activeSkipWindow(
          position: const Duration(seconds: 50),
          opening: opening,
          ending: window(),
        ),
        SkipWindowKind.opening,
      );
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 9),
          opening: opening,
          ending: window(),
        ),
        SkipWindowKind.none,
      );
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 100),
          opening: opening,
          ending: window(),
        ),
        SkipWindowKind.none,
        reason: 'the end boundary belongs to the episode, not the skip pill',
      );
    });

    test('reports the ending once the opening has passed', () {
      expect(
        activeSkipWindow(
          position: const Duration(minutes: 22),
          opening: window(start: 10, end: 100),
          ending: window(start: 1300, end: 1400),
        ),
        SkipWindowKind.ending,
      );
    });

    test('opening wins when the two windows overlap', () {
      expect(
        activeSkipWindow(
          position: const Duration(seconds: 50),
          opening: window(start: 40, end: 60),
          ending: window(start: 45, end: 70),
        ),
        SkipWindowKind.opening,
      );
    });

    test('a zero-length or negative window means no data', () {
      expect(
        activeSkipWindow(
          position: Duration.zero,
          opening: window(start: -1, end: -1),
          ending: window(start: 0, end: 0),
        ),
        SkipWindowKind.none,
      );
    });
  });
}
