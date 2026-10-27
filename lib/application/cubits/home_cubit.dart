// Dart dependencies
import 'dart:async';

// External dependencies
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/states/home_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/selected_menu_option.dart';

import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/menu_bar_notifier.dart';
import 'package:unyo/core/notification/reload/reload_notifier.dart';
import 'package:unyo/core/notification/reload/reload_type.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/repositories/anime_repository.dart';
import 'package:unyo/domain/repositories/user_repository.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';

class HomeCubit extends Cubit<HomeState> with EffectMixin<HomeState> {
  // Repositories
  final UserRepository _userRepository;
  final AnimeRepository _animeRepository;
  // Notifiers / Subscriptions
  final UserNotifier _loggedUserNotifier;
  final MenuBarNotifier _menuBarNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final MangaNotifier _selectedMangaNotifier;
  final MediaListNotifier _selectedMediaListNotifier;
  final ReloadNotifier _reloadNotifier;
  late StreamSubscription<User> _newLoggedUserSubscription;
  late StreamSubscription<ReloadType> _reloadSubscription;
  final Logger _logger = sl<Logger>();

  HomeCubit(
    this._loggedUserNotifier,
    this._selectedAnimeNotifier,
    this._selectedMangaNotifier,
    this._selectedMediaListNotifier,
    this._userRepository,
    this._animeRepository,
    this._menuBarNotifier,
    this._reloadNotifier,
  ) : super(
        HomeState(
          loggedUser: UserModel.empty(),
          selectedMenuOption: SelectedMenuOption.home,
          continueWatching: [],
          continueReading: [],
          mediaCoverImages: [],
          isLoading: true,
          userLoaded: false,
        ),
      ) {
    _init();
  }

  @override
  HomeState copyStateWithEffects(HomeState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  @override
  Future<void> close() {
    _newLoggedUserSubscription.cancel();
    _reloadSubscription.cancel();
    return super.close();
  }

  void _init() {
    _newLoggedUserSubscription = _loggedUserNotifier.userStream.listen((
      loggedUser,
    ) async {
      emit(
        state.copyWith(loggedUser: loggedUser),
      );
      if (!state.userLoaded) {
        await _getUserInfo(loggedUser);
        await _getMediaCoverImages(loggedUser);
        _menuBarNotifier.showMenuBar(true);
        emit(state.copyWith(userLoaded: true, isLoading: false));
      }
    });
    _reloadSubscription = _reloadNotifier.reloadStream.listen((reloadType) async {
      if (reloadType == ReloadType.newMetadataService) {
        _logger.i("Reloading Home Screen data due to new metadata service");
        await _getMediaCoverImages(state.loggedUser, ignoreCache: true);
      }
      if (reloadType == ReloadType.homeMediaListEntryUpdated) {
        _logger.i("Reloading Home Screen data due to media list entry update");
        await _getUserInfo(state.loggedUser, ignoreCacheAnime: true);
      }
    });
  }

  void selectMenuOption(SelectedMenuOption option) {
    emit(state.copyWith(selectedMenuOption: option));
  }

  void navigateToAnimeDetails(Anime anime, MediaList mediaList) {
    _logger.i("Navigating to Anime Details of ${anime.title.userPreferred}");
    _selectedAnimeNotifier.updateSelectedAnime(anime);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    pushRouteEffect(path: "/animedetails");
  }

  void navigateToMangaDetails(Manga manga, MediaList mediaList) {
    _logger.i("Navigating to Manga Details of ${manga.title.userPreferred}");
    _selectedMangaNotifier.updateSelectedManga(manga);
    _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
    pushRouteEffect(path: "/mangadetails");
  }

  void navigateToUserAnimeList(BuildContext context) {
    _logger.i("Navigating to User Anime List");
    pushRouteEffect(path: "/userlist?type=anime");
  }

  void navigateToUserMangaList(BuildContext context) {
    _logger.i("Navigating to User Manga List");
    pushRouteEffect(path: "/userlist?type=manga");
  }

  Future<void> _getUserInfo(User user, {bool ignoreCacheAnime = false, bool ignoreCacheManga = false}) async {
    try {
      switch (user) {
        case AnilistUserModel anilistUserModel:
          _logger.i("Fetching Anilist User lists");
          List<Anime> watchingList = await _userRepository
              .getUserWatchingList(anilistUserModel, ignoreCache: ignoreCacheAnime);
          List<Manga> readingList = await _userRepository
              .getUserReadingList(anilistUserModel, ignoreCache: ignoreCacheManga);
          emit(
            state.copyWith(
              continueWatching: watchingList,
              continueReading: readingList,
            ),
          );
        case LocalUserModel localUserModel:
      }
    } catch (e, stackTrace) {
      handleError("Error fetching user info: $e", stackTrace: stackTrace);
      replaceRouteEffect(path: "/login");
    }
  }

  Future<void> _getMediaCoverImages(User loggedUser, {bool ignoreCache = false}) async {
    try {
      _logger.i("Fetching Media Cover Images");
      List<String> mediaCoverImages = await _animeRepository.getMediaCoverImages(loggedUser, ignoreCache: ignoreCache);
      emit(state.copyWith(mediaCoverImages: mediaCoverImages));
    } catch (e, stackTrace) {
      handleError("Error fetching media cover images: $e", stackTrace: stackTrace);
    }
  }

}
