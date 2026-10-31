import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/settings_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/response_cache_scope.dart';
import 'package:unyo/core/services/media/episode_service.dart';
import 'package:unyo/core/services/media/media_service.dart';
import 'package:unyo/core/theme/color_image_service.dart';
import 'package:unyo/core/theme/theme_service.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/repositories.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/presentation/dialogs/extensions_dialog.dart';
import 'package:unyo/presentation/dialogs/theme_color_picker_dialog.dart';

class SettingsCubit extends Cubit<SettingsState> with EffectMixin<SettingsState> {
  final Logger _logger = sl<Logger>();

  // Repositories
  final UserRepository _userRepository;
  final UserRepositoryLocal _userRepositoryLocal;

  // Notifiers
  final UserNotifier _loggedUserNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<User> _loggedUserSubscription;

  // Services
  final ThemeService _themeService;
  final ColorImageService _colorImageService;

  SettingsCubit(
    this._userRepository,
    this._userRepositoryLocal,
    this._loggedUserNotifier,
    this._reloadNotifier,
    this._themeService,
    this._colorImageService,
  ) : super(SettingsState(loggedUser: UserModel.empty())) {
    _init();
  }

  @override
  SettingsState copyStateWithEffects(SettingsState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    return super.close();
  }

  @override
  Logger get logger => _logger;

  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) async {
      emit(state.copyWith(loggedUser: loggedUser));
    });
  }

  Future<void> updateMediaMetadataService(String? newService) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        metadataService: MediaServiceFactory.getEnumMediaService(newService),
      );
      await _updateUserInfo(updatedSettings);
      // Lazy tabs have no cubit to receive the reload broadcast, so the cache
      // the previous provider populated is scoped out here as well.
      sl<ResponseCacheScope>().invalidate();
      _reloadNotifier.emitReload(ReloadType.newMetadataService);
    } catch (e, stackTrace) {
      logger.e("Error updating media metadata service $e", stackTrace: stackTrace);
      handleError("Error updating media metadata service", stackTrace: stackTrace);
    }
  }

  Future<void> updateEpisodeMetadataService(String? newService) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        episodeService: EpisodeMediaServiceFactory.getEnumEpisodeService(newService),
      );
      await _updateUserInfo(updatedSettings);
      // The episode provider changed too: cached AniZip rows belong to the
      // provider that served them, so scope them out exactly like the metadata
      // switch does.
      sl<ResponseCacheScope>().invalidate();
      _reloadNotifier.emitReload(ReloadType.newEpisodeService);
    } catch (e, stackTrace) {
      logger.e("Error updating episode metadata service $e", stackTrace: stackTrace);
      handleError("Error updating episode metadata service", stackTrace: stackTrace);
    }
  }

  Future<void> updateMediaTitleLanguage(String? newLanguage) async {
    if (newLanguage == null || newLanguage.isEmpty) {
      return;
    }
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        mediaTitleLanguage: newLanguage,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error updating media title language $e", stackTrace: stackTrace);
      handleError("Error updating media title language", stackTrace: stackTrace);
    }
  }

  Future<void> updateEpisodeTitleLanguage(String? newLanguage) async {
    if (newLanguage == null || newLanguage.isEmpty) {
      return;
    }
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        episodeTitleLanguage: newLanguage,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error updating episode title language $e", stackTrace: stackTrace);
      handleError("Error updating episode title language", stackTrace: stackTrace);
    }
  }

  Future<void> enableNSFWContent(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        enableNsfwContent: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling NSFW content $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling NSFW content", stackTrace: stackTrace);
    }
  }

  Future<void> enableDiscordRichPresence(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        enableDiscordRichPresence: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling Discord Rich Presence $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling Discord Rich Presence", stackTrace: stackTrace);
    }
  }

  Future<void> enableAutomaticallySkipOpening(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        automaticallySkipOpening: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling automatically skip opening $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling automatically skip opening", stackTrace: stackTrace);
    }
  }

  Future<void> enableAutomaticallySkipEnding(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        automaticallySkipEnding: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling automatically skip ending $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling automatically skip ending", stackTrace: stackTrace);
    }
  }

  Future<void> enableAutoPlayNextEpisode(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        autoPlayNextEpisode: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling auto play next episode $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling auto play next episode", stackTrace: stackTrace);
    }
  }

  Future<void> enableOpenSubtitlesIntegration(bool enable) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        enableOpenSubtitlesIntegration: enable,
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling OpenSubtitles integration $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling OpenSubtitles integration", stackTrace: stackTrace);
    }
  }

  Future<void> enableUseWallpaperAsThemeColor(bool enable) async {
    if (!enable) return;
    try {
      List<Color> wallpaperColors = [];
      switch (state.loggedUser) {
        case AnilistUserModel anilistUserModel:
          _logger.d("Getting anilist user's theme");
          wallpaperColors = await _colorImageService.getColorsFromPalleteGenerator(
            NetworkImage(anilistUserModel.bannerImage),
          );
        case ShikimoriUserModel _:
          // `currentUser` carries no banner, so there is no wallpaper to sample;
          // the primary colour stays the account colour (same as a local user).
          _logger.d("Getting shikimori user's theme");
        case LocalUserModel _:
          _logger.d("Getting local user's theme");
      }
      _themeService.updateThemeFromColors(
        loggedUser: state.loggedUser,
        useWallpaperAsThemeColor: true,
        primary: wallpaperColors[0],
        secondary: wallpaperColors[1],
        tertiary: wallpaperColors[2],
      );
    } catch (e, stackTrace) {
      logger.e("Error enabling/disabling using the user wallpaper as a Theme $e", stackTrace: stackTrace);
      handleError("Error enabling/disabling using the user wallpaper as a Theme", stackTrace: stackTrace);
    }
  }

  Future<void> manualSkipTimeUpdate(double newSkipTime) async {
    try {
      Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
        manualSkipTime: newSkipTime.toInt(),
      );
      _updateUserInfo(updatedSettings);
    } catch (e, stackTrace) {
      logger.e("Error updating manual skip time $e", stackTrace: stackTrace);
      handleError("Error updating manual skip time", stackTrace: stackTrace);
    }
  }

  void openAniyomiExtensionsDialog() {
    showWidgetDialogEffect(
      dialog: ExtensionsSettingsDialog(
        width: 600.w,
        height: 400.h,
        title: "Aniyomi extensions repository URL",
        currentRepositoriesUrls: state.loggedUser.settings.aniyomiExtensionsRepositories,
        onSubmitted: (newExtensionsRepositories) {
          if (newExtensionsRepositories.isEmpty) {
            return;
          }
          try {
            Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
              aniyomiExtensionsRepositories: newExtensionsRepositories.where((url) => _isValidRepoUrl(url)).toList(),
            );
            _updateUserInfo(updatedSettings);
          } catch (e, stackTrace) {
            logger.e("Error updating Aniyomi extensions URL $e", stackTrace: stackTrace);
            handleError("Error updating Aniyomi extensions URL", stackTrace: stackTrace);
          }
        },
      ),
    );
  }

  void openTachiyomiExtensionsDialog() {
    showWidgetDialogEffect(
      dialog: ExtensionsSettingsDialog(
        width: 600.w,
        height: 400.h,
        title: "Tachiyomi extensions repository URL",
        currentRepositoriesUrls: state.loggedUser.settings.tachiyomiExtensionsRepositories,
        onSubmitted: (newExtensionsRepositories) {
          if (newExtensionsRepositories.isEmpty) {
            return;
          }
          try {
            Settings updatedSettings = (state.loggedUser.settings as SettingsModel).copyWith(
              tachiyomiExtensionsRepositories: newExtensionsRepositories.where((url) => _isValidRepoUrl(url)).toList(),
            );
            _updateUserInfo(updatedSettings);
          } catch (e, stackTrace) {
            logger.e("Error updating Tachiyomi extensions URL $e", stackTrace: stackTrace);
            handleError("Error updating Tachiyomi extensions URL", stackTrace: stackTrace);
          }
        },
      ),
    );
  }

  void openColorPickerDialog(BuildContext context) {
    showWidgetDialogEffect(
      dialog: ThemeColorPickerDialog(
        initialColor: state.loggedUser.settings.themeColor,
        onConfirmed: (color) => _themeService.updateThemeFromColors(
          loggedUser: state.loggedUser,
          primary: color,
          useWallpaperAsThemeColor: false,
        ),
      ),
    );
  }

  Future<void> _updateUserInfo(Settings settings) async {
    try {
      switch (state.loggedUser) {
        case AnilistUserModel anilistUserModel:
          AnilistUserModel updatedAnilistUserModel = anilistUserModel.copyWith(settings: settings);
          await _userRepository.updateUserInfo(updatedAnilistUserModel);
          break;
        case ShikimoriUserModel shikimoriUserModel:
          ShikimoriUserModel updatedShikimoriUserModel = shikimoriUserModel.copyWith(settings: settings);
          await _userRepository.updateUserInfo(updatedShikimoriUserModel);
          break;
        case LocalUserModel localUserModel:
          LocalUserModel updatedLocalUserModel = localUserModel.copyWith(settings: settings);
          await _userRepositoryLocal.updateUserInfo(updatedLocalUserModel);
          break;
      }
    } catch (e, stackTrace) {
      logger.e("Error updating user info $e", stackTrace: stackTrace);
      handleError("Error updating user info", stackTrace: stackTrace);
    }
  }

  bool _isValidRepoUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    // Structural rules
    if (!uri.isAbsolute) return false;
    if (uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    if (!url.toLowerCase().endsWith('.json')) return false;

    return true;
  }
}
