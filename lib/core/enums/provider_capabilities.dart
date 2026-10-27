import 'package:unyo/core/enums/service.dart';

/// Single place that states which [Service] values are wired up for each role.
///
/// v1: AniList is the only provider that owns accounts/lists, while details can
/// come from AniList or Shikimori. Extend these lists (do not add ad-hoc checks
/// in the UI) when MAL/Kitsu/Simkl user repositories land.
const List<Service> kUserProviders = [Service.anilist];

const List<Service> kMetadataProviders = [Service.anilist, Service.shikimori];

/// True when [service] can currently be used as the `userService`.
bool isUserProvider(Service service) => kUserProviders.contains(service);

/// True when [service] can currently be used as the `metadataService`.
bool isMetadataProvider(Service service) => kMetadataProviders.contains(service);
