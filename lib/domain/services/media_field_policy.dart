/// Data that a details/list widget can render, named by its owner (WP #61
/// decision 3). Widgets and cubits ask this table instead of testing the
/// service setting themselves.
enum MediaField {
  // Identity + list state: always the user provider.
  identity,
  avatarImage,
  displayName,
  customLists,
  listStatus,
  progress,
  score,
  startedAt,
  completedAt,

  // List cards keep rendering from the user provider's own entry.
  listCardTitle,
  listCardCoverImage,
  listCardStatusBadge,

  // Presentation details: the metadata provider once the record is linked.
  synopsis,
  coverImage,
  bannerImage,
  genres,
  format,
  episodeCount,
  meanScore,
  alternativeTitles,
}

enum MediaFieldOwner { userProvider, metadataProvider }

/// Explicit, unit-testable field-ownership table.
///
/// - user provider: identity, lists, progress, score, dates, custom lists,
///   avatar/name, and every list-card field;
/// - metadata provider: synopsis, cover/banner, genres, format, episode count,
///   mean score, alternative titles — **only while the record is linked**;
/// - unresolved mapping: the metadata-owned fields fall back to the user
///   provider's own details (rule 5 — never an empty details screen).
class MediaFieldPolicy {
  const MediaFieldPolicy._();

  static const Set<MediaField> userOwnedFields = <MediaField>{
    MediaField.identity,
    MediaField.avatarImage,
    MediaField.displayName,
    MediaField.customLists,
    MediaField.listStatus,
    MediaField.progress,
    MediaField.score,
    MediaField.startedAt,
    MediaField.completedAt,
    MediaField.listCardTitle,
    MediaField.listCardCoverImage,
    MediaField.listCardStatusBadge,
  };

  static const Set<MediaField> metadataOwnedFields = <MediaField>{
    MediaField.synopsis,
    MediaField.coverImage,
    MediaField.bannerImage,
    MediaField.genres,
    MediaField.format,
    MediaField.episodeCount,
    MediaField.meanScore,
    MediaField.alternativeTitles,
  };

  /// Who renders [field] right now. [mappingResolved] is false when the entry
  /// is `unresolved` (or has no pivot yet), which flips every metadata-owned
  /// field over to the user-provider fallback.
  static MediaFieldOwner ownerOf(MediaField field, {required bool mappingResolved}) {
    if (userOwnedFields.contains(field)) return MediaFieldOwner.userProvider;
    return mappingResolved ? MediaFieldOwner.metadataProvider : MediaFieldOwner.userProvider;
  }

  /// True when the value must be read from the metadata repository.
  static bool readsFromMetadata(MediaField field, {required bool mappingResolved}) =>
      ownerOf(field, mappingResolved: mappingResolved) == MediaFieldOwner.metadataProvider;

  /// True when the value must be written to (and read back from) the user
  /// provider — writes never go to the metadata provider.
  static bool isUserOwned(MediaField field) => userOwnedFields.contains(field);
}
