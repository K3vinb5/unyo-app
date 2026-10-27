import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';

import 'support/widget_harness.dart';

void main() {
  testWidgets('SkeletonScope shimmers its blocks by default', (tester) async {
    await pumpSkeletonHarness(
      tester,
      const SkeletonScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonBlock(width: 100, height: 20),
            SkeletonBlock(width: 50, height: 10),
          ],
        ),
      ),
    );

    expect(find.byType(ShaderMask), findsNWidgets(2));
    expect(
      SkeletonScope.isAnimated(tester.element(find.byType(SkeletonBlock).first)),
      isTrue,
    );
  });

  testWidgets('SkeletonScope renders static blocks under disableAnimations', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      const SkeletonScope(child: SkeletonBlock(width: 100, height: 20)),
      disableAnimations: true,
    );

    // Accessibility: blocks keep their resting fill, but nothing animates and
    // no shader layer is built at all.
    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(find.byType(ShaderMask), findsNothing);
    expect(
      SkeletonScope.isAnimated(tester.element(find.byType(SkeletonBlock))),
      isFalse,
    );
  });

  testWidgets('blocks outside a SkeletonScope fall back to static', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      const SkeletonBlock(width: 100, height: 20),
    );

    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(find.byType(ShaderMask), findsNothing);
    expect(find.byType(SkeletonScope), findsNothing);
  });
}
