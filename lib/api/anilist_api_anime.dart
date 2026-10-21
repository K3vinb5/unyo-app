import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:unyo/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:unyo/util/constants.dart';
import 'package:url_launcher/url_launcher.dart';

const String anilistEndPointGetToken =
    "https://anilist.co/api/v2/oauth/authorize?client_id=17550&response_type=token";
const int maxAttempts = 5;

Future<List<AnimeModel>> getAnimeModelListTrending(
    int page, int n, int attempt) async {
  Map<String, dynamic> query = {
    "query":
        "query(\$page:Int = 1 \$id:Int \$type:MediaType \$isAdult:Boolean = false \$search:String \$format:[MediaFormat] \$status:MediaStatus \$countryOfOrigin:CountryCode \$source:MediaSource \$season:MediaSeason \$seasonYear:Int \$year:String \$onList:Boolean \$yearLesser:FuzzyDateInt \$yearGreater:FuzzyDateInt \$episodeLesser:Int \$episodeGreater:Int \$durationLesser:Int \$durationGreater:Int \$chapterLesser:Int \$chapterGreater:Int \$volumeLesser:Int \$volumeGreater:Int \$licensedBy:[Int]\$isLicensed:Boolean \$genres:[String]\$excludedGenres:[String]\$tags:[String]\$excludedTags:[String]\$minimumTagRank:Int \$sort:[MediaSort]=[POPULARITY_DESC,SCORE_DESC]){Page(page:\$page,perPage:$n){pageInfo{total perPage currentPage lastPage hasNextPage}media(id:\$id type:\$type season:\$season format_in:\$format status:\$status countryOfOrigin:\$countryOfOrigin source:\$source search:\$search onList:\$onList seasonYear:\$seasonYear startDate_like:\$year startDate_lesser:\$yearLesser startDate_greater:\$yearGreater episodes_lesser:\$episodeLesser episodes_greater:\$episodeGreater duration_lesser:\$durationLesser duration_greater:\$durationGreater chapters_lesser:\$chapterLesser chapters_greater:\$chapterGreater volumes_lesser:\$volumeLesser volumes_greater:\$volumeGreater licensedById_in:\$licensedBy isLicensed:\$isLicensed genre_in:\$genres genre_not_in:\$excludedGenres tag_in:\$tags tag_not_in:\$excludedTags minimumTagRank:\$minimumTagRank sort:\$sort isAdult:\$isAdult){id idMal title{userPreferred english romaji}coverImage{extraLarge large color}startDate{year month day}endDate{year month day}bannerImage season seasonYear description type format status(version:2)episodes duration chapters volumes genres isAdult averageScore popularity nextAiringEpisode{airingAt timeUntilAiring episode}mediaListEntry{id status}studios(isMain:true){edges{isMain node{id name}}}}}}",
    "variables": {
      "page": page,
      "type": "ANIME",
      "sort": ["TRENDING_DESC", "POPULARITY_DESC"]
    }
  };
  var url = Uri.parse(anilistEndpoint);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("Trending list: $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return await getAnimeModelListRecentlyReleased(page, n, newAttempt);
    }
    return [];
  } else {
    List<dynamic> media = jsonDecode(response.body)["data"]["Page"]["media"];
    List<AnimeModel> list = [];
    for (int i = 0; i < n; i++) {
      Map<String, dynamic> json = media[i];
      list.add(AnimeModel.fromJson(json));
    }
    return list;
  }
}

