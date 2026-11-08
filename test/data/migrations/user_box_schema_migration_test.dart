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
/// whose value carries adapter typeId 12, stored as 44. `writeTypeId` writes its
/// argument verbatim, but `RawObjectWriter` passes `resolved.typeId`, which
/// `TypeRegistryImpl` computes as `calculateTypeId(adapter.typeId)` =
/// `typeId + reservedTypeIds` (32) for external adapters — so a future adapter
/// typeId 12 really does appear in the stream as 44, exactly how a newer build
/// persists a field this one does not ship.
/// Write-only: the payload is never meant to be read here.
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

/// Collects log events so a test can assert the startup wrapper reported one.
class _RecordingLogOutput extends LogOutput {
  final List<OutputEvent> events = <OutputEvent>[];

  @override
  void output(OutputEvent event) => events.add(event);
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

  /// Writes [name] with the newer schema first, then supersedes it with the
  /// current build's frame — the shape every real box has after two builds.
  Future<void> writeSupersededFrame({required Box<dynamic> box, required String name, required String id}) async {
    Hive.registerAdapter<SettingsModel>(_NewerSchemaSettingsAdapter(), override: true);
    await box.put(name, user(name: name, id: id));
    Hive.registerAdapter<SettingsModel>(SettingsModelMigrationAdapter(), override: true);
    await box.put(name, user(name: name, id: id));
  }

  Matcher unknownTypeId() => throwsA(
        isA<HiveError>().having((HiveError error) => error.message, 'message', contains('unknown typeId')),
      );

  int boxFileSize() => File('${tempDir.path}/anilistusers.hive').lengthSync();

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
    // A build that does not ship adapter 12 wrote this row first (as every real
    // box is written at some point, by whichever build saved last)…
    await writeSupersededFrame(box: box, name: 'Kiwib5', id: '859862');
    // …then the current build saved both accounts, superseding that frame.
    await box.put('RodrigoXDDD', user(name: 'RodrigoXDDD', id: '6687402'));
    await box.close();

    // Precondition: opening deserialises the superseded frame too, so the whole
    // box — both accounts — is unreadable.
    await expectLater(Hive.openBox<AnilistUserModel>('anilistUsers'), unknownTypeId());
    await Hive.close();

    await UserBoxSchemaMigration(logger).run();

    final Box<AnilistUserModel> loaded = await Hive.openBox<AnilistUserModel>('anilistUsers');
    expect(loaded.keys, containsAll(<String>['Kiwib5', 'RodrigoXDDD']));
    expect(loaded.get('Kiwib5')!.settings.language, 'en_GB');
    await Hive.close();

    // A launch on an already-clean box changes nothing: no stale frames left.
    final int sizeBefore = boxFileSize();
    await UserBoxSchemaMigration(logger).run();
    expect(boxFileSize(), sizeBefore);
  });

  test('a second schema skew after a successful prune is pruned again', () async {
    final Box<dynamic> box = await Hive.openBox<dynamic>('anilistUsers');
    await writeSupersededFrame(box: box, name: 'Kiwib5', id: '859862');
    await box.put('RodrigoXDDD', user(name: 'RodrigoXDDD', id: '6687402'));
    await box.close();
    await UserBoxSchemaMigration(logger).run();
    await Hive.close();

    // The same box crosses the schema boundary again: another build superseded
    // by the current one. Bookkeeping ("already pruned") would now skip it.
    final Box<dynamic> reopened = await Hive.openBox<dynamic>('anilistUsers');
    await writeSupersededFrame(box: reopened, name: 'RodrigoXDDD', id: '6687402');
    await reopened.close();

    await expectLater(Hive.openBox<AnilistUserModel>('anilistUsers'), unknownTypeId());
    await Hive.close();

    final int sizeWithStaleFrame = boxFileSize();
    await UserBoxSchemaMigration(logger).run();
    expect(boxFileSize(), lessThan(sizeWithStaleFrame));

    final Box<AnilistUserModel> loaded = await Hive.openBox<AnilistUserModel>('anilistUsers');
    expect(loaded.keys, containsAll(<String>['Kiwib5', 'RodrigoXDDD']));
    expect(loaded.get('Kiwib5')!.settings.language, 'en_GB');
    await Hive.close();
  });

  test('runOrReport swallows a failing migration and logs the error', () async {
    // Occupying the box file path with a directory makes the box open fail with
    // an I/O error — the crash-recovery path that would silently truncate a
    // corrupt file never runs, so `run()` really throws.
    Directory('${tempDir.path}/anilistusers.hive').createSync();

    final UserBoxSchemaMigration migration = UserBoxSchemaMigration(logger);
    await expectLater(migration.run(), throwsA(isA<FileSystemException>()));

    final _RecordingLogOutput output = _RecordingLogOutput();
    final Logger recordingLogger = Logger(output: output, level: Level.all);
    await expectLater(UserBoxSchemaMigration(recordingLogger).runOrReport(), completes);
    expect(output.events, hasLength(1));
    expect(output.events.single.level, Level.error);
  });
}
