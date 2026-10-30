enum ReloadType {
  empty, // No reload needed
  newMetadataService, // HomeScreen, AnimeScreen and MangaScreen
  newEpisodeService, // AnimeDetailsScreen (episode list)
  homeMediaListEntryUpdated, // HomeScreen
  animeMediaListEntryUpdated, // AnimeDetailsScreen
  videoMediaListEntryUpdated, // AnimeDetailsScreen
}
