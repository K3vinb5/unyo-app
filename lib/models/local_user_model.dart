import 'package:unyo/models/models.dart';
import 'package:unyo/util/constants.dart';

class LocalUserModel implements UserModel {
  @override
  String? avatarImage;
  @override
  String? bannerImage;
  @override
  int? userId;
  @override
  String? userName;

  LocalUserModel(
      {this.avatarImage, this.bannerImage, this.userName, this.userId});

  @override
  void deleteUserAnime(int mediaId) {
    try {
      logger.i('Deleting user anime with mediaId: $mediaId');
      prefs.box.put(mediaId, null);
    } catch (e, s) {
      logger.e('Error deleting user anime: $e', error: e, stackTrace: s);
    }
  }

  @override
  void deleteUserManga(int mediaId) {
    try {
      logger.i('Deleting user manga with mediaId: $mediaId');
      prefs.box.put(mediaId, null);
    } catch (e, s) {
      logger.e('Error deleting user manga: $e', error: e, stackTrace: s);
    }
  }

  @override
  Future<Map<String, List<AnimeModel>>> getAllUserAnimeLists() async {
    logger.i('Fetching all user anime lists');
    try {
      return (prefs.box.get("allUserAnimeLists") as Map<dynamic, dynamic>?)?.map(
              (key, value) =>
                  MapEntry(key as String, (value as List).cast<AnimeModel>())) ??
          {};
    } catch (e, s) {
      logger.e('Error fetching all user anime lists: $e', error: e, stackTrace: s);
      return {};
    }
  }

  @override
  Future<Map<String, List<MangaModel>>> getAllUserMangaLists() async {
    logger.i('Fetching all user manga lists');
    try {
      return (prefs.box.get("allUserMangaLists") as Map<dynamic, dynamic>?)?.map(
              (key, value) =>
                  MapEntry(key as String, (value as List).cast<MangaModel>())) ??
          {};
    } catch (e, s) {
      logger.e('Error fetching all user manga lists: $e', error: e, stackTrace: s);
      return {};
    }
  }

  @override
  Future<UserMediaModel?> getUserAnimeInfo(int mediaId) async {
    logger.i('Fetching user anime info for mediaId: $mediaId');
    try {
      return prefs.box.get("userAnimeInfo-$mediaId") as UserMediaModel? ??
          UserMediaModel(
              score: 0,
              progress: 0,
              repeat: null,
              priority: null,
              status: "NOT SET",
              startDate: null,
              endDate: null);
    } catch (e, s) {
      logger.e('Error fetching user anime info: $e', error: e, stackTrace: s);
      return UserMediaModel(
          score: 0,
          progress: 0,
          repeat: null,
          priority: null,
          status: "NOT SET",
          startDate: null,
          endDate: null);
    }
  }

  @override
  Future<List<AnimeModel>> getUserAnimeLists(String listName) async {
    logger.i('Fetching user anime list: $listName');
    try {
      return (prefs.box.get("allUserAnimeLists")?[listName] as List<dynamic>?)
              ?.map((e) => e as AnimeModel)
              .toList() ??
          [];
    } catch (e, s) {
      logger.e('Error fetching user anime list: $e', error: e, stackTrace: s);
      return [];
    }
  }

  @override
  Future<String> getUserAvatarImageUrl() async {
    logger.i('Fetching user avatar image URL');
    try {
      avatarImage ??= "https://i.imgur.com/EKtChtm.png";
      return "https://i.imgur.com/EKtChtm.png";
    } catch (e, s) {
      logger.e('Error fetching user avatar image URL: $e', error: e, stackTrace: s);
      return "https://i.imgur.com/EKtChtm.png";
    }
  }

  @override
  Future<UserMediaModel?> getUserMangaInfo(int mediaId) async {
    logger.i('Fetching user manga info for mediaId: $mediaId');
    try {
      return prefs.box.get("userMangaInfo-$mediaId") as UserMediaModel? ??
          UserMediaModel(
              score: 0,
              progress: 0,
              repeat: null,
              priority: null,
              status: "NOT SET",
              startDate: null,
              endDate: null);
    } catch (e, s) {
      logger.e('Error fetching user manga info: $e', error: e, stackTrace: s);
      return UserMediaModel(
          score: 0,
          progress: 0,
          repeat: null,
          priority: null,
          status: "NOT SET",
          startDate: null,
          endDate: null);
    }
  }

  @override
  Future<List<MangaModel>> getUserMangaLists(String listName) async {
    logger.i('Fetching user manga list: $listName');
    try {
      return (prefs.box.get("allUserMangaLists")?[listName] as List<dynamic>?)
              ?.map((e) => e as MangaModel)
              .toList() ??
          [];
    } catch (e, s) {
      logger.e('Error fetching user manga list: $e', error: e, stackTrace: s);
      return [];
    }
  }

  @override
  Future<List<String>> getUserNameAndId() async {
    logger.i('Fetching user name and ID');
    try {
      if (userName != null && userId != null) {
        return [userName!, userId!.toString()];
      }
      userName = prefs.box.get("userName") as String?;
      userId = prefs.box.get("userId") as int?;
      return [prefs.box.get("userName") as String, ""];
    } catch (e, s) {
      logger.e('Error fetching user name and ID: $e', error: e, stackTrace: s);
      return ["", ""];
    }
  }

