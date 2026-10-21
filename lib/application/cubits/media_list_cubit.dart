import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/media_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/notification/anime_notifier.dart';
import 'package:unyo/core/notification/manga_notifier.dart';
import 'package:unyo/core/notification/media_list_notifier.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/domain/entities/user/user.dart';

class MediaListCubit extends Cubit<MediaListState>
    with EffectMixin<MediaListState> {
  final Logger _logger = sl<Logger>();
  final UserRepositoryAnilist _userRepositoryAnilist;
  final UserNotifier _loggedUserNotifier;
  final AnimeNotifier _selectedAnimeNotifier;
  final MangaNotifier _selectedMangaNotifier;
  final MediaListNotifier _selectedMediaListNotifier;
  late StreamSubscription<User> _loggedUserSubscription;

  MediaListCubit(this._loggedUserNotifier, this._userRepositoryAnilist, this._selectedAnimeNotifier, this._selectedMangaNotifier, this._selectedMediaListNotifier)
    : super(
        MediaListState(
          userAnimeLists: {},
          userMangaLists: {},
          loggedUser: UserModel.empty(),
        ),
      ) {
    _init();
  }

  @override
  MediaListState copyStateWithEffects(
    MediaListState state,
    List<AppEffect> effects,
  ) {
    return state.copyWith(effects: effects);
  }

  @override
  Logger get logger => _logger;

  @override
  Future<void> close() {
    _loggedUserSubscription.cancel();
    return super.close();
  }

  void _init() async {
    _loggedUserSubscription = _loggedUserNotifier.userStream.listen((
      loggedUser,
    ) {
      emit(state.copyWith(loggedUser: loggedUser));
      _getUserLists(loggedUser);
    });
  }

  void navigateToMediaDetails(Object media, MediaList mediaList) {
    switch (media) {
      case Anime anime:
        _logger.i("Navigating to Anime Details of ${anime.title.userPreferred}");
        _selectedAnimeNotifier.updateSelectedAnime(anime);
        _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
        pushRouteEffect(path: "/animedetails");
      case Manga manga:
        _logger.i("Navigating to Manga Details of ${manga.title.userPreferred}");
        _selectedMangaNotifier.updateSelectedManga(manga);
        _selectedMediaListNotifier.updateSelectedMediaList(mediaList);
        pushRouteEffect(path: "/mangadetails");
    }
  }

  void popScreen(BuildContext context) {
    popRouteEffect(context);
    // close();
  }

  Future<void> _getUserLists(User user) async {
    try {
      switch (user) {
        case AnilistUserModel anilistUserModel:
          _logger.i("Fetching Anilist User lists");
          Map<String, List<Anime>> userAnimeLists = await _userRepositoryAnilist
              .getUserAnimeLists(user);
          Map<String, List<Manga>> userMangaLists = await _userRepositoryAnilist
              .getUserMangaLists(user);
          emit(
            state.copyWith(
              userAnimeLists: userAnimeLists,
              userMangaLists: userMangaLists,
            ),
          );
        case LocalUserModel localUserModel:
      }
    } catch (e, stackTrace) {
      handleError("Error fetching user info: $e", stackTrace: stackTrace);
    }
  }
}
