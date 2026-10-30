import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import 'support/fake_image_http.dart';
import 'support/widget_harness.dart';

/// The shared image widget must never pop: the slot is skeleton-tinted until
/// the first frame arrives, then the image fades in over 250ms.
void main() {
  const Size slotSize = Size(140, 200.5);

  double fadeValue(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  testWidgets('paints the skeleton slot while the frame is pending', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const UnyoNetworkImage(
          url: 'https://example.test/pending.png',
          width: 140,
          height: 200.5,
        ),
      );

      expect(tester.getSize(find.byType(UnyoNetworkImage)), slotSize);
      final BuildContext context = tester.element(find.byType(UnyoNetworkImage));
      final ColoredBox slot = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(slot.color, SkeletonBlock.baseColor(context));
    });
  });

  testWidgets('fades a resolved image in over 250ms with easeOut', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const UnyoNetworkImage(
          url: 'https://example.test/fade.png',
          width: 140,
          height: 200.5,
        ),
      );

      final AnimatedOpacity fade = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(fade.duration, const Duration(milliseconds: 250));
      expect(fade.curve, Curves.easeOut);
      expect(fadeValue(tester), 0, reason: 'no frame has arrived yet');

      // Let the fake HTTP client and the image codec deliver the frame; the
      // decode runs on the real event loop, so it needs runAsync.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      expect(fadeValue(tester), 0, reason: 'the fade starts from transparent');

      await tester.pump(const Duration(milliseconds: 125));
      final double mid = fadeValue(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));

      await tester.pump(const Duration(milliseconds: 250));
      expect(fadeValue(tester), 1);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('swaps the frame in without animating for reduce-motion', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const UnyoNetworkImage(
          url: 'https://example.test/reduced.png',
          width: 140,
          height: 200.5,
        ),
        disableAnimations: true,
      );

      expect(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(AnimatedOpacity),
        ),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('forwards filterQuality and can skip the skeleton slot', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const UnyoNetworkImage(
          url: 'https://example.test/sharp.png',
          width: 140,
          height: 200.5,
          filterQuality: FilterQuality.high,
          showPlaceholder: false,
        ),
      );

      final Image image = tester.widget<Image>(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(Image),
        ),
      );
      expect(image.filterQuality, FilterQuality.high);
      expect(
        find.descendant(
          of: find.byType(UnyoNetworkImage),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
        reason: 'showPlaceholder: false must drop the skeleton colour',
      );
      expect(tester.getSize(find.byType(UnyoNetworkImage)), slotSize);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('an empty url paints only the placeholder', (tester) async {
    await pumpSkeletonHarness(
      tester,
      const UnyoNetworkImage(url: '', width: 52, height: 52),
    );

    expect(find.byType(Image), findsNothing);
    expect(tester.getSize(find.byType(UnyoNetworkImage)), const Size(52, 52));
    expect(tester.takeException(), isNull);
  });
}