Future<List<AnimeModel>> getAnimeModelListRecentlyReleased(
    int page, int n, int attempt) async {
  Map<String, dynamic> query = {
    "query":
        "query{ Page(page: $page, perPage: $n) { airingSchedules (sort: TIME_DESC, notYetAired: false) {episode media { id idMal title { userPreferred romaji english} coverImage { large } bannerImage format startDate { year month day } endDate { year month day } type description status averageScore episodes duration}}}}"
  };

  var url = Uri.parse(anilistEndpoint);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("Recently released: $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return await getAnimeModelListRecentlyReleased(page, n, newAttempt);
    }
    return [];
  } else {
    List<dynamic> media =
        jsonDecode(response.body)["data"]["Page"]["airingSchedules"];
    List<AnimeModel> list = [];
    for (int i = 0; i < media.length; i++) {
      var currentMedia = media[i]["media"];

      list.add(AnimeModel.fromJson(currentMedia));
    }
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length - 1; j++) {
        if (list[i].id == list[j].id) {
          list.removeAt(j);
        }
      }
    }
    return list;
  }
}

Future<List<AnimeModel>> getAnimeModelListSeasonPopular(
    int page, int n, int year, String season, int attempt) async {
  Map<String, dynamic> query = {
    "query":
        "query(\$page:Int = 1 \$id:Int \$type:MediaType \$isAdult:Boolean = false \$search:String \$format:[MediaFormat]\$status:MediaStatus \$countryOfOrigin:CountryCode \$source:MediaSource \$season:MediaSeason \$seasonYear:Int \$year:String \$onList:Boolean \$yearLesser:FuzzyDateInt \$yearGreater:FuzzyDateInt \$episodeLesser:Int \$episodeGreater:Int \$durationLesser:Int \$durationGreater:Int \$chapterLesser:Int \$chapterGreater:Int \$volumeLesser:Int \$volumeGreater:Int \$licensedBy:[Int]\$isLicensed:Boolean \$genres:[String]\$excludedGenres:[String]\$tags:[String]\$excludedTags:[String]\$minimumTagRank:Int \$sort:[MediaSort]=[POPULARITY_DESC,SCORE_DESC]){Page(page:\$page,perPage:$n){pageInfo{total perPage currentPage lastPage hasNextPage}media(id:\$id type:\$type season:\$season format_in:\$format status:\$status countryOfOrigin:\$countryOfOrigin source:\$source search:\$search onList:\$onList seasonYear:\$seasonYear startDate_like:\$year startDate_lesser:\$yearLesser startDate_greater:\$yearGreater episodes_lesser:\$episodeLesser episodes_greater:\$episodeGreater duration_lesser:\$durationLesser duration_greater:\$durationGreater chapters_lesser:\$chapterLesser chapters_greater:\$chapterGreater volumes_lesser:\$volumeLesser volumes_greater:\$volumeGreater licensedById_in:\$licensedBy isLicensed:\$isLicensed genre_in:\$genres genre_not_in:\$excludedGenres tag_in:\$tags tag_not_in:\$excludedTags minimumTagRank:\$minimumTagRank sort:\$sort isAdult:\$isAdult){id idMal title{userPreferred english romaji}coverImage{extraLarge large color}startDate{year month day}endDate{year month day}bannerImage season seasonYear description type format status(version:2)episodes duration chapters volumes genres isAdult averageScore popularity nextAiringEpisode{airingAt timeUntilAiring episode}mediaListEntry{id status}studios(isMain:true){edges{isMain node{id name}}}}}}",
    "variables": {
      "page": page,
      "type": "ANIME",
      "seasonYear": year,
      "season": season,
    }
  };

  var url = Uri.parse(anilistEndpoint);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("Season Popular: $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return await getAnimeModelListRecentlyReleased(page, n, newAttempt);
    }
    return [];
  } else {
    List<dynamic> media = jsonDecode(response.body)["data"]["Page"]["media"];
    List<AnimeModel> list = [];
    for (int i = 0; i < n; i++) {
      Map<String, dynamic> json = media[i];

      list.add(AnimeModel.fromJson(json));
    }
    return list;
  }
}

