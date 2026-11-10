// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/hive_registrar.g.dart';

/// Hive's adapter registry is process-global; register the real adapters once.
bool _adaptersRegistered = false;

/// `MalUserModel` is the persisted shape of a MAL account (WP #156): the
/// identity fields every [User] carries plus the OAuth token triple
/// (`accessToken`, `refreshToken`, `accessTokenExpiresAt`) that
/// `MalAuthService` rotates. This suite proves the generated Hive adapter and
/// the freezed JSON pair survive a round trip with the token fields intact.
void main() {
  late Directory tempDir;
  const String boxName = 'malUsers';

  MalUserModel userWith({
    String accessToken = 'access-1',
    String refreshToken = 'refresh-1',
    String accessTokenExpiresAt = '2026-11-08T13:00:00.000Z',
  }) {
    return MalUserModel(
      id: '9876',
      name: 'mal-tester',
      settings: const SettingsModel(userService: Service.mal, metadataService: Service.anilist),
      avatarImage: 'https://cdn.myanimelist.net/images/user/9876.jpg',
      bannerImage: '',
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      profileUrl: 'https://myanimelist.net/profile/mal-tester',
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('unyo_mal_user_model_');
    Hive.init(tempDir.path);
    if (!_adaptersRegistered) {
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapters();
      _adaptersRegistered = true;
    }
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('the generated adapter round-trips every field through a Hive box', () async {
    final Box<MalUserModel> box = await Hive.openBox<MalUserModel>(boxName);
    final MalUserModel user = userWith();

    await box.put(user.name, user);
    final MalUserModel? read = box.get(user.name);
    await box.close();

    expect(read, isNotNull);
    expect(read!.id, '9876');
    expect(read.name, 'mal-tester');
    expect(read.avatarImage, 'https://cdn.myanimelist.net/images/user/9876.jpg');
    expect(read.bannerImage, '');
    expect(read.accessToken, 'access-1');
    expect(read.refreshToken, 'refresh-1');
    expect(read.accessTokenExpiresAt, '2026-11-08T13:00:00.000Z');
    expect(read.profileUrl, 'https://myanimelist.net/profile/mal-tester');
    final SettingsModel settings = read.settings as SettingsModel;
    expect(settings.userService, Service.mal);
    expect(settings.metadataService, Service.anilist);
  });

  test('the adapter is registered under the shared MAL type id', () {
    final MalUserModelAdapter adapter = MalUserModelAdapter();

    expect(adapter.typeId, types.malUserAdapterType);
  });

  test('the freezed JSON pair round-trips the token triple', () {
    final MalUserModel user = userWith(accessTokenExpiresAt: '2026-12-01T00:00:00.000Z');

    final MalUserModel read = MalUserModel.fromJson(user.toJson());

    expect(read.id, user.id);
    expect(read.name, user.name);
    expect(read.accessToken, 'access-1');
    expect(read.refreshToken, 'refresh-1');
    expect(read.accessTokenExpiresAt, '2026-12-01T00:00:00.000Z');
    expect(read.profileUrl, user.profileUrl);
    expect((read.settings as SettingsModel).userService, Service.mal);
  });
}
