import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/extensions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/extension_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/http/http_exception.dart';
import 'package:unyo/domain/entities/extension/extension.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/extension_repository.dart';
import 'package:unyo/presentation/dialogs/extension_preferences_dialog.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

class ExtensionsCubit extends Cubit<ExtensionsState> with EffectMixin<ExtensionsState> {
  final Logger _logger = sl<Logger>();

  // Repositories
  final ExtensionRepository _extensionRepositoryAniyomi;

  // Notifiers
  final UserNotifier _loggedUserNotifier;
  late StreamSubscription<User> _loggedUserSubscription;

  ExtensionsCubit(this._extensionRepositoryAniyomi, this._loggedUserNotifier)
    : super(
        ExtensionsState(
          loggedUser: UserModel.empty(),
          installedAnimeExtensions: [],
          installedMangaExtensions: [],
          availableAnimeExtensions: [],
          availableMangaExtensions: [],
          userLoaded: false,
          extensionsLoaded: false,
        ),
      ) {
    _init();
  }

  @override
  ExtensionsState copyStateWithEffects(ExtensionsState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    return super.close();
  }

  void _init() {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((loggedUser) {
      emit(state.copyWith(loggedUser: loggedUser));
      if (!state.userLoaded) {
        _loadExtensions(loggedUser);
      }
    });
  }

  /// Fetches every extension list, then flips [ExtensionsState.extensionsLoaded]
  /// so the screen swaps its skeletons for the real rows. Each `_fetch*` keeps
  /// its own error handling, so a failing endpoint still settles the flag.
  Future<void> _loadExtensions(User loggedUser) async {
    emit(state.copyWith(userLoaded: true));
    await Future.wait([
      _fetchAvailableAnimeExtensions(loggedUser),
      _fetchAvailableMangaExtensions(loggedUser),
      _fetchInstaledAnimeExtensions(loggedUser),
      _fetchInstaledMangaExtensions(loggedUser),
      _fetchAnimeExtensionUpdates(loggedUser),
      _fetchMangaExtensionUpdates(loggedUser),
    ]);
    if (isClosed) return;
    emit(state.copyWith(extensionsLoaded: true));
  }

  Future<void> downloadExtension(Extension extension) async {
    if (state.installedAnimeExtensions.contains(extension) ||
        state.installedMangaExtensions.contains(extension)) {
      handleError(
        "This version of ${extension.name} is already installed.",
        copyKey: 'ext_already_installed',
        copyArgs: <String, String>{'name': extension.name},
      );
      return;
    }
    try {
      await _extensionRepositoryAniyomi.addExtension(extension);
      if (extension.type == ExtensionType.ANIYOMI) {
        _fetchInstaledAnimeExtensions(state.loggedUser);
        _fetchAvailableAnimeExtensions(state.loggedUser);
        _fetchAnimeExtensionUpdates(state.loggedUser);
      } else {
        _fetchInstaledMangaExtensions(state.loggedUser);
        _fetchAvailableMangaExtensions(state.loggedUser);
        _fetchMangaExtensionUpdates(state.loggedUser);
      }
      showSnackBarEffect(
        'ext_installed_title',
        titleArgs: <String, String>{'name': extension.name},
        messageKey: 'ext_installed_message',
        messageArgs: <String, String>{'name': extension.name},
        contentType: ContentType.success,
      );
    } catch (e, stackTrace) {
      if (extension.type == ExtensionType.ANIYOMI) {
        _fetchAvailableAnimeExtensions(state.loggedUser);
      } else {
        _fetchAvailableMangaExtensions(state.loggedUser);
      }
      handleError("Failed to download extension ${extension.pkg}: $e", stackTrace: stackTrace);
    }
  }

  Future<void> removeExtension(Extension extension) async {
    if (!state.installedAnimeExtensions.contains(extension) &&
        !state.installedMangaExtensions.contains(extension)) {
      handleError(
        "This version of ${extension.name} is already uninstalled.",
        copyKey: 'ext_already_uninstalled',
        copyArgs: <String, String>{'name': extension.name},
      );
      return;
    }
    try {
      await _extensionRepositoryAniyomi.removeExtension(extension);
      if (extension.type == ExtensionType.ANIYOMI) {
        _fetchInstaledAnimeExtensions(state.loggedUser);
        _fetchAvailableAnimeExtensions(state.loggedUser);
        _fetchAnimeExtensionUpdates(state.loggedUser);
      } else {
        _fetchInstaledMangaExtensions(state.loggedUser);
        _fetchAvailableMangaExtensions(state.loggedUser);
        _fetchMangaExtensionUpdates(state.loggedUser);
      }
      showSnackBarEffect(
        'ext_removed_title',
        titleArgs: <String, String>{'name': extension.name},
        messageKey: 'ext_removed_message',
        messageArgs: <String, String>{'name': extension.name},
        contentType: ContentType.success,
      );
    } catch (e, stackTrace) {
      if (extension.type == ExtensionType.ANIYOMI) {
        _fetchInstaledAnimeExtensions(state.loggedUser);
      } else {
        _fetchInstaledMangaExtensions(state.loggedUser);
      }
      handleError("Failed to remove extension ${extension.pkg}: $e", stackTrace: stackTrace);
    }
  }

