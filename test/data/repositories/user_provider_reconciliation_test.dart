// External dependencies
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/adapters/type_adapters/settings_model_migration_adapter.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_provider_reconciliation.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/hive_registrar.g.dart';

/// Hive's adapter registry is process-global; register the real adapters once.
bool _adaptersRegistered = false;

/// WP #123: legacy rows carry the pre-split AniList default even when the
/// account is Shikimori-backed; the account record is the source of truth.
void main() {
  late Directory tempDir;
  late Box<ShikimoriUserModel> box;
  final Logger logger = Logger(level: Level.off);

  ShikimoriUserModel user({required String name, required Service userService}) => ShikimoriUserModel(
        id: '1819521',
        name: name,
        settings: SettingsModel.empty().copyWith(userService: userService),
        avatarImage: '',
        bannerImage: '',
        accessToken: '',
        refreshToken: '',
        accessTokenExpiresAt: '',
        profileUrl: '',
      );

  Future<List<User>> reconcile() => UserProviderReconciliation.reconcile<ShikimoriUserModel>(
        box: box,
        provider: Service.shikimori,
        logger: logger,
        withSettings: (ShikimoriUserModel user, SettingsModel settings) => user.copyWith(settings: settings),
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('unyo_user_provider_');
    Hive.init(tempDir.path);
    if (!_adaptersRegistered) {
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapters()
        ..registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
      _adaptersRegistered = true;
    }
    box = await Hive.openBox<ShikimoriUserModel>('shikimoriUsers');
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('a legacy AniList default on a Shikimori account is corrected and persisted', () async {
    final ShikimoriUserModel legacy = user(name: 'Kiwib5', userService: Service.anilist);
    await box.put(legacy.name, legacy);

    final List<User> users = await reconcile();

    expect(users, hasLength(1));
    expect(users.single.settings.userService, Service.shikimori);
    expect(box.get('Kiwib5')!.settings.userService, Service.shikimori);
  });

  test('a row that already names its provider is not rewritten', () async {
    final ShikimoriUserModel correct = user(name: 'Kiwib5', userService: Service.shikimori);
    final ShikimoriUserModel legacy = user(name: 'RodrigoXDDD', userService: Service.anilist);
    await box.put(correct.name, correct);
    await box.put(legacy.name, legacy);

    final List<User> users = await reconcile();

    expect(users, hasLength(2));
    expect(users.where((User user) => user.name == 'Kiwib5').single, same(box.get('Kiwib5')));
    expect(box.get('Kiwib5')!.settings.userService, Service.shikimori);
    expect(box.get('RodrigoXDDD')!.settings.userService, Service.shikimori);
  });

  test('a second run is a no-op', () async {
    await box.put('Kiwib5', user(name: 'Kiwib5', userService: Service.anilist));

    final List<User> first = await reconcile();
    final List<User> second = await reconcile();

    expect(second, hasLength(1));
    expect(identical(second.single, first.single), isTrue);
  });
}
