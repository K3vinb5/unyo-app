// External dependencies
import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/theme_color_picker_dialog.dart';

/// WCAG relative luminance, used to prove text/background contrast.
double relativeLuminance(Color color) {
  double channel(double value) =>
      value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
}

double contrastRatio(Color foreground, Color background) {
  final double light = math.max(relativeLuminance(foreground), relativeLuminance(background));
  final double dark = math.min(relativeLuminance(foreground), relativeLuminance(background));
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  Future<void> openDialog(WidgetTester tester, {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        child: MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ThemeColorPickerDialog(
                    initialColor: const Color.fromARGB(255, 146, 102, 168),
                    onConfirmed: (_) {},
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder labelModeSelector() => find.byKey(const ValueKey('theme-color-picker-label-mode'));

  Future<void> selectLabelMode(WidgetTester tester, String mode) async {
    await tester.tap(labelModeSelector());
    await tester.pumpAndSettle();
    await tester.tap(find.text(mode).last);
    await tester.pumpAndSettle();
  }

  String valueLabel(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const ValueKey('theme-color-picker-values'))).data!;

  testWidgets('the dialog keeps one size across RGB, HSV and HSL label modes', (
    tester,
  ) async {
    await openDialog(tester, theme: ThemeData.dark());

    final Size rgbSize = tester.getSize(find.byType(AlertDialog));
    expect(valueLabel(tester), startsWith('R '));

    await selectLabelMode(tester, 'HSV');
    final Size hsvSize = tester.getSize(find.byType(AlertDialog));
    expect(valueLabel(tester), startsWith('H '));
    expect(valueLabel(tester), contains('V '));

    await selectLabelMode(tester, 'HSL');
    final Size hslSize = tester.getSize(find.byType(AlertDialog));
    expect(valueLabel(tester), startsWith('H '));
    expect(valueLabel(tester), contains('L '));

    expect(hsvSize, rgbSize);
    expect(hslSize, rgbSize);
  });

  for (final MapEntry<String, ThemeData> userTheme in <String, ThemeData>{
    'dark': ThemeData.dark(),
    'light': ThemeData.light(),
  }.entries) {
    testWidgets(
      'label menu and selected value stay legible on a ${userTheme.key} user theme',
      (tester) async {
        await openDialog(tester, theme: userTheme.value);

        final DropdownButton<String> selector = tester.widget<DropdownButton<String>>(
          labelModeSelector(),
        );
        final Color selectedValueColor =
            selector.style?.color ?? Theme.of(tester.element(labelModeSelector())).textTheme.titleMedium!.color!;
        expect(
          contrastRatio(selectedValueColor, themeColorPickerDialogSurface),
          greaterThan(4.5),
          reason: 'selected value $selectedValueColor on $themeColorPickerDialogSurface',
        );

        await tester.tap(labelModeSelector());
        await tester.pumpAndSettle();

        final BuildContext itemContext = tester.element(find.text('HSV').last);
        final TextStyle itemStyle = DefaultTextStyle.of(itemContext).style;
        final Color menuBackground = selector.dropdownColor ?? Theme.of(itemContext).canvasColor;
        expect(itemStyle.color, isNotNull);
        expect(
          contrastRatio(itemStyle.color!, menuBackground),
          greaterThan(4.5),
          reason: 'menu item text ${itemStyle.color} on menu background $menuBackground',
        );

        final Color valueColor = tester
            .widget<Text>(find.byKey(const ValueKey('theme-color-picker-values')))
            .style!
            .color!;
        expect(
          contrastRatio(valueColor, themeColorPickerDialogSurface),
          greaterThan(4.5),
          reason: 'value read-out $valueColor on $themeColorPickerDialogSurface',
        );
      },
    );
  }
}
