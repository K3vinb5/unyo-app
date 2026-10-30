// Tests for the subtitle delay state shared by `VideoService.setSubtitleOffset`
// and the attach-time stream correction (WP #97).
import 'package:flutter_test/flutter_test.dart';

import 'package:unyo/core/services/video/subtitle_offset_controller.dart';

void main() {
  late List<Duration> written;
  late SubtitleOffsetController controller;

  setUp(() {
    written = <Duration>[];
    controller = SubtitleOffsetController(onChanged: written.add);
  });

  group('setSubtitleOffset conversion', () {
    test('converts a delay to the seconds string the player property expects', () {
      expect(SubtitleOffsetController.toMdkSeconds(Duration.zero), '0.000');
      expect(
        SubtitleOffsetController.toMdkSeconds(const Duration(milliseconds: 700)),
        '0.700',
      );
      expect(
        SubtitleOffsetController.toMdkSeconds(const Duration(milliseconds: -100)),
        '-0.100',
      );
      expect(
        SubtitleOffsetController.toMdkSeconds(const Duration(milliseconds: 1250)),
        '1.250',
      );
      // Sub-millisecond precision is not expressible in the property.
      expect(
        SubtitleOffsetController.toMdkSeconds(const Duration(microseconds: 1400)),
        '0.001',
      );
    });

    test('setOffset applies the requested total and reports the applied value', () {
      final applied = controller.setOffset(const Duration(milliseconds: 250));
      expect(applied, const Duration(milliseconds: 250));
      expect(controller.offset, const Duration(milliseconds: 250));
      expect(written.last, const Duration(milliseconds: 250));
    });
  });

  group('setSubtitleOffset clamping', () {
    test('clamps above the maximum offset and reports the clamped value', () {
      final applied = controller.setOffset(const Duration(seconds: 90));
      expect(applied, const Duration(seconds: 60));
      expect(controller.offset, const Duration(seconds: 60));
    });

    test('clamps below the negative maximum offset', () {
      final applied = controller.setOffset(const Duration(seconds: -90));
      expect(applied, const Duration(seconds: -60));
      expect(controller.offset, const Duration(seconds: -60));
    });

    test('honours a custom maximum', () {
      final tight = SubtitleOffsetController(
        onChanged: written.add,
        maxOffset: const Duration(seconds: 2),
      );
      expect(
        tight.setOffset(const Duration(seconds: 5)),
        const Duration(seconds: 2),
      );
    });
  });

  group('stream start-offset correction', () {
    test('needed cue shift is -startTime, i.e. sub-delay = +startTime', () {
      // The ticket's hypothesis, encoded: the cue file needs its timestamps
      // moved by -startTime, and mpv/mdk express that as a positive sub-delay of
      // the same magnitude (positive = presented later).
      for (final start in <int>[700, 101, 6706]) {
        final delay = SubtitleOffsetController.autoCorrectionForStream(start);
        final cueShift = -delay.inMilliseconds;
        expect(cueShift, -start);
        expect(delay, Duration(milliseconds: start));
      }
    });

    test('a stream that starts at a non-zero PTS delays the cue file by it', () {
      expect(
        SubtitleOffsetController.autoCorrectionForStream(700),
        const Duration(milliseconds: 700),
      );
      expect(
        SubtitleOffsetController.autoCorrectionForStream(6706),
        const Duration(milliseconds: 6706),
      );
    });

    test('a stream that starts at 0 (or an unknown start) needs no correction', () {
      expect(SubtitleOffsetController.autoCorrectionForStream(0), Duration.zero);
      expect(SubtitleOffsetController.autoCorrectionForStream(null), Duration.zero);
      expect(SubtitleOffsetController.autoCorrectionForStream(-1), Duration.zero);
    });

    test('the correction is written when an external file is attached', () {
      controller.setAutoOffset(
        SubtitleOffsetController.autoCorrectionForStream(700),
      );
      expect(controller.autoOffset, const Duration(milliseconds: 700));
      expect(controller.offset, const Duration(milliseconds: 700));
      expect(SubtitleOffsetController.toMdkSeconds(written.last), '0.700');
    });

    test('selecting an embedded track keeps the offset at exactly zero', () {
      controller.setAutoOffset(
        SubtitleOffsetController.autoCorrectionForStream(700),
      );
      // Embedded subtitle streams share the container timeline.
      controller.setAutoOffset(SubtitleOffsetController.autoCorrectionForStream(0));
      expect(controller.offset, Duration.zero);
      expect(SubtitleOffsetController.toMdkSeconds(written.last), '0.000');
    });
  });

  group('user nudge', () {
    test('steps by 100 ms and composes on top of the stream correction', () {
      controller.setAutoOffset(
        SubtitleOffsetController.autoCorrectionForStream(700),
      );

      controller.nudge(const Duration(milliseconds: 100));
      expect(controller.userOffset, const Duration(milliseconds: 100));
      expect(controller.offset, const Duration(milliseconds: 800));

      controller.nudge(const Duration(milliseconds: -200));
      expect(controller.offset, const Duration(milliseconds: 600));
      // The stream correction survives nudging.
      expect(controller.autoOffset, const Duration(milliseconds: 700));
    });

    test('nudging is clamped like any other offset', () {
      controller.nudge(const Duration(seconds: 61));
      expect(controller.offset, const Duration(seconds: 60));
    });
  });

  group('reset on media or track change', () {
    test('drops the stream correction and the user nudge in one write', () {
      controller.setAutoOffset(
        SubtitleOffsetController.autoCorrectionForStream(700),
      );
      controller.nudge(const Duration(milliseconds: 300));
      expect(controller.offset, const Duration(milliseconds: 1000));

      written.clear();
      controller.reset();

      expect(controller.offset, Duration.zero);
      expect(controller.autoOffset, Duration.zero);
      expect(controller.userOffset, Duration.zero);
      expect(written, <Duration>[Duration.zero]);
      expect(SubtitleOffsetController.toMdkSeconds(written.single), '0.000');
    });
  });
}
