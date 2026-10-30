// External dependencies
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

/// Factory that resolves the correct [UserRepository] implementation based on
/// the user's selected account provider (`settings.userService`).
///
/// [Service.anilist] and [Service.shikimori] are registered (WP #64 subpart (c)
/// added the second one — see [ProviderCapabilities.userProviders]); every other
/// value throws a [StateError] because the UI cannot produce it.
class UserRepositoryFactory implements UserRepository {
  final UserRepositoryAnilist _userRepositoryAnilist = sl<UserRepositoryAnilist>();
  final UserRepositoryShikimori _userRepositoryShikimori = sl<UserRepositoryShikimori>();
  final Logger _logger = sl<Logger>();

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    switch (_currentUserService) {
      case Service.anilist:
        return _userRepositoryAnilist.fetchAllLoggedInUsers();
      case Service.shikimori:
        return _userRepositoryShikimori.fetchAllLoggedInUsers();
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(_currentUserService);
    }
  }

  @override
  Future<void> attemptCreateUser() async {
    switch (_currentUserService) {
      case Service.anilist:
        return _userRepositoryAnilist.attemptCreateUser();
      case Service.shikimori:
        return _userRepositoryShikimori.attemptCreateUser();
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(_currentUserService);
    }
  }

  @override
  Future<void> updateUserInfo(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.updateUserInfo(user);
      case Service.shikimori:
        return _userRepositoryShikimori.updateUserInfo(user);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserWatchingList(user, ignoreCache: ignoreCache);
      case Service.shikimori:
        return _userRepositoryShikimori.getUserWatchingList(user, ignoreCache: ignoreCache);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserReadingList(user, ignoreCache: ignoreCache);
      case Service.shikimori:
        return _userRepositoryShikimori.getUserReadingList(user, ignoreCache: ignoreCache);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserAnimeLists(user);
      case Service.shikimori:
        return _userRepositoryShikimori.getUserAnimeLists(user);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) async {
    switch (user.settings.userService) {
      case Service.anilist:
        return _userRepositoryAnilist.getUserMangaLists(user);
      case Service.shikimori:
        return _userRepositoryShikimori.getUserMangaLists(user);
      case Service.mal:
      case Service.kitsu:
      case Service.simkl:
        throw _unregistered(user.settings.userService);
    }
  }

  /// The currently logged in user is not passed to [fetchAllLoggedInUsers] or
  /// [attemptCreateUser]; those two run before any session exists and are driven
  /// by the login screen's selected account card (`LoginCubit` calls the concrete
  /// repository), so the no-session default stays AniList.
  Service get _currentUserService => Service.anilist;

  StateError _unregistered(Service service) {
    _logger.e("No UserRepository registered for ${service.name}");
    return StateError("No UserRepository registered for ${service.name}");
  }
}
