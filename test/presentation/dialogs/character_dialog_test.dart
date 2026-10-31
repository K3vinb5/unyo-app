// External dependencies
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/presentation/dialogs/character_dialog.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import '../widgets/skeleton/support/fake_image_http.dart';

MediaCharacter character({
  int id = 1,
  String image = 'https://example.test/kirito.png',
  String name = 'Kirito',
  String gender = 'Male',
  String description = 'A solo player.',
  String dateOfBirth = '7/10/1991',
  int age = 17,
}) {
  return MediaCharacterModel(
    id: id,
    image: image,
    name: name,
    gender: gender,
    description: description,
    dateOfBirth: dateOfBirth,
    age: age,
  );
}

/// A Shikimori-sourced character: only image and name are real, everything else
/// is the provider's sentinel value.
MediaCharacter shikimoriCharacter({String name = 'Kirito'}) {
  return character(
    name: name,
    gender: 'Unknown',
    description: 'No description available',
    dateOfBirth: 'Unknown',
    age: -1,
  );
}

/// An AniList-sourced character with every field populated and a raw-HTML
/// description, exactly as the data layer delivers it.
MediaCharacter anilistCharacter() {
  return character(
    description: '<i>Black Swordsman</i><br>Always <b>solo</b>.',
    age: 21,
    dateOfBirth: '7/10/1991',
  );
}

ThemeData themeWithPrimary(Color primary) => ThemeData.dark().copyWith(
  colorScheme: ColorScheme.dark(
    primary: primary,
    secondary: const Color(0xFF403252),
    tertiary: const Color(0xFFD5BCEA),
  ),
);

/// Every label present in the live semantics tree.
Iterable<String> semanticsLabels(WidgetTester tester) sync* {
  final SemanticsNode? root = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  if (root == null) return;
  final List<SemanticsNode> queue = <SemanticsNode>[root];
  while (queue.isNotEmpty) {
    final SemanticsNode node = queue.removeLast();
    if (node.label.isNotEmpty) yield node.label;
    node.visitChildren((SemanticsNode child) {
      queue.add(child);
      return true;
    });
  }
}

