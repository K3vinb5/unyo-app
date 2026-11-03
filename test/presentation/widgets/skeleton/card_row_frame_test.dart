import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
// EasyLocalization persists the chosen locale through this package, so the
// test needs its in-memory platform implementation (transitive dependency).
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unyo/core/i18n/underscore_asset_loader.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/anime_card_list.dart';
import 'package:unyo/presentation/widgets/styled/card_row_frame.dart';
import 'package:unyo/presentation/widgets/styled/unyo_character_list.dart';
import 'package:unyo/core/i18n/app_localizations.dart';

/// Pumps [child] inside an app-shaped shell: the menu rail (100 wide) on the
/// left and the screen content in the rest of the window, exactly like
/// `screens/tabs_screen.dart`. The content sits at x = 0, so the rects below
/// are read in the same coordinates the screens lay out in.
///
/// The screens' outer `Column` is centered, so a `1.sw - 140` strip shows up
/// 20 px into a 1820-wide viewport - which is what the alignment tests pin.
Future<void> pumpInShell(
  WidgetTester tester,
  Widget child, {
  double viewWidth = 1920,
  double viewHeight = 1080,
  double contentWidth = 1820,
}) async {
  tester.view.physicalSize = Size(viewWidth, viewHeight);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // The translations load from the asset bundle on the real event loop, so the
  // first frame has to be pumped inside `runAsync`; the shimmer then runs on
  // the fake clock like every other widget test.
  await tester.runAsync(() async {
    await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'GB')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en', 'GB'),
      useOnlyLangCode: false,
      assetLoader: const UnderscoreAssetLoader(),
      child: Builder(
        builder: (BuildContext context) {
          final localization = EasyLocalization.of(context);
          return ScreenUtilInit(
            designSize: const Size(1920, 1080),
            child: MaterialApp(
              locale: const Locale('en', 'GB'),
              supportedLocales: const [Locale('en', 'GB')],
              localizationsDelegates: appLocalizationDelegates(
                localization?.delegates ?? const <LocalizationsDelegate<dynamic>>[],
              ),
              home: Scaffold(
                body: Row(
                  children: [
                    // The menu rail the real shell reserves.
                    const SizedBox(width: 100),
                    SizedBox(
                      width: contentWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [const SizedBox(height: 25), child],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pump();
}

/// The width of the menu rail every rect in this file is offset by.
const double railWidth = 100;

void main() {
  // `context.tr` needs the localization delegate, which needs the device
  // locale EasyLocalization resolves at startup.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  const double cardWidth = MediaCardMetrics.width;
  int cardsAt(double width) => (width / cardWidth).ceil() + 1;

  group('CardRowFrame.browse', () {
    testWidgets(
      'is the strip the loaded rows use: the placeholder and the content sit '
      'in exactly the same box',
      (tester) async {
        await pumpInShell(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CardRowFrame.browse(child: CardRowSkeleton()),
              CardRowFrame.browse(
                child: AnimeCardList(
                  listTitle: 'Trending Animes',
                  animeList: const [],
                  controller: ScrollController(),
                  onPressed: (_, _) {},
                  loadMore: false,
                ),
              ),
            ],
          ),
        );

        final Rect skeleton = tester.getRect(find.byType(CardRowSkeleton));
        final Rect loaded = tester.getRect(find.byType(AnimeCardList));
        expect(
          loaded.left,
          skeleton.left,
          reason: 'the swap must not move the row horizontally',
        );
        expect(loaded.width, skeleton.width);
        expect(
          skeleton.width,
          1.sw - CardRowFrame.stripInset,
          reason: 'the frame owns the 1.sw - 140 strip',
        );

        // The card strips themselves are the same band in both states.
        final Rect skeletonStrip = tester.getRect(find.byType(ListView).first);
        final Rect loadedStrip = tester.getRect(find.byType(ListView).last);
        expect(loadedStrip.left, skeletonStrip.left);
        expect(loadedStrip.width, skeletonStrip.width);
        expect(
          skeletonStrip.height,
          CardRowMetrics.rowHeight,
          reason: 'the placeholder strip is the loaded strip height',
        );
        expect(loadedStrip.height, skeletonStrip.height);
      },
    );

    testWidgets('centers the strip in the content viewport like the screens', (
      tester,
    ) async {
      await pumpInShell(
        tester,
        const CardRowFrame.browse(child: CardRowSkeleton()),
      );

      final Rect frame = tester.getRect(find.byType(CardRowFrame));
      final double stripWidth = 1.sw - CardRowFrame.stripInset;
      expect(frame.width, stripWidth);
      expect(
        frame.left - railWidth,
        (1820 - stripWidth) / 2,
        reason: 'a 1780 strip centers 20 px into the 1820 content viewport',
      );
    });

    testWidgets('the placeholder count follows the viewport width', (
      tester,
    ) async {
      for (final (double viewWidth, int expected) in [
        (740.0, 5),
        (1340.0, 9),
        (2540.0, 17),
      ]) {
        await pumpInShell(
          tester,
          const CardRowFrame.browse(child: CardRowSkeleton()),
          viewWidth: viewWidth,
          contentWidth: viewWidth - 100,
        );

        final Rect strip = tester.getRect(find.byType(CardRowSkeleton));
        expect(strip.width, viewWidth - CardRowFrame.stripInset);
        final SliverChildBuilderDelegate delegate =
            tester.widget<ListView>(find.byType(ListView)).childrenDelegate
                as SliverChildBuilderDelegate;
        expect(
          delegate.childCount,
          cardsAt(strip.width),
          reason:
              'at ${strip.width} wide the loaded strip shows '
              '${cardsAt(strip.width)} cards',
        );
        expect(delegate.childCount, expected);
      }
    });
  });

  group('CardRowFrame.details', () {
    testWidgets(
      'insets the strip by 35 like the character/recommendation rows, for the '
      'placeholder and the content alike',
      (tester) async {
        const double contentWidth = 1365; // flex 75 of (75 + 35) of 1820
        await pumpInShell(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CardRowFrame.details(child: CardRowSkeleton()),
              CardRowFrame.details(
                child: UnyoCharacterList(
                  characters: const [],
                  controller: ScrollController(),
                ),
              ),
            ],
          ),
          contentWidth: contentWidth,
        );

        final Rect skeleton = tester.getRect(find.byType(CardRowSkeleton));
        final Rect loaded = tester.getRect(find.byType(UnyoCharacterList));
        expect(
          loaded.left,
          skeleton.left,
          reason: 'same 35.w inset on both sides',
        );
        expect(loaded.width, skeleton.width);
        expect(skeleton.left - railWidth, CardRowFrame.detailsInset.w);
        expect(
          skeleton.width,
          contentWidth - 2 * CardRowFrame.detailsInset.w,
          reason: 'the strip fills the details column between the insets',
        );
      },
    );
  });
}