Future<List<AnimeModel>> getAnimeModelListSearch(
  String search,
  String genre,
  String sort,
  String season,
  String status,
  String format,
  String year,
  int n,
) async {
  String finalSearch = search.isNotEmpty ? "search:\"$search\"" : "";

  Map<String, dynamic> query = {
    "query":
        "query(\$page:Int = 1 \$id:Int \$type:MediaType \$isAdult:Boolean = false \$format:[MediaFormat] \$status:MediaStatus \$countryOfOrigin:CountryCode \$source:MediaSource \$season:MediaSeason \$seasonYear:Int \$year:String \$onList:Boolean \$yearLesser:FuzzyDateInt \$yearGreater:FuzzyDateInt \$episodeLesser:Int \$episodeGreater:Int \$durationLesser:Int \$durationGreater:Int \$chapterLesser:Int \$chapterGreater:Int \$volumeLesser:Int \$volumeGreater:Int \$licensedBy:[Int]\$isLicensed:Boolean \$genres:[String]\$excludedGenres:[String]\$tags:[String]\$excludedTags:[String]\$minimumTagRank:Int \$sort:[MediaSort]=[POPULARITY_DESC,SCORE_DESC]){Page(page:\$page,perPage:$n){pageInfo{total perPage currentPage lastPage hasNextPage}media(id:\$id type:\$type season:\$season format_in:\$format status:\$status countryOfOrigin:\$countryOfOrigin source:\$source $finalSearch onList:\$onList seasonYear:\$seasonYear startDate_like:\$year startDate_lesser:\$yearLesser startDate_greater:\$yearGreater episodes_lesser:\$episodeLesser episodes_greater:\$episodeGreater duration_lesser:\$durationLesser duration_greater:\$durationGreater chapters_lesser:\$chapterLesser chapters_greater:\$chapterGreater volumes_lesser:\$volumeLesser volumes_greater:\$volumeGreater licensedById_in:\$licensedBy isLicensed:\$isLicensed genre_in:\$genres genre_not_in:\$excludedGenres tag_in:\$tags tag_not_in:\$excludedTags minimumTagRank:\$minimumTagRank sort:\$sort isAdult:\$isAdult){id idMal title{userPreferred english romaji}coverImage{extraLarge large color}startDate{year month day}endDate{year month day}bannerImage season seasonYear description type format status(version:2)episodes duration chapters volumes genres isAdult averageScore popularity nextAiringEpisode{airingAt timeUntilAiring episode}mediaListEntry{id status}studios(isMain:true){edges{isMain node{id name}}}}}}",
    "variables": {
      "page": 1,
      "type": "ANIME",
      if (sort == "Select Sorting")
        "sort": "SEARCH_MATCH"
      else
        "sort": "${sort.toUpperCase()}_DESC",
      if (format != "Select Format")
        "format": [format.toUpperCase().replaceAll(' ', '_')],
      if (season != "Select Season") "season": season.toUpperCase(),
      if (year != "Select Year") "seasonYear": int.parse(year),
      if (genre != "Select Genre") "genres": [genre],
      if (status != "Select Status")
        "status": status.toUpperCase().replaceAll(' ', '_')
    }
  };
  var url = Uri.parse(anilistEndpoint);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    print("ERROR:\n${response.statusCode}\n${response.body}");
    return [];
  } else {
    List<dynamic> media = jsonDecode(response.body)["data"]["Page"]["media"];
    List<AnimeModel> list = [];
    for (int i = 0; i < media.length; i++) {
      Map<String, dynamic> json = media[i];
      list.add(AnimeModel.fromJson(json));
    }
    print(list.length);
    // if ((sort != "Select Sorting")) {
    // return list.reversed.toList();
    // }
    return list;
  }
}

