enum ReloadType {
  empty, // No reload needed
  newMetadataService, // HomeScreen, AnimeScreen and MangaScreen
  homeMediaListEntryUpdated, // HomeScreen
  animeMediaListEntryUpdated, // AnimeDetailsScreen
  videoMediaListEntryUpdated, // AnimeDetailsScreen
}