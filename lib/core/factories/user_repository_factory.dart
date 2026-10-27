// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

/// Factory that resolves the correct [UserRepository] implementation based on
/// the user's selected account provider (`settings.userService`).
///
/// v1 only registers [Service.anilist] (see `kUserProviders`); every other
/// value throws a [StateError] because the UI cannot produce it. WP #64 adds
/// Shikimori here.
class UserRepositoryFactory implements UserRepository {
  final UserRepositoryAnilist _userRepositoryAnilist = sl<UserRepositoryAnilist>();
  final Logger _logger = sl<Logger>();

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    switch (_currentUserService) {
      case Service.anilist:
        return _userRepositoryAnilist.fetchAllLoggedInUsers();
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(_currentUserService);
    }
  }

  @override
  Future<void> attemptCreateUser() async {
    switch (_currentUserService) {
      case Service.anilist:
        return _userRepositoryAnilist.attemptCreateUser();
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(_currentUserService);
    }
  }

  @override
  Future<void> updateUserInfo(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.updateUserInfo(user);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserWatchingList(user, ignoreCache: ignoreCache);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserReadingList(user, ignoreCache: ignoreCache);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserAnimeLists(user);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserMangaLists(user);
      case Service.mal:
      case Service.kitsu:
      case Service.shikimori:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  /// The currently logged in user is not passed to [fetchAllLoggedInUsers] or
  /// [attemptCreateUser]; those two run before any session exists, so they stay
  /// on the v1 default account provider.
  Service get _currentUserService => Service.anilist;

  StateError _unregistered(Service service) {
    _logger.e("No UserRepository registered for ${service.name}");
    return StateError("No UserRepository registered for ${service.name}");
  }
}
