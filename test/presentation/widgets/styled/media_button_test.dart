import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/media_button.dart';

import '../skeleton/support/fake_image_http.dart';
import '../skeleton/support/widget_harness.dart';

/// WP #166: the browse buttons must show art when a provider has a cover.
/// MediaButton itself stays a dumb painter — an empty url is the gradient-only
/// fallback, a non-empty one becomes the decoration image.
void main() {
  /// The decoration image the button paints, or null for the gradient-only case.
  DecorationImage? paintedImage(WidgetTester tester) {
    final decoration = tester
        .widget<HoverAnimatedContainer>(find.byType(HoverAnimatedContainer))
        .decoration;
    return (decoration as BoxDecoration).image;
  }

  testWidgets('a non-empty image url becomes the button decoration image', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        MediaButton(
          image: 'https://cdn.example.test/cover.jpg',
          text: 'x',
          onPressed: () {},
        ),
      );

      final image = paintedImage(tester);
      expect(image, isNotNull);
      expect(
        (image!.image as NetworkImage).url,
        'https://cdn.example.test/cover.jpg',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('an empty image url paints no decoration image (gradient only)', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        MediaButton(image: '', text: 'x', onPressed: () {}),
      );

      expect(
        paintedImage(tester),
        isNull,
        reason: 'NetworkImage("") only errors; the gradient stands alone',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
