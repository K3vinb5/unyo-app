import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/presentation/widgets/styled/unyo_banner_carousel.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import '../skeleton/support/fake_image_http.dart';
import '../skeleton/support/widget_harness.dart';

/// Tail-review sweep on PR #188: the banner carousel printed the raw 0–100
/// `meanScore` next to a star ("90"), the same display bug the details pages
/// had before `TextUtils.scoreOutOfTen` existed. Every user-facing score goes
/// through that helper, so the banner must show "9.0" and never "90".
void main() {
  // Each banner title resolves through the logged-user notifier
  // (`displayMediaTitle`), so the display seam needs the app's registration —
  // same wiring as skeleton_swap_test.
  setUp(() async {
    // GetIt's reset is async: it awaits each registration's dispose and only
    // then clears the registry. Left un-awaited it wipes the registrations
    // added right below it (the WP #166 banner tests caught it: the carousel
    // resolved the title seam against an empty locator).
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(filter: ProductionFilter()));
    sl.registerSingleton<UserNotifier>(
      UserNotifier(),
      instanceName: config.loggedUserNotifier,
    );
  });

  tearDown(() => sl.reset());

  testWidgets('banner score shows the 0-10 form, not the raw 0-100 int', (
    tester,
  ) async {
    await pumpSkeletonHarness(
      tester,
      UnyoBannerCarousel(
        animeList: [AnimeModel.empty().copyWith(id: 1, meanScore: 90)],
      ),
    );

    expect(find.text('9.0'), findsOneWidget);
    expect(
      find.text('90'),
      findsNothing,
      reason: 'the raw 0-100 int must never render beside the star',
    );

    // "9.0" is one glyph wider than the raw "90"; the badge must grow to fit
    // rather than clip it (this overflowed the old fixed 50px box).
    expect(tester.takeException(), isNull);

    // Unmount so the auto-scroll timer is cancelled before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('hero art', () {
    /// The art a page paints: what the user sees in the banner slot.
    String artUrl(WidgetTester tester) {
      return tester
          .widget<UnyoNetworkImage>(find.byType(UnyoNetworkImage))
          .url;
    }

    testWidgets(
      'a MAL-shaped card (no banner, cover set) paints its cover as the hero',
      (tester) async {
        await withFakeImages(() async {
          await pumpSkeletonHarness(
            tester,
            UnyoBannerCarousel(
              animeList: [
                // What `MalAnimeModel.fromNode` produces: Jikan v4 has no
                // banner asset, so the card carries only a cover.
                AnimeModel.empty().copyWith(
                  id: 1,
                  bannerImage: '',
                  coverImage: 'https://cdn.example.test/cover.jpg',
                  meanScore: 87,
                ),
              ],
            ),
          );

          expect(
            artUrl(tester),
            'https://cdn.example.test/cover.jpg',
            reason: 'the cover is the hero art when the provider ships no banner',
          );
          // The text block is real content too: title, 0-10 score, description.
          expect(find.text('8.7'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(const SizedBox.shrink());
        });
      },
    );

    testWidgets(
      'a manga card without a banner paints its cover as the hero',
      (tester) async {
        await withFakeImages(() async {
          await pumpSkeletonHarness(
            tester,
            UnyoBannerCarousel(
              mangaList: [
                MangaModel.empty().copyWith(
                  id: 2,
                  bannerImage: '',
                  coverImage: 'https://cdn.example.test/manga-cover.jpg',
                ),
              ],
            ),
          );

          expect(artUrl(tester), 'https://cdn.example.test/manga-cover.jpg');
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(const SizedBox.shrink());
        });
      },
    );

    testWidgets('the provider banner wins when the card has both', (
      tester,
    ) async {
      await withFakeImages(() async {
        await pumpSkeletonHarness(
          tester,
          UnyoBannerCarousel(
            animeList: [
              AnimeModel.empty().copyWith(
                id: 3,
                bannerImage: 'https://cdn.example.test/banner.jpg',
                coverImage: 'https://cdn.example.test/cover.jpg',
              ),
            ],
          ),
        );

        expect(
          artUrl(tester),
          'https://cdn.example.test/banner.jpg',
          reason: 'AniList/Shikimori keep their real banner-first behavior',
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    });
  });
}
