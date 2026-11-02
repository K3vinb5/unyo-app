// External dependencies
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/config/assets.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/skeleton/skeletons.dart';
import 'package:unyo/presentation/widgets/styled/add_user_avatar.dart';
import 'package:unyo/presentation/widgets/styled/hover_animated_container.dart';
import 'package:unyo/presentation/widgets/styled/service_badge.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/styled/user_avatar.dart';

import '../../../support/localized_app.dart';
import '../skeleton/support/fake_image_http.dart';

/// WP #112: an account tile says which service owns the account, as one small
/// badge in the avatar's bottom-right.
UserModel providerUser({
  String id = '42',
  String name = 'alice',
  Service userService = Service.anilist,
}) => UserModel(
  id: id,
  name: name,
  settings: SettingsModel.empty().copyWith(userService: userService),
  avatarImage: 'https://example.test/avatar.png',
  bannerImage: '',
);

/// Offline accounts keep the default `userService` (AniList) in their settings,
/// so only their type distinguishes them.
LocalUserModel localUser({String name = 'Kiwib5'}) => LocalUserModel(
  id: '',
  name: name,
  settings: SettingsModel.empty(),
  avatarImage: 'https://example.test/avatar.png',
  bannerImage: '',
);

void main() {
  group('ServiceBadge mapping', () {
    test('every user provider resolves to its own brand mark', () {
      expect(ServiceBadge.fromService(Service.anilist), ServiceBadge.anilist);
      expect(ServiceBadge.fromService(Service.shikimori), ServiceBadge.shikimori);
      expect(ServiceBadge.fromService(Service.mal), ServiceBadge.myanimelist);
      expect(ServiceBadge.anilist.asset, 'assets/images/anilist.svg');
      expect(ServiceBadge.shikimori.asset, 'assets/images/shikimori.svg');
      expect(ServiceBadge.myanimelist.asset, 'assets/images/myanimelist.svg');
    });

    test('providers without a brand mark fall back to the generic glyph', () {
      for (final Service service in <Service>[Service.kitsu, Service.simkl]) {
        expect(ServiceBadge.fromService(service), ServiceBadge.generic, reason: service.name);
      }
      expect(ServiceBadge.generic.asset, isNull);
      expect(ServiceBadge.generic.glyph, isNotNull);
    });

    test('a local account is its own mark, not an unknown one and not AniList', () {
      expect(ServiceBadge.of(localUser()), ServiceBadge.local);
      expect(ServiceBadge.local.asset, 'assets/images/local_account.svg');
      expect(ServiceBadge.local, isNot(ServiceBadge.generic));
      expect(ServiceBadge.local, isNot(ServiceBadge.anilist));
    });

    test('a provider account is resolved from settings.userService', () {
      expect(ServiceBadge.of(providerUser(userService: Service.shikimori)), ServiceBadge.shikimori);
      expect(ServiceBadge.of(providerUser(userService: Service.anilist)), ServiceBadge.anilist);
    });
  });

  group('UserAvatar badge', () {
    Future<void> pumpTile(WidgetTester tester, Widget tile) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1280, 720),
          minTextAdapt: true,
          child: localizedApp(
            home: Scaffold(
              body: Center(child: SkeletonScope(child: tile)),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('each account renders the badge of its own service', (WidgetTester tester) async {
      await withFakeImages(() async {
        for (final Service service in <Service>[Service.anilist, Service.shikimori, Service.mal, Service.kitsu]) {
          final User user = providerUser(name: service.name, userService: service);
          await pumpTile(
            tester,
            UserAvatar(user: user, onPressed: () {}),
          );

          final ServiceBadgeView view = tester.widget<ServiceBadgeView>(
            find.byKey(UserAvatar.badgeKeyFor(user)),
          );
          expect(view.badge, ServiceBadge.fromService(service), reason: service.name);
        }
      });
    });

    testWidgets('a local account shows the local mark, not the AniList one it defaults to', (
      WidgetTester tester,
    ) async {
      await withFakeImages(() async {
        final LocalUserModel user = localUser();
        await pumpTile(tester, UserAvatar(user: user, onPressed: () {}));

        final ServiceBadgeView view = tester.widget<ServiceBadgeView>(
          find.byKey(UserAvatar.badgeKeyFor(user)),
        );
        expect(view.badge, ServiceBadge.local);
      });
    });

    testWidgets('the badge sits bottom-right inside the avatar circle without moving the layout', (
      WidgetTester tester,
    ) async {
      await withFakeImages(() async {
        final User user = providerUser();
        await pumpTile(tester, UserAvatar(user: user, onPressed: () {}));

        final Rect avatar = tester.getRect(find.byType(HoverAnimatedContainer));
        final Rect badge = tester.getRect(find.byKey(UserAvatar.badgeKeyFor(user)));

        // Bottom-right quadrant.
        expect(badge.center.dx, greaterThan(avatar.center.dx));
        expect(badge.center.dy, greaterThan(avatar.center.dy));

        // Fully inside the circle, not merely inside its bounding box.
        final double reach = (badge.center - avatar.center).distance + badge.width / 2;
        expect(reach, lessThanOrEqualTo(avatar.width / 2 + 0.5), reason: 'badge must stay inside the circle');

        // Overlay: the badge neither grows nor shifts the 160.h avatar box.
        expect(avatar.width, closeTo(avatar.height, 0.01));
        expect(avatar.width, closeTo(160, 0.01));
        expect(avatar.contains(badge.topLeft), isTrue);
        expect(avatar.contains(badge.bottomRight - const Offset(0.01, 0.01)), isTrue);
      });
    });

    // Merge of WP #112 (badge) with WP #102 (bundled avatar): the resolver picks
    // the image source, the badge overlay still sits on top of it.
    testWidgets('an account without a picture gets the bundled default under its badge', (
      WidgetTester tester,
    ) async {
      final User user = UserModel.empty().copyWith(id: '7', name: 'offline');
      await pumpTile(tester, UserAvatar(user: user, onPressed: () {}));

      expect(find.byType(UnyoNetworkImage), findsNothing, reason: 'an empty avatar is bundled art, never a request');
      final Image image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, AppAssets.defaultAvatar);
      expect(find.byKey(UserAvatar.badgeKeyFor(user)), findsOneWidget);
    });

    testWidgets('loading placeholders and the add-account tile carry no badge', (WidgetTester tester) async {
      await withFakeImages(() async {
        await pumpTile(
          tester,
          const SizedBox(
            height: 250,
            child: ListTileSkeleton(
              height: 250,
              leadingSize: 160,
              titleWidth: 120,
              vertical: true,
            ),
          ),
        );
        expect(find.byType(ServiceBadgeView), findsNothing);

        await pumpTile(tester, AddUserAvatar(onPressed: () {}));
        expect(find.byType(ServiceBadgeView), findsNothing);
      });
    });
  });
}
