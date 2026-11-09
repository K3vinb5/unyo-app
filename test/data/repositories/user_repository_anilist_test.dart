// External dependencies
import 'dart:io';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart' show sl;
import 'package:unyo/core/notification/user_notifier.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/data/adapters/type_adapters/color_adapter.dart';
import 'package:unyo/data/repositories/user_repository_anilist.dart';
import 'package:unyo/hive_registrar.g.dart';

class MockLogger extends Mock implements Logger {}

/// `UserRepositoryAnilist` resolves its transports at construction; the login
/// flow never reaches them (that is the token half of the flow, out of scope
/// here), so a double that refuses every call is enough.
class UnusedHttpService implements HttpService {
  @override
  http.Client get client => throw UnimplementedError('the login server is not a transport');

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  RetryOptions get retryOptions => const RetryOptions(maxAttempts: 1);

  @override
  Duration get cacheTtl => const Duration(minutes: 20);

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login callback server is under test, not a transport');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login callback server is under test, not a transport');
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login callback server is under test, not a transport');
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login callback server is under test, not a transport');
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    throw UnimplementedError('the login callback server is under test, not a transport');
  }
}

/// Both the AniList and the Shikimori suite drive the shared `:9999` callback,
/// and `flutter test` runs suites concurrently. Two listeners on a `shared` port
/// load-balance incoming requests between them, so a probe could land on the
/// other provider's handler. This file lock keeps only one suite bound at a
/// time, which is what makes the per-handler assertions meaningful.
Future<RandomAccessFile> lockCallbackPort() async {
  final File file = File('${Directory.systemTemp.path}/unyo_oauth_callback_9999.lock');
  final RandomAccessFile handle = await file.open(mode: FileMode.write);
  while (true) {
    try {
      await handle.lock(FileLock.exclusive);
      return handle;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }
}

/// A sibling suite (`user_repository_shikimori_test`) drives the very same
/// shared `:9999` callback and `flutter test` runs test files concurrently, so a
/// bind can race the other suite's live listener. Retry briefly instead of
/// failing: the winner's teardown releases the port in milliseconds.
Future<void> bindLoginServer(Future<void> Function() attemptCreateUser) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 20));
  while (true) {
    try {
      await attemptCreateUser();
      return;
    } on SocketException {
      if (DateTime.now().isAfter(deadline)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }
}

/// WP #163: the AniList callback on the shared `:9999` used to throw on a
/// code-less request (`queryParameters['code']!`) and close the server in its
/// `finally`, so a favicon/probe killed the in-flight OAuth redirect. These
/// tests drive the real shelf server.
void main() {
  // `attemptCreateUser` launches the OAuth page through `url_launcher`, a
  // platform channel, so the binding must exist...
  TestWidgetsFlutterBinding.ensureInitialized();
  // ...but the test binding installs an HttpOverrides answering every request
  // with an empty 400. These tests talk to the real shelf server on :9999.
  HttpOverrides.global = null;

  late Directory tempDir;
  late RandomAccessFile callbackLock;
  bool adaptersRegistered = false;

  setUp(() async {
    callbackLock = await lockCallbackPort();
    await sl.reset();
    sl.registerSingleton<Logger>(MockLogger());
    sl.registerSingleton<HttpService>(UnusedHttpService());
    sl.registerLazySingleton<GraphQLService>(
      () => GraphQLService(
        httpService: sl<HttpService>(),
        endpoint: config.anilistGraphQLEndpoint,
      ),
      instanceName: config.anilistGraphQlService,
    );
    // `attemptCreateUser` binds the callback before opening the browser; under
    // `flutter test` there is none, so the channel answers "cannot launch".
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (MethodCall call) async => call.method != 'canLaunch',
    );
    tempDir = await Directory.systemTemp.createTemp('unyo_anilist_user_repo_');
    Hive.init(tempDir.path);
    if (!adaptersRegistered) {
      Hive
        ..registerAdapter(ColorAdapter())
        ..registerAdapters();
      adaptersRegistered = true;
    }
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), null);
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    await callbackLock.unlock();
    await callbackLock.close();
  });

  group('login flow (shared shelf :9999)', () {
    test('a code-less request is a bad request and keeps the shared server up', () async {
      final UserRepositoryAnilist repository = UserRepositoryAnilist(UserNotifier(), UserNotifier());
      addTearDown(repository.closeLoginServer);

      await bindLoginServer(repository.attemptCreateUser);

      final Uri callback = Uri.parse(config.anilistRedirectUri);
      final http.Response first = await http.get(callback);
      expect(first.statusCode, 400, reason: first.body);
      expect(first.body, contains('authorization code'),
          reason: 'the repository handler answered, not an HTTP mock');

      final http.Response second = await http.get(callback);
      expect(second.statusCode, 400, reason: 'the server must still be listening: ${second.body}');
    });

    test('an abandoned login server is reaped by the timeout', () async {
      final UserRepositoryAnilist repository = UserRepositoryAnilist(
        UserNotifier(),
        UserNotifier(),
        loginServerTimeout: const Duration(milliseconds: 100),
      );
      addTearDown(repository.closeLoginServer);

      await bindLoginServer(repository.attemptCreateUser);

      final Uri callback = Uri.parse(config.anilistRedirectUri);
      expect((await http.get(callback)).statusCode, 400, reason: 'the server is up before the timeout');

      Object? closedBy;
      final DateTime deadline = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(deadline)) {
        try {
          await http.get(callback);
          await Future<void>.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          closedBy = e;
          break;
        }
      }
      expect(closedBy, isNotNull, reason: 'the timer must close a login nobody finishes');
      expect(closedBy, anyOf(isA<http.ClientException>(), isA<SocketException>()));
    });
  });
}
