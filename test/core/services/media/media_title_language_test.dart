// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_service.dart';
import 'package:unyo/core/services/media/media_title_language.dart';
import 'package:unyo/domain/entities/media/title.dart';

/// The media title language preference (`settings.mediaTitleLanguage`) stores
/// the label a provider advertises via `MediaService.titleLanguages`. Shikimori
/// is the only provider that offers `Russian`, and WP #64 subpart (b) added the
/// matching [Title.russian] slot — selected by the preference, never by a
/// Shikimori-only branch at a call site.
void main() {
  const Title shikimoriTitle = TitleModel(
    romaji: 'Shingeki no Kyojin',
    english: 'Attack on Titan',
    nativeTitle: '進撃の巨人',
    userPreferred: 'Shingeki no Kyojin',
    russian: 'Атака титанов',
  );

  group('MediaTitleLanguage.resolve', () {
    test('Russian resolves the new slot', () {
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'Russian'), 'Атака титанов');
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'russian'), 'Атака титанов');
    });

    test('every advertised label resolves its own slot', () {
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'Romaji'), 'Shingeki no Kyojin');
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'English'), 'Attack on Titan');
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'Native'), '進撃の巨人');
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'UserPreferred'), 'Shingeki no Kyojin');
    });

    test('the Hive default value userPreferred resolves without a slot lookup', () {
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'userPreferred'), 'Shingeki no Kyojin');
    });

    test('an empty slot falls back to the preferred title, never to an empty card', () {
      const Title noRussian = TitleModel(
        romaji: 'Berserk',
        english: '',
        nativeTitle: '',
        userPreferred: 'Berserk',
      );

      expect(MediaTitleLanguage.resolve(noRussian, 'Russian'), 'Berserk');
      expect(MediaTitleLanguage.resolve(noRussian, 'Native'), 'Berserk');
    });

    test('an unknown language degrades to userPreferred', () {
      expect(MediaTitleLanguage.resolve(shikimoriTitle, 'klingon'), 'Shingeki no Kyojin');
    });

    test('a title with only a Russian slot still renders when another slot is requested', () {
      const Title russianOnly = TitleModel(
        romaji: '',
        english: '',
        nativeTitle: '',
        userPreferred: 'Атака титанов',
        russian: 'Атака титанов',
      );

      expect(MediaTitleLanguage.resolve(russianOnly, 'Romaji'), 'Атака титанов');
    });
  });

  group('ShikimoriMediaService', () {
    test('advertises the Russian slot the entity now carries', () {
      final MediaService service = MediaServiceFactory.getMediaService(Service.shikimori);

      expect(service.titleLanguages, contains('Russian'));
      expect(MediaTitleLanguage.resolve(shikimoriTitle, service.titleLanguages.last), 'Атака титанов');
    });
  });
}
