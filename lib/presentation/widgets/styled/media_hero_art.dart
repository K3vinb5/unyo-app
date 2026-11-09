import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';

/// The art a browse card shows as its hero: the provider banner when it has
/// one, else the card's cover.
///
/// MAL/Jikan v4 ships no banner asset at all (`MalAnimeModel.fromNode` sets
/// `bannerImage: ''`), so a banner-first display site left that provider with a
/// blank hero while the cover art sat unused on the same card (WP #166). The
/// models stay truthful — nothing is copied between the fields — and the choice
/// is made here at render time.
///
/// Display sites: `unyo_banner_carousel.dart` (the hero carousel pages) and the
/// Calendar / Advanced Search `MediaButton`s on the anime and manga browse
/// screens.
extension AnimeHeroArt on Anime {
  String get heroArt => bannerImage.isNotEmpty ? bannerImage : coverImage;
}

extension MangaHeroArt on Manga {
  String get heroArt => bannerImage.isNotEmpty ? bannerImage : coverImage;
}
