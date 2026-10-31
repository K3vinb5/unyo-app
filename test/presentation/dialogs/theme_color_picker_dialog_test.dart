// External dependencies
import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/theme_color_picker_dialog.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

void main() {
  /// WCAG relative luminance, used to prove text/background contrast.
  double relativeLuminance(Color color) {
    double channel(double value) =>
        value <= 0.03928 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);
  }

  /// Composite a translucent paint over its background, the way the card does.
  Color flatten(Color color, Color background) => Color.alphaBlend(color, background);

  double contrastRatio(Color foreground, Color background) {
    final double light = math.max(relativeLuminance(foreground), relativeLuminance(background));
    final double dark = math.min(relativeLuminance(foreground), relativeLuminance(background));
    return (light + 0.05) / (dark + 0.05);
  }

  ThemeData themeWithPrimary(Color primary) => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: const Color(0xFF403252),
      tertiary: const Color(0xFFD5BCEA),
    ),
  );

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
    final ColorScheme scheme = ThemeData.dark().colorScheme;

    expect(find.byType(DropdownButton<String>), findsNothing, reason: 'the mode control is text, not a dropdown');
    expect(find.text('RGB'), findsOneWidget);
    expect(find.text('HSV'), findsOneWidget);
    expect(find.text('HSL'), findsOneWidget);

    expect(modeColor(tester, 'RGB'), scheme.dialogText, reason: 'the active mode is bright');
    expect(modeColor(tester, 'HSV'), scheme.dialogDim, reason: 'the inactive modes are dim');

    await selectLabelMode(tester, 'HSV');

    expect(modeColor(tester, 'HSV'), scheme.dialogText);
    expect(modeColor(tester, 'RGB'), scheme.dialogDim);
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
        final Color surface = userTheme.value.colorScheme.dialogSurface;

        final List<(String, Color)> cardText = <(String, Color)>[
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
        for (final (String label, Color color) in cardText) {
          expect(
            contrastRatio(flatten(color, surface), surface),
            greaterThan(4.5),
            reason: '$label $color on $surface',
          );
        }
      },
    );
  }

  for (final MapEntry<String, Color> preset in <String, Color>{
    'purple': Color(0xFF9266A8),
    'teal': Color(0xFF2E8B8B),
  }.entries) {
    testWidgets(
      'the active marker follows the ${preset.key} theme colour',
      (WidgetTester tester) async {
        await openDialog(tester, theme: themeWithPrimary(preset.value));

        final Container underline = tester.widget<Container>(
          find.descendant(of: modeLink('RGB'), matching: find.byType(Container)),
        );
        expect(
          underline.color,
          preset.value,
          reason: 'the marker is the scheme accent, not a baked purple',
        );
      },
    );
  }

  testWidgets('confirm is the light button and cancel the filled dark one', (
    WidgetTester tester,
  ) async {
    await openDialog(tester, theme: ThemeData.dark());

    final Finder confirm = find.ancestor(
      of: find.text('Confirm'),
      matching: find.byType(LightUnyoButton),
    );
    final Finder cancel = find.ancestor(
      of: find.text('Cancel'),
      matching: find.byType(DarkUnyoButton),
    );
    expect(confirm, findsOneWidget);
    expect(cancel, findsOneWidget);

    final Rect confirmRect = tester.getRect(confirm);
    final Rect cancelRect = tester.getRect(cancel);
    expect(confirmRect.height, cancelRect.height, reason: 'the pair shares one height');
    expect(confirmRect.top, cancelRect.top, reason: 'the pair is aligned on one row');
    expect(cancelRect.right, lessThan(confirmRect.left), reason: 'dark cancel, light confirm');
    expect(confirmRect.height, greaterThanOrEqualTo(40));

    // No bespoke outline variant survives: nothing in the card is stroked.
    final Iterable<Container> containers = tester.widgetList<Container>(
      find.descendant(
        of: find.byKey(ThemeColorPickerDialog.cardKey),
        matching: find.byType(Container),
      ),
    );
    for (final Container container in containers) {
      final Decoration? decoration = container.decoration;
      if (decoration is BoxDecoration) {
        expect(decoration.border, isNull, reason: 'the only outlined pill in the app is gone');
      }
    }
  });

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
