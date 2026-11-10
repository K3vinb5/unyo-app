// External dependencies
import 'package:logger/logger.dart';

// Internal Dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/domain/entities/entities.dart';
import 'package:unyo/domain/repositories/user_repository.dart';

class UserRepositoryLocal implements UserRepository {
  final Logger _logger = sl<Logger>();

  @override
  Future<List<User>> fetchAllLoggedInUsers() async {
    return [];
  }

  @override
  Future<void> attemptCreateUser() {
    throw UnimplementedError();
  }

  @override
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<Manga>>> getUserMangaLists(User user) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserInfo(User user) {
    throw UnimplementedError();
  }

  /// A local account has no backing box — it only ever exists in the session
  /// that created it (`fetchAllLoggedInUsers` is empty by design), so there is
  /// nothing on disk to delete.
  @override
  Future<void> removeUser(User user) async {
    _logger.i("Nothing to remove for local user ${user.name}: no stored account exists");
  }


}