Future<void> pumpDialog(
  WidgetTester tester,
  MediaCharacter value, {
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      child: MaterialApp(
        theme: theme ?? ThemeData.dark(),
        home: Scaffold(body: CharacterDialog(character: value)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the portrait and the name', (WidgetTester tester) async {
    await withFakeImages(() async {
      await pumpDialog(tester, character());

      expect(find.text('Kirito'), findsOneWidget);
      final UnyoNetworkImage portrait = tester.widget<UnyoNetworkImage>(
        find.byType(UnyoNetworkImage),
      );
      expect(portrait.url, 'https://example.test/kirito.png');
      expect(portrait.borderRadius, 22, reason: 'the photo column keeps the family image radius');
    });
  });

  testWidgets('renders an HTML description as plain text', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(tester, anilistCharacter());

      expect(find.text('Black Swordsman\nAlways solo.'), findsOneWidget);
      expect(find.textContaining('<i>'), findsNothing);
      expect(find.textContaining('</i>'), findsNothing);
      expect(find.textContaining('<br>'), findsNothing);
      expect(find.textContaining('<b>'), findsNothing);
    });
  });

  testWidgets('a character without data shows an explicit placeholder per slot', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(tester, shikimoriCharacter());

      expect(find.text('Kirito'), findsOneWidget);
      // Every section stays present: chip, three fact rows, description.
      expect(find.text('GENDER'), findsOneWidget);
      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('BIRTHDAY'), findsOneWidget);
      expect(find.byKey(CharacterDialog.placeholderChipKey), findsOneWidget);
      expect(find.byKey(CharacterDialog.descriptionKey), findsOneWidget);
      expect(
        find.text(characterDialogPlaceholder),
        findsNWidgets(5),
        reason: 'chip + GENDER + AGE + BIRTHDAY + description',
      );
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('No description available'), findsNothing);
      expect(find.textContaining('0/0/0'), findsNothing);
      expect(find.byKey(CharacterDialog.closeKey), findsOneWidget, reason: 'the action stays');
    });
  });

  testWidgets('shows every field of a fully populated AniList character', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(tester, anilistCharacter());

      expect(find.byKey(CharacterDialog.genderChipKey), findsOneWidget);
      expect(find.byKey(CharacterDialog.ageChipKey), findsOneWidget);
      expect(find.text('GENDER'), findsOneWidget);
      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('BIRTHDAY'), findsOneWidget);
      expect(find.text('Male'), findsNWidgets(2), reason: 'the chip and the fact row both say it');
      expect(find.text('21'), findsOneWidget);
      expect(find.text('7/10/1991'), findsOneWidget);
      expect(find.byKey(CharacterDialog.descriptionKey), findsOneWidget);
      expect(find.text(characterDialogPlaceholder), findsNothing, reason: 'nothing is missing here');
    });
  });

  testWidgets('a long name wraps and stays clear of the chips', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(
        tester,
        character(name: 'Alexandria Pendragon Alter Lily'),
      );

      final Text name = tester.widget<Text>(find.byKey(CharacterDialog.nameKey));
      expect(name.maxLines, 2);

      final Rect nameRect = tester.getRect(find.byKey(CharacterDialog.nameKey));
      final Rect chipRect = tester.getRect(find.byKey(CharacterDialog.genderChipKey));
      expect(nameRect.bottom, lessThanOrEqualTo(chipRect.top), reason: 'no overlap between name and chips');
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a very long description scrolls inside the card instead of growing it', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      const String longDescription =
          'A mysterious, cute and isolated girl in her third year of middle school. '
          'Her left eye is covered by an eye patch. The girl with a mysterious presence '
          'and is always sketching alone. She is labeled as the one that does not exist. '
          'Her left eye is a doll eye. It can see things that should remain unseen, '
          "that's why she keeps it covered. It can see people close to death or that are "
          'dead. She also keeps a diary of everyone she has ever met, and every page is '
          'covered in small sketches of the people she has lost along the way. Nobody '
          'knows where the diary came from or why she started it, and she never explains.';
      await pumpDialog(tester, character(description: longDescription));

      expect(find.byKey(CharacterDialog.descriptionKey), findsOneWidget);
      final Size card = tester.getSize(find.byKey(CharacterDialog.cardKey));
      expect(card.height, characterDialogHeight);
      expect(card.width, characterDialogWidth);
      expect(
        find.descendant(
          of: find.byKey(CharacterDialog.cardKey),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
        reason: 'the description scrolls in its own area',
      );
      expect(tester.takeException(), isNull, reason: 'the description never overflows the card');
    });
  });

  testWidgets('one stable footprint for name-only, full-data and long-description characters', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      Future<Size> cardOf(MediaCharacter value) async {
        await pumpDialog(tester, value);
        return tester.getSize(find.byKey(CharacterDialog.cardKey));
      }

      final Size nameOnly = await cardOf(shikimoriCharacter(name: 'Yuno'));
      final Size full = await cardOf(anilistCharacter());
      final Size longDescription = await cardOf(
        character(
          name: 'Vanica Zogratis',
          description: List<String>.filled(40, 'A very long biography line.').join(' '),
        ),
      );

      expect(full, nameOnly, reason: 'a character with data must not open a taller dialog');
      expect(longDescription, nameOnly, reason: 'a long description must not grow the dialog');
      expect(nameOnly.width, characterDialogWidth);
      expect(nameOnly.height, characterDialogHeight);
    });
  });

  testWidgets('the close action is a labelled 44px circular glyph, not an accent pill', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await withFakeImages(() async {
      await pumpDialog(tester, character());

      final Size hitTarget = tester.getSize(find.byKey(CharacterDialog.closeKey));
      expect(hitTarget.width, greaterThanOrEqualTo(44));
      expect(hitTarget.height, greaterThanOrEqualTo(44));

      expect(find.text('Close'), findsNothing, reason: 'the glyph has no visible label');
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Close');
      expect(
        semanticsLabels(tester),
        contains('Close'),
        reason: 'screen readers announce the glyph as its own button',
      );
      expect(find.byIcon(Icons.close), findsOneWidget);

      final UnyoInkWell inkWell = tester.widget<UnyoInkWell>(
        find.byKey(CharacterDialog.closeKey),
      );
      expect(inkWell.hoverColor, isNotNull, reason: 'the glyph has hover feedback');

      // Low contrast: the disc is a wash of the copy colour, not the accent fill.
      final ThemeData theme = ThemeData.dark();
      final Container disc = tester.widget<Container>(
        find.descendant(
          of: find.byKey(CharacterDialog.closeKey),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration decoration = disc.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, isNot(theme.colorScheme.primary));
    });
    semantics.dispose();
  });

  testWidgets('closes when the close glyph is pressed', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          minTextAdapt: true,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => CharacterDialog(character: character()),
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
      expect(find.byType(CharacterDialog), findsOneWidget);

      await tester.tap(find.byKey(CharacterDialog.closeKey));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDialog), findsNothing);
    });
  });

  testWidgets('the eyebrow follows the theme accent', (WidgetTester tester) async {
    await withFakeImages(() async {
      const Color purple = Color(0xFF9266A8);
      const Color teal = Color(0xFF2E8B8B);

      Color eyebrowOf(WidgetTester tester) => tester
          .widget<Text>(find.text('CHARACTER'))
          .style!
          .color!;

      await pumpDialog(tester, character(), theme: themeWithPrimary(purple));
      expect(eyebrowOf(tester), purple);

      await pumpDialog(tester, character(), theme: themeWithPrimary(teal));
      expect(eyebrowOf(tester), teal, reason: 'a theme swap recolours the eyebrow');
    });
  });
}
