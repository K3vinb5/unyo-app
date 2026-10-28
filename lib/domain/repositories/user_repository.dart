import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/user/user.dart';

abstract class UserRepository {
  Future<List<User>> fetchAllLoggedInUsers();
  Future<void> attemptCreateUser();
  Future<void> updateUserInfo(User user);
  Future<List<Anime>> getUserWatchingList(User user, {bool ignoreCache = false});
  Future<List<Manga>> getUserReadingList(User user, {bool ignoreCache = false});
  Future<Map<String, List<Anime>>> getUserAnimeLists(User user);
  Future<Map<String, List<Manga>>> getUserMangaLists(User user);
}