  @override
  Future<String> getUserbannerImageUrl() async {
    logger.i('Fetching user banner image URL');
    try {
      bannerImage ??= "https://i.imgur.com/x6TGK1x.png";
      return "https://i.imgur.com/x6TGK1x.png";
    } catch (e, s) {
      logger.e('Error fetching user banner image URL: $e', error: e, stackTrace: s);
      return "https://i.imgur.com/x6TGK1x.png";
    }
  }

  @override
  void setUserAnimeInfo(int mediaId, Map<String, String> receivedQuery,
      {AnimeModel? animeModel}) {
    logger.i('Setting user anime info for mediaId: $mediaId');
    try {
      UserMediaModel userMediaModel = UserMediaModel(
        score: double.parse(receivedQuery["score"]!),
        progress: int.parse(receivedQuery["progress"]!),
        repeat: null,
        priority: null,
        status: receivedQuery["status"],
        startDate:
            "${receivedQuery["startDateDay"]}/${receivedQuery["startDateMonth"]}/${receivedQuery["startDateYear"]}",
        endDate:
            "${receivedQuery["endDateDay"]}/${receivedQuery["endDateMonth"]}/${receivedQuery["endDateYear"]}",
      );
      prefs.box.put("userAnimeInfo-$mediaId", userMediaModel);
      Map<String, List<AnimeModel>>? userAnimeLists = (prefs.box
                  .get("allUserAnimeLists") as Map<dynamic, dynamic>?)
              ?.map((key, value) =>
                  MapEntry(key as String, (value as List).cast<AnimeModel>())) ??
          {};

      for (var animeModelList in userAnimeLists.values) {
        animeModelList.remove(animeModel);
      }

      switch (receivedQuery["status"]) {
        case "CURRENT":
          userAnimeLists["Watching"] ??= [];
          userAnimeLists["Watching"]!.add(animeModel!);
          break;
        case "COMPLETED":
          userAnimeLists["Completed"] ??= [];
          userAnimeLists["Completed"]!.add(animeModel!);
          break;
        case "PLANNING":
          userAnimeLists["Planning"] ??= [];
          userAnimeLists["Planning"]!.add(animeModel!);
          break;
        case "PAUSED":
          userAnimeLists["Paused"] ??= [];
          userAnimeLists["Paused"]!.add(animeModel!);
          break;
        case "DROPPED":
          userAnimeLists["Dropped"] ??= [];
          userAnimeLists["Dropped"]!.add(animeModel!);
          break;
        default:
      }

      prefs.box.put("allUserAnimeLists", userAnimeLists);
    } catch (e, s) {
      logger.e('Error setting user anime info: $e', error: e, stackTrace: s);
    }
  }

  @override
  void setUserMangaInfo(int mediaId, Map<String, String> receivedQuery,
      {MangaModel? mangaModel}) {
    logger.i('Setting user manga info for mediaId: $mediaId');
    try {
      UserMediaModel userMediaModel = UserMediaModel(
        score: double.parse(receivedQuery["score"]!),
        progress: int.parse(receivedQuery["progress"]!),
        repeat: null,
        priority: null,
        status: receivedQuery["status"],
        startDate:
            "${receivedQuery["startDateDay"]}/${receivedQuery["startDateMonth"]}/${receivedQuery["startDateYear"]}",
        endDate:
            "${receivedQuery["endDateDay"]}/${receivedQuery["endDateMonth"]}/${receivedQuery["endDateYear"]}",
      );
      prefs.box.put("userMangaInfo-$mediaId", userMediaModel);
      Map<String, List<MangaModel>>? userMangaLists = (prefs.box
                  .get("allUserMangaLists") as Map<dynamic, dynamic>?)
              ?.map((key, value) =>
                  MapEntry(key as String, (value as List).cast<MangaModel>())) ??
          {};

      for (var mangaModelList in userMangaLists.values) {
        mangaModelList.remove(mangaModel!);
      }

      switch (receivedQuery["status"]) {
        case "CURRENT":
          userMangaLists["Reading"] ??= [];
          userMangaLists["Reading"]!.add(mangaModel!);
          break;
        case "COMPLETED":
          userMangaLists["Completed"] ??= [];
          userMangaLists["Completed"]!.add(mangaModel!);
          break;
        case "PLANNING":
          userMangaLists["Planning"] ??= [];
          userMangaLists["Planning"]!.add(mangaModel!);
          break;
        case "PAUSED":
          userMangaLists["Paused"] ??= [];
          userMangaLists["Paused"]!.add(mangaModel!);
          break;
        case "DROPPED":
          userMangaLists["Dropped"] ??= [];
          userMangaLists["Dropped"]!.add(mangaModel!);
          break;
        default:
      }

      prefs.box.put("allUserMangaLists", userMangaLists);
    } catch (e, s) {
      logger.e('Error setting user manga info: $e', error: e, stackTrace: s);
    }
  }
}
