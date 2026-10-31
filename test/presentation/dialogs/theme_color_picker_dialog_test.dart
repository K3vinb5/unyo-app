// External dependencies
import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/theme_color_picker_dialog.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';

void main() {
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

  Future<void> openDialog(
    WidgetTester tester, {
    ThemeData? theme,
    ValueChanged<Color>? onConfirmed,
  }) async {
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
                    onConfirmed: onConfirmed ?? (_) {},
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

  Finder modeLink(String mode) => find.byKey(ValueKey('theme-color-picker-mode-$mode'));

  Future<void> selectLabelMode(WidgetTester tester, String mode) async {
    await tester.tap(modeLink(mode));
    await tester.pumpAndSettle();
  }

  String valueLabel(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(ThemeColorPickerDialog.readOutKey)).data!;

  /// Colour of the label inside an inline mode link.
  Color modeColor(WidgetTester tester, String mode) => tester
      .widget<Text>(
        find.descendant(of: modeLink(mode), matching: find.byType(Text)),
      )
      .style!
      .color!;

  testWidgets('the dialog keeps one size across RGB, HSV and HSL label modes', (
    tester,
  ) async {
    await openDialog(tester, theme: ThemeData.dark());

    final Size rgbSize = tester.getSize(find.byKey(ThemeColorPickerDialog.cardKey));
    expect(valueLabel(tester), startsWith('R '));

    await selectLabelMode(tester, 'HSV');
    final Size hsvSize = tester.getSize(find.byKey(ThemeColorPickerDialog.cardKey));
    expect(valueLabel(tester), startsWith('H '));
    expect(valueLabel(tester), contains('V '));

    await selectLabelMode(tester, 'HSL');
    final Size hslSize = tester.getSize(find.byKey(ThemeColorPickerDialog.cardKey));
    expect(valueLabel(tester), startsWith('H '));
    expect(valueLabel(tester), contains('L '));

    expect(hsvSize, rgbSize);
    expect(hslSize, rgbSize);
    expect(rgbSize.width, themeColorPickerDialogWidth);
    expect(rgbSize.height, lessThanOrEqualTo(themeColorPickerDialogHeight));
  });

  testWidgets('switches the label mode inline, never through a menu', (
    WidgetTester tester,
  ) async {
    await openDialog(tester, theme: ThemeData.dark());

    expect(find.byType(DropdownButton<String>), findsNothing, reason: 'the mode control is text, not a dropdown');
    expect(find.text('RGB'), findsOneWidget);
    expect(find.text('HSV'), findsOneWidget);
    expect(find.text('HSL'), findsOneWidget);

    expect(modeColor(tester, 'RGB'), unyoDialogText, reason: 'the active mode is bright');
    expect(modeColor(tester, 'HSV'), unyoDialogDim, reason: 'the inactive modes are dim');

    await selectLabelMode(tester, 'HSV');

    expect(modeColor(tester, 'HSV'), unyoDialogText);
    expect(modeColor(tester, 'RGB'), unyoDialogDim);
    expect(find.byType(DropdownMenuItem<String>), findsNothing);
    expect(valueLabel(tester), startsWith('H 280°'));
  });

  for (final MapEntry<String, ThemeData> userTheme in <String, ThemeData>{
    'dark': ThemeData.dark(),
    'light': ThemeData.light(),
  }.entries) {
    testWidgets(
      'every label stays legible on a ${userTheme.key} user theme',
      (tester) async {
        await openDialog(tester, theme: userTheme.value);

        final List<(String, Color)> pinnedText = <(String, Color)>[
          (
            'eyebrow',
            tester.widget<Text>(find.byKey(ThemeColorPickerDialog.eyebrowKey)).style!.color!,
          ),
          (
            'title',
            tester.widget<Text>(find.byKey(ThemeColorPickerDialog.titleKey)).style!.color!,
          ),
          (
            'read-out',
            tester.widget<Text>(find.byKey(ThemeColorPickerDialog.readOutKey)).style!.color!,
          ),
          ('active mode', modeColor(tester, 'RGB')),
          ('inactive mode', modeColor(tester, 'HSV')),
        ];
        for (final (String label, Color color) in pinnedText) {
          expect(
            contrastRatio(color, themeColorPickerDialogSurface),
            greaterThan(4.5),
            reason: '$label $color on $themeColorPickerDialogSurface',
          );
        }
      },
    );
  }

  testWidgets('confirm hands back the picked colour and closes', (WidgetTester tester) async {
    Color? confirmed;
    await openDialog(
      tester,
      theme: ThemeData.dark(),
      onConfirmed: (Color color) => confirmed = color,
    );

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(confirmed, const Color.fromARGB(255, 146, 102, 168));
    expect(find.byType(ThemeColorPickerDialog), findsNothing);
  });

  testWidgets('cancel closes without confirming', (WidgetTester tester) async {
    bool confirmed = false;
    await openDialog(
      tester,
      theme: ThemeData.dark(),
      onConfirmed: (_) => confirmed = true,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
    expect(find.byType(ThemeColorPickerDialog), findsNothing);
  });
}
