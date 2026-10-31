// Internal dependencies
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/video_display_mode.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// Persists the per-user video display mode (WP #114).
///
/// Same pattern as `ThemeService`: the choice is a field on the user's
/// `settings`, written through the provider-specific repository, which stores it
/// in Hive and re-emits the user on the logged-user notifier. Nothing else in
/// the app keeps a copy, so the value survives a restart and the next episode
/// played.
class VideoDisplayModeStore {
  VideoDisplayModeStore(this._userRepositoryAnilist, this._userRepositoryLocal);

  final UserRepositoryAnilist _userRepositoryAnilist;
  final UserRepositoryLocal _userRepositoryLocal;

  /// Writes [mode] into [user]'s settings and saves that user.
  Future<void> save(User user, VideoDisplayMode mode) async {
    final Settings updatedSettings =
        (user.settings as SettingsModel).copyWith(videoDisplayMode: mode);
    switch (user) {
      case AnilistUserModel anilistUser:
        await _userRepositoryAnilist.updateUserInfo(anilistUser.copyWith(settings: updatedSettings));
      case ShikimoriUserModel shikimoriUser:
        await sl<UserRepositoryShikimori>().updateUserInfo(shikimoriUser.copyWith(settings: updatedSettings));
      case LocalUserModel localUser:
        await _userRepositoryLocal.updateUserInfo(localUser.copyWith(settings: updatedSettings));
    }
  }
}
