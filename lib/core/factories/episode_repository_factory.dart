// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/episode_service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/data/repositories/episode_repository_anizip.dart';
import 'package:unyo/domain/entities/media/episode_info.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/episode_repository.dart';

/// Factory that resolves the correct [EpisodeRepository] implementation
/// based on the user's selected episode metadata [EpisodeService].
///
/// Currently supports:
/// - [EpisodeService.anizip] → delegates to [EpisodeRepositoryAnizip]
/// - [EpisodeService.kitsu] → returns safe empty defaults
class EpisodeRepositoryFactory implements EpisodeRepository {
  final EpisodeRepositoryAnizip _episodeRepositoryAnizip = sl<EpisodeRepositoryAnizip>();
  final UserNotifier _loggedUserNotifier = sl<UserNotifier>(instanceName: config.loggedUserNotifier);
  final Logger _logger = sl<Logger>();

  User get _loggedUser => _loggedUserNotifier.currentUser;

  @override
  Future<List<EpisodeInfo>> getEpisodeInfo({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  }) async {
    switch (_loggedUser.settings.episodeService) {
      case EpisodeService.anizip:
        _logger.i("Fetching episode info from Anizip");
        return _episodeRepositoryAnizip.getEpisodeInfo(
          malId: malId,
          anilistId: anilistId,
          ignoreCache: ignoreCache,
        );
      case EpisodeService.kitsu:
        _logger.i("Fetching episode info from Kitsu");
        return [];
    }
  }

  @override
  Future<String> getAlternativeImage({
    required int malId,
    required int anilistId,
    bool ignoreCache = false,
  }) async {
    switch (_loggedUser.settings.episodeService) {
      case EpisodeService.anizip:
        _logger.i("Fetching alternative image from Anizip");
        return _episodeRepositoryAnizip.getAlternativeImage(
          malId: malId,
          anilistId: anilistId,
          ignoreCache: ignoreCache,
        );
      case EpisodeService.kitsu:
        _logger.i("Fetching alternative image from Kitsu");
        return "";
    }
  }
}
