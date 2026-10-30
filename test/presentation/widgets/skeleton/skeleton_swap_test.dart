import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';
import 'package:unyo/presentation/widgets/styled/unyo_extension_button.dart';
import 'package:unyo/presentation/widgets/styled/unyo_media_banner.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/styled/user_avatar.dart';

import 'support/fake_image_http.dart';
import 'support/widget_harness.dart';

/// Proves the loading -> loaded swap the screens implement: while the section
/// flag is false the skeleton renders, when it flips the real component takes
/// its place and the box does not change size.
void main() {
  // The carousel resolves each card title through the logged-user notifier
  // (`displayMediaTitle`), so the display seam needs the app's registration.
  setUp(() {
    sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    sl.registerSingleton<UserNotifier>(UserNotifier(), instanceName: config.loggedUserNotifier);
  });

  tearDown(() => sl.reset());

  Widget mediaCard() => MediaCard(
    title: 'Some Anime',
    score: 71,
    coverImage: 'https://example.test/cover.png',
    onPressed: () {},
    status: 'RELEASING',
    year: '2020/01/01',
    format: 'TV',
    tag: 'test-card',
  );

  Widget extensionRow() => const UnyoExtensionButton(
    iconUrl: 'https://example.test/icon.png',
    name: 'Aniyomi Test',
    lang: 'en',
    version: '1.2.3',
    nsfw: 0,
    repoUrl: 'https://example.test/repo',
  );

  testWidgets('a media card cell swaps its skeleton for the real card', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(tester, const MediaCardSkeleton());
      expect(find.byType(MediaCardSkeleton), findsOneWidget);
      expect(find.byType(MediaCard), findsNothing);
      final Size loadingSize = tester.getSize(find.byType(MediaCardSkeleton));

      await pumpSkeletonHarness(tester, mediaCard());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MediaCard), findsOneWidget);
      expect(find.byType(MediaCardSkeleton), findsNothing);
      expect(
        tester.getSize(find.byType(MediaCard)),
        loadingSize,
        reason: 'the loaded card must occupy exactly the skeleton box',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('an extension row swaps its skeleton for the real row', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const Column(children: [ExtensionRowSkeleton()]),
      );
      final Size loadingSize = tester.getSize(find.byType(ExtensionRowSkeleton));

      await pumpSkeletonHarness(tester, Column(children: [extensionRow()]));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(UnyoExtensionButton), findsOneWidget);
      expect(find.byType(ExtensionRowSkeleton), findsNothing);
      expect(
        tester.getSize(find.byType(UnyoExtensionButton)),
        loadingSize,
        reason: 'the loaded row must occupy exactly the skeleton box',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a card row swaps every placeholder for real cards', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(tester, const CardRowSkeleton(cardCount: 2));
      expect(find.byType(MediaCardSkeleton), findsNWidgets(2));

      await pumpSkeletonHarness(
        tester,
        SizedBox(
          height: CardRowMetrics.rowHeight,
          child: ListView(children: [mediaCard(), mediaCard()]),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MediaCard), findsNWidgets(2));
      expect(find.byType(MediaCardSkeleton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the details header swaps its skeleton for the media banner', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(tester, const DetailHeaderSkeleton());
      final Size loadingSize = tester.getSize(find.byType(DetailHeaderSkeleton));
      expect(loadingSize.height, 300);

      await pumpSkeletonHarness(
        tester,
        const UnyoMediaBanner(
          imageUrl: 'https://example.test/banner.png',
          coverImage: 'https://example.test/cover.png',
          title: 'Some Anime',
          status: 'RELEASING',
          tag: 'details-banner',
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DetailHeaderSkeleton), findsNothing);
      expect(
        tester.getSize(find.byType(UnyoMediaBanner)).height,
        loadingSize.height,
        reason: 'the banner must keep the skeleton header height',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the browse banner swaps its skeleton for the carousel', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(tester, const BannerCarouselSkeleton());
      final double loadingHeight = tester
          .getSize(find.byType(BannerCarouselSkeleton))
          .height;

      await pumpSkeletonHarness(
        tester,
        UnyoBannerCarousel(
          animeList: [
            AnimeModel.empty().copyWith(
              bannerImage: 'https://example.test/banner.png',
              coverImage: 'https://example.test/cover.png',
            ),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BannerCarouselSkeleton), findsNothing);
      expect(
        tester.getSize(find.byType(UnyoBannerCarousel)).height,
        loadingHeight,
        reason: 'the carousel must keep the skeleton height',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the login avatar tile swaps its skeleton for a real avatar', (
    tester,
  ) async {
    await withFakeImages(() async {
      const Key tileKey = Key('avatar-tile');
      Widget row(Widget child) => SizedBox(
        height: 250,
        child: Row(children: [KeyedSubtree(key: tileKey, child: child)]),
      );

      // Same 25.w gutter the login screen puts around the tile.
      await pumpSkeletonHarness(
        tester,
        row(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: ListTileSkeleton(
              height: 250,
              leadingSize: 160,
              titleWidth: 120,
              vertical: true,
            ),
          ),
        ),
      );
      final Size loadingSize = tester.getSize(find.byKey(tileKey));

      await pumpSkeletonHarness(
        tester,
        row(UserAvatar(user: UserModel.empty(), onPressed: () {})),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListTileSkeleton), findsNothing);
      expect(
        tester.getSize(find.byKey(tileKey)),
        loadingSize,
        reason: 'the avatar column must keep the skeleton tile box',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a media card always keeps a poster-sized image slot', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(tester, mediaCard());

      // The grid/list regression: the cover area must be a poster-sized slot
      // whether or not the image has resolved.
      final Finder slot = find.descendant(
        of: find.byType(MediaCard),
        matching: find.byType(UnyoNetworkImage),
      );
      expect(
        tester.getSize(slot),
        const Size(MediaCardMetrics.coverWidth, MediaCardMetrics.coverHeight),
      );

      await pumpSkeletonHarness(tester, const MediaCardSkeleton());
      expect(
        tester.getSize(find.byType(SkeletonBlock).first),
        const Size(MediaCardMetrics.coverWidth, MediaCardMetrics.coverHeight),
        reason: 'the placeholder reserves the same poster box as the card',
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('grid cells are the size the skeleton grid reserves', (
    tester,
  ) async {
    await withFakeImages(() async {
      await pumpSkeletonHarness(
        tester,
        const SizedBox(height: 700, child: MediaGridSkeleton(itemCount: 4)),
      );
      final Size skeletonCell = tester.getSize(
        find.byType(MediaCardSkeleton).first,
      );

      await pumpSkeletonHarness(
        tester,
        SizedBox(
          height: 700,
          child: GridView.builder(
            gridDelegate: mediaGridDelegate,
            itemCount: 4,
            itemBuilder:
                (context, index) => SizedBox(width: 165, child: mediaCard()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.getSize(find.byType(MediaCard).first), skeletonCell);
      expect(tester.takeException(), isNull);
    });
  });
}
