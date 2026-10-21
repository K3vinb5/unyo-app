// External Dependencies
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
  Future<List<Anime>> getUserWatchingList(User user) {
    throw UnimplementedError();
  }

  @override
  Future<List<Manga>> getUserReadingList(User user) {
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


}
