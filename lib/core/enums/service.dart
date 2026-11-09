import 'package:hive_ce/hive.dart';
import 'package:unyo/data/adapters/adapters_types.dart' as types;
import 'package:unyo/data/adapters/adapters_names.dart' as names;

part 'service.g.dart';

@HiveType(typeId: types.serviceAdapterType, adapterName: names.serviceEnumAdapterName)
enum Service {
  @HiveField(0) anilist,
  @HiveField(1) mal,
  @HiveField(2) kitsu,
  @HiveField(3) shikimori,
  @HiveField(4) simkl
}

/// Single place that states which [Service] values are wired up for each role.
///
/// AniList, Shikimori (WP #64 subpart (c)) and MyAnimeList (WP #156) own
/// accounts/lists, and all three now serve media details as well — MAL's
/// metadata reads landed in WP #166, so it joined [metadataProviders] there.
/// Extend these lists (do not add ad-hoc checks in the UI) when Kitsu/Simkl
/// user repositories land.
class ProviderCapabilities {
  const ProviderCapabilities._();

  static const List<Service> userProviders = [Service.anilist, Service.shikimori, Service.mal];

  static const List<Service> metadataProviders = [Service.anilist, Service.shikimori, Service.mal];

  /// True when [service] can currently be used as the `userService`.
  static bool isUser(Service service) => userProviders.contains(service);

  /// True when [service] can currently be used as the `metadataService`.
  static bool isMetadata(Service service) => metadataProviders.contains(service);
}