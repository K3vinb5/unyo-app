// External dependencies
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_auth_service.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/models/local/user/local_user_model.dart';
import 'package:unyo/data/models/shikimori/user/shikimori_user_model.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/data/repositories/user_repository_local.dart';
import 'package:unyo/data/repositories/user_repository_shikimori.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/hive_registrar.g.dart';

class MockHttpService extends Mock implements HttpService {}

class MockGraphQLService extends Mock implements GraphQLService {}

class MockShikimoriAuthService extends Mock implements ShikimoriAuthService {}

class MockUserNotifier extends Mock implements UserNotifier {}

class _FakeUser extends Fake implements User {}

/// `removeUser` (WP #151) is the storage half of unlinking an account: the row
/// has to leave the provider box it was written to, and nothing else may change.
void main() {
  late Directory tempDir;
  late MockUserNotifier loggedUserNotifier;

  AnilistUserModel anilistUser({required String name, required String id}) => AnilistUserModel(
    id: id,
    name: name,
    settings: SettingsModel.empty().copyWith(userService: Service.anilist),
    avatarImage: '',
    bannerImage: '',
    accessCode: 'code',
    accessToken: 'token',
    refreshToken: 'refresh',
  );

  ShikimoriUserModel shikimoriUser({required String name, required String id}) => ShikimoriUserModel(
    id: id,
    name: name,
    settings: SettingsModel.empty().copyWith(userService: Service.shikimori),
    avatarImage: '',
    bannerImage: '',
    accessToken: 'token',
    refreshToken: 'refresh',
    accessTokenExpiresAt: '',
    profileUrl: '',
  );

  setUpAll(() {
    registerFallbackValue(_FakeUser());
    // Hive refuses a second adapter for the same typeId across tests.
    Hive
      ..registerAdapter(ColorAdapter())
      ..registerAdapters();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('unyo_remove_user_');
    Hive.init(tempDir.path);
    await sl.reset();
    sl.registerSingleton<Logger>(Logger(level: Level.off));
    sl.registerSingleton<HttpService>(MockHttpService());
    sl.registerSingleton<GraphQLService>(
      MockGraphQLService(),
      instanceName: config.anilistGraphQlService,
    );
    sl.registerSingleton<GraphQLService>(
      MockGraphQLService(),
      instanceName: config.shikimoriGraphQlService,
    );
    sl.registerSingleton<ShikimoriAuthService>(MockShikimoriAuthService());
    loggedUserNotifier = MockUserNotifier();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
    await sl.reset();
  });

  group('AniList accounts', () {
    test('removes only the named account from the anilistUsers box', () async {
      final Box<AnilistUserModel> box = await Hive.openBox<AnilistUserModel>(
        UserRepositoryAnilist.usersBoxName,
      );
      await box.put('alice', anilistUser(name: 'alice', id: '1'));
      await box.put('bob', anilistUser(name: 'bob', id: '2'));
      final UserRepositoryAnilist repository = UserRepositoryAnilist(
        MockUserNotifier(),
        loggedUserNotifier,
      );

      await repository.removeUser(anilistUser(name: 'alice', id: '1'));

      expect(box.containsKey('alice'), isFalse);
      expect(box.containsKey('bob'), isTrue);
      // The removal is storage-only: the notifier cleanup belongs to
      // AccountUnlinkService, so the repository must not signal a user update.
      verifyNever(() => loggedUserNotifier.updateUser(any()));
    });

    test('an account that is not stored is a logged no-op', () async {
      final Box<AnilistUserModel> box = await Hive.openBox<AnilistUserModel>(
        UserRepositoryAnilist.usersBoxName,
      );
      await box.put('alice', anilistUser(name: 'alice', id: '1'));
      final UserRepositoryAnilist repository = UserRepositoryAnilist(
        MockUserNotifier(),
        loggedUserNotifier,
      );

      await repository.removeUser(anilistUser(name: 'ghost', id: '9'));

      expect(box.containsKey('alice'), isTrue);
      expect(box.length, 1);
    });
  });

  group('Shikimori accounts', () {
    test('removes only the named account from the shikimoriUsers box', () async {
      final Box<ShikimoriUserModel> box = await Hive.openBox<ShikimoriUserModel>(
        UserRepositoryShikimori.usersBoxName,
      );
      await box.put('alice', shikimoriUser(name: 'alice', id: '1'));
      await box.put('bob', shikimoriUser(name: 'bob', id: '2'));
      final UserRepositoryShikimori repository = UserRepositoryShikimori(
        MockUserNotifier(),
        loggedUserNotifier,
      );

      await repository.removeUser(shikimoriUser(name: 'alice', id: '1'));

      expect(box.containsKey('alice'), isFalse);
      expect(box.containsKey('bob'), isTrue);
      verifyNever(() => loggedUserNotifier.updateUser(any()));
    });
  });

  group('local accounts', () {
    test('have no stored row, so removal completes without opening a box', () async {
      final UserRepositoryLocal repository = UserRepositoryLocal();
      final User localUser = LocalUserModel(
        id: 'local-1',
        name: 'offline',
        settings: SettingsModel.empty(),
        avatarImage: '',
        bannerImage: '',
      );

      await expectLater(repository.removeUser(localUser), completes);
      expect(Hive.isBoxOpen(UserRepositoryAnilist.usersBoxName), isFalse);
    });
  });
}
