// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/presentation/dialogs/character_dialog.dart';
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
MediaCharacter shikimoriCharacter() {
  return character(
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

Future<void> pumpDialog(WidgetTester tester, MediaCharacter value) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: CharacterDialog(character: value)),
      ),
    ),
  );
  await tester.pump();
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

  testWidgets('hides every Shikimori sentinel, including the fact rows', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(tester, shikimoriCharacter());

      expect(find.text('Kirito'), findsOneWidget);
      expect(find.byKey(CharacterDialog.genderChipKey), findsNothing);
      expect(find.byKey(CharacterDialog.ageChipKey), findsNothing);
      expect(find.text('GENDER'), findsNothing);
      expect(find.text('AGE'), findsNothing);
      expect(find.text('BIRTHDAY'), findsNothing);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('No description available'), findsNothing);
      expect(find.byKey(CharacterDialog.descriptionKey), findsNothing);
      expect(find.textContaining('Age'), findsNothing);
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

  testWidgets('a six-line description fits the card without overflowing', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      const String longDescription =
          'A mysterious, cute and isolated girl in her third year of middle school. '
          'Her left eye is covered by an eye patch. The girl with a mysterious presence '
          'and is always sketching alone. She is labeled as the one that does not exist. '
          'Her left eye is a doll eye. It can see things that should remain unseen, '
          "that's why she keeps it covered. It can see people close to death or that are "
          'dead.';
      await pumpDialog(tester, character(description: longDescription));

      expect(find.byKey(CharacterDialog.descriptionKey), findsOneWidget);
      final Size card = tester.getSize(find.byKey(CharacterDialog.cardKey));
      expect(card.height, lessThanOrEqualTo(characterDialogMaxHeight));
      expect(card.width, characterDialogWidth);
      expect(tester.takeException(), isNull, reason: 'the description never overflows the card');
    });
  });

  testWidgets('closes when the close pill is pressed', (
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

      expect(find.byIcon(Icons.close), findsOneWidget, reason: 'the pill carries the close glyph');
      await tester.tap(find.byKey(CharacterDialog.closeKey));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDialog), findsNothing);
    });
  });
}