Future<String> getRandomAnimeBanner(int attempt) async {
  var url = Uri.parse(anilistEndpoint);
  Map<String, dynamic> query = {
    "query":
        "query(\$page:Int, \$perPage:Int){ Page(page: \$page, perPage: \$perPage) { media(type: ANIME) { bannerImage } } }",
    "variables": {
      "perPage": 50,
      "page": Random().nextInt(395),
    }
  };
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  Map<String, dynamic> jsonResponse = json.decode(response.body);
  if (attempt < maxAttempts) {
    if (response.statusCode != 200) {
      await Future.delayed(const Duration(milliseconds: 200));
      print("Random anime banner: $attempt - failure");
      int newAttempt = attempt + 1;
      return getRandomAnimeBanner(newAttempt);
    }
    for (int i = 0; i < 50; i++) {
      if (jsonResponse["data"]["Page"]["media"][i]["bannerImage"] == null) {
        continue;
      } else {
        return jsonResponse["data"]["Page"]["media"][i]["bannerImage"];
      }
    }
    await Future.delayed(const Duration(milliseconds: 200));
    print("Random anime banner: $attempt - failure");
    int newAttempt = attempt + 1;
    return getRandomAnimeBanner(newAttempt);
  } else {
    return "";
  }
}

getUserToken() async {
  var url = Uri.parse(anilistEndPointGetToken);
  launchUrl(url, mode: LaunchMode.platformDefault);
}

String capitalize(String s) {
  return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
}

Future<Map<String, Map<String, double>>> getUserStatsMaps(
    {int? newAttempt}) async {
  Map<String, Map<String, double>> userStatsMaps = {};
  int attempt = newAttempt ?? 0;
  var url = Uri.parse(anilistEndpoint);
  Map<String, dynamic> query = {
    "query":
        "query(\$name:String){User(name:\$name){statistics{anime{episodesWatched minutesWatched formats{format\n\tcount\n\tmeanScore\n\tminutesWatched\n\tchaptersRead\n\tmediaIds\n}statuses{status\n\tcount\n\tmeanScore\n\tminutesWatched\n\tchaptersRead\n\tmediaIds\n}releaseYears{releaseYear\n\tcount\n\tmeanScore\n\tminutesWatched\n\tchaptersRead\n\tmediaIds\n}}}}}",
    "variables": {
      "name": userName,
    }
  };
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("User stats: $attempt - failure");
    print(response.body);
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return await getUserStatsMaps(newAttempt: newAttempt);
    }
    return {};
  }

  var animeStatistics =
      json.decode(response.body)["data"]["User"]["statistics"]["anime"];

  List<dynamic> formats = animeStatistics["formats"];
  List<dynamic> statuses = animeStatistics["statuses"];
  List<dynamic> releaseYears = animeStatistics["releaseYears"];

  Map<String, double> formatsMap = {};
  for (int i = 0; i < formats.length; i++) {
    formatsMap.addAll(
        {capitalize(formats[i]["format"]): formats[i]["count"].toDouble()});
  }
  userStatsMaps.addAll({"formats": formatsMap});

  Map<String, double> statusesMap = {};
  for (int i = 0; i < statuses.length; i++) {
    statusesMap.addAll(
        {capitalize(statuses[i]["status"]): statuses[i]["count"].toDouble()});
  }
  userStatsMaps.addAll({"statuses": statusesMap});

  Map<String, double> releaseYearsMap = {};
  for (int i = 0; i < releaseYears.length; i++) {
    releaseYearsMap.addAll({
      releaseYears[i]["releaseYear"].toString():
          releaseYears[i]["count"].toDouble()
    });
  }
  // userStatsMaps.addAll({"releaseYears": releaseYearsMap});
  Map<String, double> watchedStatisticsMap = {};
  watchedStatisticsMap.addAll(
      {"episodesWatched": animeStatistics["episodesWatched"].toDouble()});
  watchedStatisticsMap
      .addAll({"minutesWatched": animeStatistics["minutesWatched"].toDouble()});
  userStatsMaps.addAll({"watchedStatistics": watchedStatisticsMap});

  return userStatsMaps;
}

Future<List<String>> getUserAccessToken(String code, int attempt) async {
  var url = Uri.parse("https://anilist.co/api/v2/oauth/token");
  Map<String, dynamic> query = {
    "grant_type": "authorization_code",
    "client_id": 17550,
    "client_secret": "xI8KTZlKm2F3kHXLko1ArQ21bKap4MojgDTk6Ukx",
    "redirect_uri": "http://localhost:9999/auth", // http://example.com/callback
    "code": code,
  };
  var response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("User access token : $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return getUserAccessToken(code, newAttempt);
    }
  }
  print("Response: ${response.body}");
  Map<String, dynamic> jsonResponse = json.decode(response.body);

  return [jsonResponse["access_token"], jsonResponse["refresh_token"]];
}

