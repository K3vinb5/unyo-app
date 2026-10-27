// External dependencies
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/adapters/type_adapters/settings_model_migration_adapter.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/hive_registrar.g.dart';

/// Writes exactly what a pre-split install wrote: the old `service` knob is
/// present, `userService`/`metadataService` do not exist yet.
class _PreSplitSettingsAdapter extends TypeAdapter<SettingsModel> {
  @override
  int get typeId => types.settingsAdapterType;

  @override
  SettingsModel read(BinaryReader reader) => throw UnimplementedError('write-only test adapter');

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.service);
  }
}

/// Hive's adapter registry is process-global; register the real adapters once.
bool _adaptersRegistered = false;

void main() {
  late Directory tempDir;
  const String boxName = 'anilistUsers';

  AnilistUserModel userWith(Settings settings) => AnilistUserModel(
        id: '42',
        name: 'pre-split user',
        settings: settings,
        avatarImage: '',
        bannerImage: '',
        accessCode: '',
        accessToken: '',
        refreshToken: '',
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('unyo_settings_migration_');
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

  test('a pre-split Hive row keeps its metadata provider when read through the adapter', () async {
    // Phase 1: write the row the way the pre-split build did — no
    // metadataService/userService fields in the binary frame at all.
    Hive.registerAdapter<SettingsModel>(_PreSplitSettingsAdapter(), override: true);
    final Box<AnilistUserModel> box = await Hive.openBox<AnilistUserModel>(boxName);
    await box.put('u42', userWith(const SettingsModel(service: Service.shikimori)));
    await box.close();
    await Hive.close();

    // Phase 2: production registration (generated adapters, then the migration
    // wrapper over the settings typeId) and a cold read from disk.
    Hive.init(tempDir.path);
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    final Box<AnilistUserModel> reopened = await Hive.openBox<AnilistUserModel>(boxName);

    final AnilistUserModel user = reopened.get('u42')!;
    final SettingsModel settings = user.settings as SettingsModel;

    expect(settings.metadataService, Service.shikimori,
        reason: 'the pre-split service value is the media metadata provider');
    expect(settings.userService, Service.anilist,
        reason: 'existing installs were always signed in to AniList');
    await reopened.close();
  });

  test('a genuine post-split AniList choice survives the read rule', () async {
    // Writes mirror metadataService into the legacy service field, so an
    // AniList metadata choice reads back as AniList instead of being rewritten
    // by the reconciliation rule.
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    final Box<AnilistUserModel> box = await Hive.openBox<AnilistUserModel>(boxName);
    await box.put(
      'u1',
      userWith(const SettingsModel(userService: Service.anilist, metadataService: Service.anilist)),
    );
    await box.close();
    await Hive.close();

    Hive.init(tempDir.path);
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    final Box<AnilistUserModel> reopened = await Hive.openBox<AnilistUserModel>(boxName);
    final SettingsModel settings = reopened.get('u1')!.settings as SettingsModel;

    expect(settings.metadataService, Service.anilist);
    expect(settings.userService, Service.anilist);
    expect(settings.service, Service.anilist);
    await reopened.close();
  });

  test('the adapter write keeps the legacy service field mirrored', () async {
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    final Box<AnilistUserModel> box = await Hive.openBox<AnilistUserModel>(boxName);
    await box.put(
      'u2',
      userWith(const SettingsModel(userService: Service.anilist, metadataService: Service.shikimori)),
    );
    await box.close();
    await Hive.close();

    Hive.init(tempDir.path);
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    final Box<AnilistUserModel> reopened = await Hive.openBox<AnilistUserModel>(boxName);
    final SettingsModel settings = reopened.get('u2')!.settings as SettingsModel;

    expect(settings.metadataService, Service.shikimori);
    expect(settings.service, Service.shikimori, reason: 'every write keeps the legacy field in sync');
    await reopened.close();
  });
}
