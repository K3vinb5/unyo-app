import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/presentation/widgets/styled/media_hero_art.dart';

/// WP #166: MAL/Jikan v4 ships no banner (`bannerImage: ''`), so every display
/// site resolves the same hero art instead of painting a blank banner slot.
void main() {
  group('AnimeHeroArt', () {
    test('no banner falls back to the cover', () {
      final anime = AnimeModel.empty().copyWith(
        bannerImage: '',
        coverImage: 'https://cdn.example.test/cover.jpg',
      );

      expect(anime.heroArt, 'https://cdn.example.test/cover.jpg');
    });

    test('a provider banner wins', () {
      final anime = AnimeModel.empty().copyWith(
        bannerImage: 'https://cdn.example.test/banner.jpg',
        coverImage: 'https://cdn.example.test/cover.jpg',
      );

      expect(anime.heroArt, 'https://cdn.example.test/banner.jpg');
    });

    test('neither art resolves to an empty string', () {
      final anime = AnimeModel.empty().copyWith(
        bannerImage: '',
        coverImage: '',
      );

      expect(anime.heroArt, '');
    });
  });

  group('MangaHeroArt', () {
    test('no banner falls back to the cover', () {
      final manga = MangaModel.empty().copyWith(
        bannerImage: '',
        coverImage: 'https://cdn.example.test/manga-cover.jpg',
      );

      expect(manga.heroArt, 'https://cdn.example.test/manga-cover.jpg');
    });

    test('a provider banner wins', () {
      final manga = MangaModel.empty().copyWith(
        bannerImage: 'https://cdn.example.test/manga-banner.jpg',
        coverImage: 'https://cdn.example.test/manga-cover.jpg',
      );

      expect(manga.heroArt, 'https://cdn.example.test/manga-banner.jpg');
    });

    test('neither art resolves to an empty string', () {
      final manga = MangaModel.empty().copyWith(
        bannerImage: '',
        coverImage: '',
      );

      expect(manga.heroArt, '');
    });
  });
}
