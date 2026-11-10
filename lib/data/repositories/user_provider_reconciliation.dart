// External dependencies
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// Makes the persisted [Settings.userService] agree with the account that owns
/// the row (WP #123).
///
/// The provider is not a free choice: it is the repository/box the account was
/// read from (AniList repository → `anilistUsers`, Shikimori repository →
/// `shikimoriUsers`). Rows written before the field existed keep the AniList
/// default, which made the login badge and every service-routing check claim the
/// wrong provider.
///
/// Only divergent rows are written back, so already-correct rows are returned
/// untouched and a second run is a no-op.
class UserProviderReconciliation {
  const UserProviderReconciliation._();

  static Future<List<T>> reconcile<T extends User>({
    required Box<T> box,
    required Service provider,
    required Logger logger,
    required T Function(T user, SettingsModel settings) withSettings,
  }) async {
    final List<T> reconciled = <T>[];
    for (final MapEntry<dynamic, T> entry in box.toMap().entries) {
      final T user = entry.value;
      final Settings settings = user.settings;
      if (settings is! SettingsModel) {
        reconciled.add(user);
        continue;
      }
      final SettingsModel migrated = SettingsModel.reconcileUserService(settings, provider);
      if (identical(migrated, settings)) {
        reconciled.add(user);
        continue;
      }
      final T corrected = withSettings(user, migrated);
      logger.i("Corrected userService of ${user.name} to ${provider.name}");
      await box.put(entry.key, corrected);
      reconciled.add(corrected);
    }
    return reconciled;
  }
}
