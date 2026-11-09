import 'package:unyo/core/enums/service.dart';

class MediaServiceFactory {
  static MediaService getMediaService(Service service) {
    switch (service) {
      case Service.anilist:
        return AnilistMediaService();
      case Service.mal:
        return MyAnimeListMediaService();
      case Service.kitsu:
        return KitsuMediaService();
      case Service.shikimori:
        return ShikimoriMediaService();
      case Service.simkl:
        return SimklMediaService();
    }
  }

  static Service getEnumMediaService(String? serviceName) {
    switch (serviceName?.toLowerCase()) {
      case 'anilist':
        return Service.anilist;
      // The settings metadata picker lists `TextUtils.capitalize(service.name)`
      // and hands that string back, so `Mal` must resolve to the MAL provider
      // just like its brand name does.
      case 'mal':
      case 'myanimelist':
        return Service.mal;
      case 'kitsu':
        return Service.kitsu;
      case 'shikimori':
        return Service.shikimori;
      case 'simkl':
        return Service.simkl;
      default:
       return Service.anilist;
    }
  }
}

abstract class MediaService {
  Service get service;
  List<String> get titleLanguages;
}

class AnilistMediaService extends MediaService {

  @override
  Service get service => Service.anilist;

  @override
  List<String> get titleLanguages => ['Romaji', 'English', 'Native', 'UserPreferred'];

}

class MyAnimeListMediaService extends MediaService {

  @override
  Service get service => Service.mal;

  @override
  List<String> get titleLanguages => [];
}

class KitsuMediaService extends MediaService {

  @override
  Service get service => Service.kitsu;

  @override
  List<String> get titleLanguages => [];
}

class ShikimoriMediaService extends MediaService {

  @override
  Service get service => Service.shikimori;

  @override
  List<String> get titleLanguages => ['Romaji', 'English', 'Native', 'Russian'];
}

class SimklMediaService extends MediaService {

  @override
  Service get service => Service.simkl;

  @override
  List<String> get titleLanguages => [];
}