Future<int> getAnimeCurrentEpisode(int mediaId, int attempt) async {
  var url = Uri.parse(anilistEndpoint);
  Map<String, dynamic> query = {
    "query":
        "query{ AiringSchedule(mediaId: $mediaId, sort: TIME_DESC, notYetAired: false){ episode } }",
  };
  var response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("anime current episode: $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return getAnimeCurrentEpisode(mediaId, newAttempt);
    }
  }
  Map<String, dynamic> jsonResponse = json.decode(response.body);
  return jsonResponse["data"]["AiringSchedule"]["episode"];
}

Future<Map<String, List<AnimeModel>>> getCalendar(
  String localeTag,
  Map<String, List<AnimeModel>> calendarListMap,
  int page,
  int airingAtGreater,
  int airingAtLesser,
  int attempt,
) async {
  var url = Uri.parse(anilistEndpoint);
  Map<String, dynamic> query = {
    "query":
        "query{Page(page: $page, perPage: 50) { pageInfo { hasNextPage total } airingSchedules(airingAt_greater: $airingAtGreater, airingAt_lesser: $airingAtLesser, sort: TIME_DESC) { episode airingAt media { id idMal status chapters episodes nextAiringEpisode { episode } isAdult type meanScore isFavourite format bannerImage startDate {day month year} endDate {day month year} countryOfOrigin coverImage { large } title { english romaji userPreferred } mediaListEntry { progress private score(format: POINT_100) status } } } }}",
  };
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(query),
  );
  if (response.statusCode != 200) {
    await Future.delayed(const Duration(milliseconds: 200));
    print("Calendar lists: $attempt - failure");
    if (attempt < maxAttempts) {
      int newAttempt = attempt + 1;
      return await getCalendar(localeTag, calendarListMap, page,
          airingAtGreater, airingAtLesser, newAttempt);
    }
    //NOTE empry Map
    return {};
  }
  Map<String, dynamic> jsonResponse = json.decode(response.body);
  List<dynamic> mediaList = jsonResponse["data"]["Page"]["airingSchedules"];
  List<AnimeModel> animeModelList = [];

  for (int j = 0; j < mediaList.length; j++) {
    Map<String, dynamic> json = mediaList[j]["media"];
    animeModelList.add(AnimeModel.fromJson(json));
  }

  calendarListMap = formatCalendarListMap(
      localeTag, calendarListMap, animeModelList, mediaList);
  if (jsonResponse["data"]["Page"]["pageInfo"]["hasNextPage"]) {
    int newPage = page + 1;
    return await getCalendar(localeTag, calendarListMap, newPage,
        airingAtGreater, airingAtLesser, attempt);
  } else {
    return Map.fromEntries(calendarListMap.entries.toList().reversed);
  }
}

Map<String, List<AnimeModel>> formatCalendarListMap(
    String locale,
    Map<String, List<AnimeModel>> calendarListMap,
    List<AnimeModel> animeModelList,
    List<dynamic> mediaList) {
  for (int i = 0; i < animeModelList.length; i++) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        mediaList[i]["airingAt"] * 1000,
        isUtc: true);
    DateFormat dateFormat = DateFormat('EEEE, MMMM d y', locale);
    String listKey = dateFormat.format(dateTime);
    String formattedListKey =
        "${listKey[0].toUpperCase()}${listKey.substring(1)}";
    if (!calendarListMap.containsKey(formattedListKey)) {
      calendarListMap.addAll({
        formattedListKey: [animeModelList[i]]
      });
    } else {
      calendarListMap[formattedListKey]!.add(animeModelList[i]);
    }
  }
  return calendarListMap;
}
