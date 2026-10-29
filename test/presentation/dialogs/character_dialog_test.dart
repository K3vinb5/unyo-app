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

  testWidgets('hides every Shikimori sentinel', (WidgetTester tester) async {
    await withFakeImages(() async {
      await pumpDialog(tester, shikimoriCharacter());

      expect(find.text('Kirito'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('No description available'), findsNothing);
      expect(find.text('Age -1'), findsNothing);
      expect(find.textContaining('Age'), findsNothing);
      expect(find.textContaining('Born'), findsNothing);
      expect(find.textContaining('0/0/0'), findsNothing);
    });
  });

  testWidgets('shows every field of a fully populated AniList character', (
    WidgetTester tester,
  ) async {
    await withFakeImages(() async {
      await pumpDialog(tester, anilistCharacter());

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Age 21'), findsOneWidget);
      expect(find.text('Born 7/10/1991'), findsOneWidget);
      expect(find.text('Black Swordsman\nAlways solo.'), findsOneWidget);
    });
  });

  testWidgets('closes when the close button is pressed', (
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

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDialog), findsNothing);
    });
  });
}
