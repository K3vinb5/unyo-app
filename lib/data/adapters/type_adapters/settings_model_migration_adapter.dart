import 'package:hive_ce/hive.dart';

// Internal dependencies
import 'package:unyo/domain/entities/user/settings.dart';

/// Production settings adapter: the generated [SettingsModelAdapter] plus the
/// pre-split `service` reconciliation.
///
/// The `anilistUsers` box stores settings as **binary** sub-frames, so
/// `SettingsModel.fromJson` never runs for real data — `read` on this adapter
/// is the only place the migration can fire. Registering it overrides the
/// generated adapter for the same typeId (see `main.dart`).
///
/// Writes keep the legacy `service` field a mirror of `metadataService`, which
/// is what makes the read-time rule in [SettingsModel.reconcileLegacyService]
/// unambiguous.
class SettingsModelMigrationAdapter extends TypeAdapter<SettingsModel> {
  final SettingsModelAdapter _generated = SettingsModelAdapter();

  @override
  int get typeId => _generated.typeId;

  @override
  SettingsModel read(BinaryReader reader) => SettingsModel.reconcileLegacyService(_generated.read(reader));

  @override
  void write(BinaryWriter writer, SettingsModel obj) =>
      _generated.write(writer, SettingsModel.mirrorLegacyService(obj));
}
