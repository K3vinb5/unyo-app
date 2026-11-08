// External dependencies
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/adapters/type_adapters/settings_model_migration_adapter.dart';
import 'package:unyo/data/migrations/user_box_schema_migration.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/hive_registrar.g.dart';

/// Writes a settings frame with one field more than this build knows — field 24
/// whose value carries adapter typeId 12 (stored as 44, i.e. `12 + 32`
/// reserved ids), exactly how a newer build persists a field this one does not
/// ship. Write-only: the payload is never meant to be read here.
class _NewerSchemaSettingsAdapter extends TypeAdapter<SettingsModel> {
  @override
  int get typeId => types.settingsAdapterType;

  @override
  SettingsModel read(BinaryReader reader) => throw UnimplementedError('write-only test adapter');

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.service)
      ..writeByte(24)
      ..writeByte(44)
      ..writeByte(1)
      ..writeByte(0)
      ..write(5);
  }
}

/// Hive's adapter registry is process-global; register the real adapters once.
bool _adaptersRegistered = false;

void main() {
  late Directory tempDir;
  final Logger logger = Logger(level: Level.off);

  AnilistUserModel user({required String name, required String id}) => AnilistUserModel(
        id: id,
        name: name,
        settings: SettingsModel.empty(),
        avatarImage: '',
        bannerImage: '',
        accessCode: '',
        accessToken: '',
        refreshToken: '',
      );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('unyo_user_box_migration_');
    Hive.init(tempDir.path);
    if (!_adaptersRegistered) {
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapters()
        ..registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
      _adaptersRegistered = true;
    }
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('pruning stale schema frames lets both AniList users load', () async {
    final Box<dynamic> box = await Hive.openBox<dynamic>('anilistUsers');
    // A build that does not ship adapter 12 wrote this row first (as every
    // real box is written at some point, by whichever build saved last)…
    Hive.registerAdapter<SettingsModel>(_NewerSchemaSettingsAdapter(), override: true);
    await box.put('Kiwib5', user(name: 'Kiwib5', id: '859862'));
    // …then the current build saved both accounts, superseding that frame.
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    await box.put('Kiwib5', user(name: 'Kiwib5', id: '859862'));
    await box.put('RodrigoXDDD', user(name: 'RodrigoXDDD', id: '6687402'));
    await box.close();

    // Precondition: opening deserialises the superseded frame too, so the whole
    // box — both accounts — is unreadable.
    await expectLater(
      Hive.openBox<AnilistUserModel>('anilistUsers'),
      throwsA(isA<HiveError>().having((HiveError error) => error.message, 'message', contains('unknown typeId'))),
    );
    await Hive.close();

    await UserBoxSchemaMigration(logger).run();

    final Box<AnilistUserModel> loaded = await Hive.openBox<AnilistUserModel>('anilistUsers');
    expect(loaded.keys, containsAll(<String>['Kiwib5', 'RodrigoXDDD']));
    expect(loaded.get('Kiwib5')!.settings.language, 'en_GB');
    await Hive.close();

    // Idempotent: the same generation is not pruned twice.
    final int sizeBefore = File('${tempDir.path}/anilistusers.hive').lengthSync();
    await UserBoxSchemaMigration(logger).run();
    expect(File('${tempDir.path}/anilistusers.hive').lengthSync(), sizeBefore);
  });
}