  Future<void> updateExtension(Extension installedExtension) async {
    final Extension? newExtension = installedExtension.type == ExtensionType.ANIYOMI
        ? state.animeExtensionUpdates[installedExtension.pkg]
        : state.mangaExtensionUpdates[installedExtension.pkg];

    if (newExtension == null) {
      handleError(
        "No update available for ${installedExtension.name}.",
        copyKey: 'ext_no_update_available',
        copyArgs: <String, String>{'name': installedExtension.name},
      );
      return;
    }

    try {
      await _extensionRepositoryAniyomi.updateExtension(installedExtension, newExtension);
      if (installedExtension.type == ExtensionType.ANIYOMI) {
        _fetchInstaledAnimeExtensions(state.loggedUser);
        _fetchAvailableAnimeExtensions(state.loggedUser);
        _fetchAnimeExtensionUpdates(state.loggedUser);
      } else {
        _fetchInstaledMangaExtensions(state.loggedUser);
        _fetchAvailableMangaExtensions(state.loggedUser);
        _fetchMangaExtensionUpdates(state.loggedUser);
      }
      showSnackBarEffect(
        'ext_updated_title',
        titleArgs: <String, String>{'name': installedExtension.name},
        messageKey: 'ext_updated_message',
        messageArgs: <String, String>{'version': newExtension.version},
        contentType: ContentType.success,
      );
    } catch (e, stackTrace) {
      handleError("Failed to update extension ${installedExtension.pkg}: $e", stackTrace: stackTrace);
    }
  }

  Future<void> openExtensionPreferences(Extension extension) async {
    try {
      _logger.i("Fetching preferences for ${extension.name}");
      final preferences = await _extensionRepositoryAniyomi.getExtensionPreferences(extension.pkg);
      showWidgetDialogEffect(
        dialog: ExtensionPreferencesDialog(
          pkg: extension.pkg,
          preferences: preferences,
          onSave: (values) => _saveExtensionPreferences(extension.pkg, values),
        ),
      );
    } catch (e, stackTrace) {
      handleError("Failed to load preferences for ${extension.name}: $e", stackTrace: stackTrace);
    }
  }

  Future<void> _saveExtensionPreferences(String pkg, Map<String, dynamic> values) async {
    try {
      await _extensionRepositoryAniyomi.setExtensionPreferences(pkg, values);
      showSnackBarEffect(
        'ext_preferences_saved_title',
        messageKey: 'ext_preferences_saved_message',
        contentType: ContentType.success,
      );
    } catch (e, stackTrace) {
      handleError("Failed to save extension preferences: $e", stackTrace: stackTrace);
    }
  }

  Set<String> getAvailableRepositories() {
    return state.loggedUser.settings.aniyomiExtensionsRepositories
        .map((e) => TextUtils.extractRepoName(e))
        .toSet()
        .union(
          state.loggedUser.settings.tachiyomiExtensionsRepositories
              .map((e) => TextUtils.extractRepoName(e))
              .toSet(),
        );
  }

  Future<void> _fetchAvailableAnimeExtensions(User loggedUser) async {
    try {
      _logger.i("Fetching available anime extensions for Aniyomi");
      Set<Extension> availableAniyomiExtensions = await _extensionRepositoryAniyomi
          .getAvailableAnimeExtensions(loggedUser);
      emit(state.copyWith(availableAnimeExtensions: availableAniyomiExtensions.toList()));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch available anime extensions:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError("Failed to fetch available anime extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchAvailableMangaExtensions(User loggedUser) async {
    try {
      _logger.i("Fetching available manga extensions for Aniyomi");
      Set<Extension> availableTachiyomiExtensions = await _extensionRepositoryAniyomi
          .getAvailableMangaExtensions(loggedUser);
      emit(state.copyWith(availableMangaExtensions: availableTachiyomiExtensions.toList()));
    } on HttpServerException catch (e, stackTrace) {
      handleError(
        "Failed to fetch available manga extensions:",
        responseBody: e.message,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      handleError("Failed to fetch available manga extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchInstaledAnimeExtensions(User loggedUser) async {
    try {
      _logger.i("Fetching installed anime extensions for Aniyomi");
      Set<Extension> installedAniyomiExtensions = await _extensionRepositoryAniyomi
          .getInstalledAnimeExtensions(loggedUser);
      emit(state.copyWith(installedAnimeExtensions: installedAniyomiExtensions.toList()));
    } catch (e, stackTrace) {
      handleError("Failed to fetch installed anime extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchInstaledMangaExtensions(User loggedUser) async {
    try {
      _logger.i("Fetching installed manga extensions for Aniyomi");
      Set<Extension> installedTachiyomiExtensions = await _extensionRepositoryAniyomi
          .getInstalledMangaExtensions(loggedUser);
      emit(state.copyWith(installedMangaExtensions: installedTachiyomiExtensions.toList()));
    } catch (e, stackTrace) {
      handleError("Failed to fetch installed manga extensions $e", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchAnimeExtensionUpdates(User loggedUser) async {
    try {
      _logger.i("Fetching anime extension updates");
      final updates = await _extensionRepositoryAniyomi.getAnimeExtensionUpdates(loggedUser);
      emit(state.copyWith(animeExtensionUpdates: updates));
    } catch (e, stackTrace) {
      _logger.w("Failed to fetch anime extension updates", stackTrace: stackTrace);
    }
  }

  Future<void> _fetchMangaExtensionUpdates(User loggedUser) async {
    try {
      _logger.i("Fetching manga extension updates");
      final updates = await _extensionRepositoryAniyomi.getMangaExtensionUpdates(loggedUser);
      emit(state.copyWith(mangaExtensionUpdates: updates));
    } catch (e, stackTrace) {
      _logger.w("Failed to fetch manga extension updates", stackTrace: stackTrace);
    }
  }
}
