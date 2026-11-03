// External dependencies
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/config/assets.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/widgets/styled/add_user_avatar.dart';
import 'package:unyo/presentation/widgets/styled/user_avatar_image.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';

import '../../../support/localized_app.dart';

/// WP #102: the default avatar and the add-user glyph ship with the binary.
/// Avatars are persisted in Hive, so already-stored local accounts still hold
/// the pre-#102 third-party URL — that legacy value must render the bundled
/// asset instead of hitting the network.
void main() {
  // The value pre-#102 builds wrote into Hive for every local account.
  const String legacyPersistedAvatar = 'https://i.imgur.com/EKtChtm.png';

  Future<void> pumpAvatar(WidgetTester tester, String avatarImage) async {
    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(body: Center(child: UserAvatarImage(avatarImage: avatarImage, borderRadius: 8))),
      ),
    );
    // `localizedApp` resolves its bundle one microtask after the first frame.
    await tester.pump();
  }

  group('UserAvatarImage.bundledAssetFor', () {
    test('empty avatar resolves to the bundled default', () {
      expect(UserAvatarImage.bundledAssetFor(''), AppAssets.defaultAvatar);
      expect(UserAvatarImage.bundledAssetFor('   '), AppAssets.defaultAvatar);
    });

    test('the legacy persisted placeholder resolves to the bundled default', () {
      expect(UserAvatarImage.bundledAssetFor(legacyPersistedAvatar), AppAssets.defaultAvatar);
    });

    test('an explicit bundled asset path is kept', () {
      expect(UserAvatarImage.bundledAssetFor('assets/images/custom.png'), 'assets/images/custom.png');
    });

    test('a real remote avatar stays remote', () {
      expect(UserAvatarImage.bundledAssetFor('https://s4.anilist.co/file/anilistcdn/user/1.jpg'), isNull);
      expect(UserAvatarImage.bundledAssetFor('https://shikimori.io/avatar/1.png'), isNull);
    });
  });

  testWidgets('an empty avatar renders the bundled asset, not a network image', (WidgetTester tester) async {
    await pumpAvatar(tester, '');

    expect(find.byType(UnyoNetworkImage), findsNothing, reason: 'no skeleton/fade for a bundled file');
    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.defaultAvatar);
  });

  testWidgets('a migrated legacy avatar renders the bundled asset and makes no request', (
    WidgetTester tester,
  ) async {
    await pumpAvatar(tester, legacyPersistedAvatar);

    expect(find.byType(UnyoNetworkImage), findsNothing, reason: 'the legacy URL must never be fetched');
    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.defaultAvatar);
  });

  testWidgets('a remote avatar still goes through UnyoNetworkImage', (WidgetTester tester) async {
    const String remote = 'https://s4.anilist.co/file/anilistcdn/user/1.jpg';
    await pumpAvatar(tester, remote);

    final UnyoNetworkImage network = tester.widget<UnyoNetworkImage>(find.byType(UnyoNetworkImage));
    expect(network.url, remote);
    final Image image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>(), reason: 'remote avatars keep loading over the network');
  });

  test('UserModel.empty() persists no third-party avatar URL', () {
    expect(UserModel.empty().avatarImage, isEmpty);
  });

  testWidgets('the add-user tile draws the bundled plus glyph with cover fit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        home: const Scaffold(body: Center(child: AddUserAvatarGlyph())),
      ),
    );
    await tester.pump();

    expect(find.byType(UnyoNetworkImage), findsNothing, reason: 'nothing in the tile is fetched');
    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, AppAssets.addUserIcon);
    expect(image.fit, BoxFit.cover, reason: 'same cover fit as the remote artwork it replaces');
  });

  test('both bundled images ship in the asset bundle', () async {
    for (final String asset in <String>[AppAssets.defaultAvatar, AppAssets.addUserIcon]) {
      final ByteData data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(512), reason: '$asset must be a real image');
      expect(
        data.buffer.asUint8List(data.offsetInBytes, 8),
        <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
        reason: '$asset must be a PNG',
      );
    }
  });
}
