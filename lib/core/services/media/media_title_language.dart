import 'package:unyo/domain/entities/media/title.dart';

/// Resolves the title slot the user picked in
/// *Settings → Default Media Title Language* (`settings.mediaTitleLanguage`).
///
/// The setting stores the label a provider advertises through
/// `MediaService.titleLanguages` — `Romaji`, `English`, `Native`, `Russian`,
/// `UserPreferred` (Shikimori adds the Russian slot, WP #64 subpart (b)). The
/// match is case-insensitive so the Hive default `userPreferred` and the
/// capitalized dropdown labels both resolve.
///
/// Fallback: when the requested slot is empty (a Shikimori entry with no
/// Russian title, an AniList entry with no English title, …) the provider's
/// [Title.userPreferred] wins, and if that is empty too the first non-empty
/// slot in provider order. A card never renders blank because of a preference.
abstract final class MediaTitleLanguage {
  static String resolve(Title title, String language) {
    final String preferred = firstNonEmpty(<String>[
      title.userPreferred,
      title.romaji,
      title.english,
      title.nativeTitle,
      title.russian,
    ]);
    final String requested;
    switch (language.trim().toLowerCase()) {
      case 'romaji':
        requested = title.romaji;
      case 'english':
        requested = title.english;
      case 'native':
        requested = title.nativeTitle;
      case 'russian':
        requested = title.russian;
      default:
        // `userPreferred` and any value a provider does not advertise.
        return preferred;
    }
    return requested.trim().isEmpty ? preferred : requested;
  }

  /// First slot with visible text, or `''` when every slot is empty.
  static String firstNonEmpty(List<String> candidates) {
    for (final String candidate in candidates) {
      if (candidate.trim().isNotEmpty) return candidate;
    }
    return '';
  }
}
