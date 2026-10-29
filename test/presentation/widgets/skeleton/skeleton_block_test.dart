import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';

import 'support/widget_harness.dart';

void main() {
  /// 0xFF12AB34 is deliberately not a grey: if a skeleton ever hardcodes a
  /// colour instead of reading the scheme, these expectations catch it.
  const Color surface = Color(0xFF12AB34);

  Widget themed(Widget child) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: surface,
    ).copyWith(onSurface: surface);
    return Theme(
      data: ThemeData(colorScheme: scheme),
      child: SkeletonScope(child: child),
    );
  }

  DecoratedBox blockDecoration(WidgetTester tester, Finder block) =>
      tester.widget<DecoratedBox>(
        find.descendant(of: block, matching: find.byType(DecoratedBox)),
      );

  testWidgets('SkeletonBlock base fill derives from ColorScheme.onSurface', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      themed(const SkeletonBlock(width: 100, height: 20)),
    );

    final BoxDecoration decoration =
        blockDecoration(tester, find.byType(SkeletonBlock)).decoration
            as BoxDecoration;
    expect(decoration.color, surface.withValues(alpha: 0.06));
    expect(decoration.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('SkeletonBlock highlight derives from ColorScheme.onSurface', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      themed(const SkeletonBlock(width: 100, height: 20, borderRadius: 3)),
    );

    final BuildContext context = tester.element(find.byType(SkeletonBlock));
    expect(SkeletonBlock.baseColor(context), surface.withValues(alpha: 0.06));
    expect(
      SkeletonBlock.highlightColor(context),
      surface.withValues(alpha: 0.12),
    );
  });

  testWidgets('SkeletonBlock honours width, height and borderRadius', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      const Center(
        child: SkeletonBlock(width: 120, height: 34, borderRadius: 12),
      ),
    );

    expect(tester.getSize(find.byType(SkeletonBlock)), const Size(120, 34));
    final BoxDecoration decoration =
        blockDecoration(tester, find.byType(SkeletonBlock)).decoration
            as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('SkeletonBlock without a width fills the space it is given', (
    tester,
  ) async {
    await pumpSkeletonHarness(tester, const SkeletonBlock(height: 20));

    // A childless DecoratedBox would otherwise collapse to zero width, which
    // is how the carousel banner and the episode dividers disappeared.
    expect(tester.getSize(find.byType(SkeletonBlock)), const Size(1200, 20));
  });
}
