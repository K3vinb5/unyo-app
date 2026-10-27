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
/// v1: AniList is the only provider that owns accounts/lists, while details can
/// come from AniList or Shikimori. Extend these lists (do not add ad-hoc checks
/// in the UI) when MAL/Kitsu/Simkl user repositories land.
class ProviderCapabilities {
  const ProviderCapabilities._();

  static const List<Service> userProviders = [Service.anilist];

  static const List<Service> metadataProviders = [Service.anilist, Service.shikimori];

  /// True when [service] can currently be used as the `userService`.
  static bool isUser(Service service) => userProviders.contains(service);

  /// True when [service] can currently be used as the `metadataService`.
  static bool isMetadata(Service service) => metadataProviders.contains(service);
}