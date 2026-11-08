// External dependencies
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

// Internal dependencies
import 'package:unyo/core/services/api/mal/mal_auth_service.dart';
import 'package:unyo/data/models/mal/user/mal_user_model.dart';
import 'package:unyo/data/repositories/user_repository_mal.dart';

/// One recorded MyAnimeList HTTP exchange, so the assertions can read the real
/// wire shape the repository+service chain produced.
class RecordedMalRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final String body;

  const RecordedMalRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
  });

  Map<String, String> get bodyFields {
    final Map<String, String> fields = <String, String>{};
    for (final String pair in body.split('&')) {
      if (pair.isEmpty) continue;
      final int eq = pair.indexOf('=');
      if (eq < 0) continue;
      fields[Uri.decodeQueryComponent(pair.substring(0, eq))] =
          Uri.decodeQueryComponent(pair.substring(eq + 1));
    }
    return fields;
  }

  @override
  String toString() => '$method $url body=$body';
}

class MockUserRepositoryMal extends Mock implements UserRepositoryMal {}

/// Auth double: the refresh seam is injectable on the real service, and here it
/// is replaced outright so the repository tests stay about the repository.
class FakeMalAuthService extends MalAuthService {
  FakeMalAuthService({this.expired = false});

  bool expired;
  int refreshes = 0;

  @override
  bool isAccessTokenExpired(MalUserModel user, {DateTime? at}) => expired;

  @override
  Future<MalUserModel> withFreshAccessToken(MalUserModel user) async {
    refreshes++;
    expired = false;
    return user.copyWith(
      accessToken: 'fresh-access',
      refreshToken: 'fresh-refresh',
      accessTokenExpiresAt: '2099-01-01T00:00:00.000',
    );
  }
}

/// Scripted MyAnimeList wire: records every request, answers from a queue of
/// `(status, body)` tuples or thrown exceptions (empty queue = `200 {}`).
class MalWireDouble {
  final List<RecordedMalRequest> requests = <RecordedMalRequest>[];
  /// Scripted answers consumed in order: `(status, body)` tuples or thrown
  /// exceptions (empty queue = `200 {}`). Reassignable per test.
  List<Object> answers = <Object>[];

  http.Client createClient() {
    return MockClient((http.Request request) async {
      requests.add(RecordedMalRequest(
        method: request.method,
        url: request.url,
        headers: request.headers,
        body: request.body,
      ));
      if (answers.isEmpty) {
        return http.Response('{}', 200);
      }
      final Object answer = answers.removeAt(0);
      if (answer is Exception) throw answer;
      final (int status, String body) = answer as (int, String);
      return http.Response(body, status);
    });
  }
}
