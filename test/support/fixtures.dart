// Internal dependencies
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/domain/entities/media/airing_episode.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/media/title.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// Small entity builders so a test states only the fields it cares about.
class Fixtures {
  static Title title(String value) => TitleModel(
    romaji: value,
    english: value,
    nativeTitle: value,
    userPreferred: value,
  );

  static Anime anime({
    int id = 1,
    String titleText = 'Anime',
    String bannerImage = '',
    String coverImage = '',
    int duration = 24,
  }) => AnimeModel(
    id: id,
    idMal: id,
    title: title(titleText),
    averageScore: 0,
    bannerImage: bannerImage,
    countryOfOrigin: '',
    coverImage: coverImage,
    description: '',
    duration: duration,
    endDate: '',
    startDate: '',
    episodes: 0,
    genres: const <String>[],
    format: '',
    isAdult: false,
    popularity: 0,
    meanScore: 0,
    season: '',
    isFavourite: false,
    status: '',
    nextAiringEpisode: AiringEpisodeModel.empty(),
  );

  static Manga manga({
    int id = 1,
    String titleText = 'Manga',
    String bannerImage = '',
    int chapters = 0,
  }) => MangaModel(
    id: id,
    idMal: id,
    title: title(titleText),
    averageScore: 0,
    bannerImage: bannerImage,
    chapters: chapters,
    countryOfOrigin: '',
    coverImage: '',
    description: '',
    endDate: '',
    startDate: '',
    genres: const <String>[],
    format: '',
    isAdult: false,
    popularity: 0,
    meanScore: 0,
    isFavourite: false,
    status: '',
  );

  static LocalUserModel localUser({
    String id = '1',
    String name = 'alice',
    Settings? settings,
  }) => LocalUserModel(
    id: id,
    name: name,
    settings: settings ?? SettingsModel.empty(),
    avatarImage: '',
    bannerImage: '',
  );

  static AnilistUserModel anilistUser({
    String id = '2',
    String name = 'bob',
    Settings? settings,
    String accessToken = '',
    String accessCode = '',
  }) => AnilistUserModel(
    id: id,
    name: name,
    settings: settings ?? SettingsModel.empty(),
    avatarImage: '',
    bannerImage: '',
    accessCode: accessCode,
    accessToken: accessToken,
    refreshToken: '',
  );

  static UserModel emptyUser() => UserModel.empty();
}
