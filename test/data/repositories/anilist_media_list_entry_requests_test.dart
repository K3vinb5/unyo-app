// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/graphql/graphql_response.dart';
import 'package:unyo/core/services/api/graphql/graphql_service.dart';
import 'package:unyo/core/services/api/graphql/queries/anilist_queries.dart' as anilist_queries;
import 'package:unyo/data/models/anilist/user/anilist_user_model.dart';
import 'package:unyo/data/repositories/anilist_media_list_entry_requests.dart';
import 'package:unyo/domain/entities/list/media_list_entry.dart';
import 'package:unyo/domain/entities/user/settings.dart';

/// Records every GraphQL call and answers with a canned payload, so a test can
/// prove which calls a route makes — and, for a refusal, that it makes none.
class RecordingGraphQLService implements GraphQLService {
  final List<String> queries = <String>[];
  final List<String> mutations = <String>[];
  final Map<String, Map<String, dynamic>> payloadByQuery = <String, Map<String, dynamic>>{};

  @override
  Future<ApiGraphQLResponse<T>> query<T>({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    bool ignoreCache = false,
  }) async {
    queries.add(query);
    return ApiGraphQLResponse<T>(data: fromJson(payloadByQuery[query] ?? const <String, dynamic>{}));
  }

  @override
  Future<ApiGraphQLResponse<T>> mutation<T>({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    bool ignoreCache = true,
  }) async {
    mutations.add(query);
    return ApiGraphQLResponse<T>(data: fromJson(payloadByQuery[query] ?? const <String, dynamic>{}));
  }
}

/// WP #167 review: deletion is exclusive to the explicit removal route. The save
/// route must refuse a statusless entry instead of dispatching a removal.
void main() {
  late RecordingGraphQLService graphQLService;
  late AnilistMediaListEntryRequests requests;

  const AnilistUserModel user = AnilistUserModel(
    id: '1',
    name: 'tester',
    settings: SettingsModel(),
    avatarImage: '',
    bannerImage: '',
    accessCode: '',
    accessToken: 'access-token',
    refreshToken: '',
  );

  setUp(() {
    graphQLService = RecordingGraphQLService();
    requests = AnilistMediaListEntryRequests(graphQLService);
  });

  group('AnilistMediaListEntryRequests.write (save route)', () {
    test('a statusless draft is refused, and no removal is dispatched', () async {
      await expectLater(
        requests.write(MediaListEntryModel.empty(), 7, user),
        throwsStateError,
      );

      expect(graphQLService.queries, isEmpty, reason: 'no entry lookup, so no delete can follow');
      expect(graphQLService.mutations, isEmpty, reason: 'a save must never delete');
    });

    test('an empty status string is refused the same way', () async {
      await expectLater(
        requests.write(MediaListEntryModel.empty().copyWith(status: ''), 7, user),
        throwsStateError,
      );

      expect(graphQLService.queries, isEmpty);
      expect(graphQLService.mutations, isEmpty);
    });

    test('a draft with a status goes to SaveMediaListEntry only', () async {
      graphQLService.payloadByQuery[anilist_queries.updateMediaEntryQuery] = <String, dynamic>{
        'SaveMediaListEntry': <String, dynamic>{
          'progress': 4,
          'score': 8.0,
          'status': 'CURRENT',
        },
      };

      final MediaListEntry stored = await requests.write(
        MediaListEntryModel.empty().copyWith(status: 'CURRENT', progress: 4, score: 8.0),
        7,
        user,
      );

      expect(graphQLService.mutations, <String>[anilist_queries.updateMediaEntryQuery]);
      expect(graphQLService.queries, isEmpty, reason: 'a save needs no entry-id lookup');
      expect(stored.status, 'CURRENT');
      expect(stored.progress, 4);
    });
  });

  group('AnilistMediaListEntryRequests.remove (delete route)', () {
    test('looks the entry id up and dispatches DeleteMediaListEntry', () async {
      graphQLService.payloadByQuery[anilist_queries.mediaListEntryQuery] = <String, dynamic>{
        'Media': <String, dynamic>{
          'mediaListEntry': <String, dynamic>{'id': 987},
        },
      };
      graphQLService.payloadByQuery[anilist_queries.deleteMediaListEntryQuery] = <String, dynamic>{
        'DeleteMediaListEntry': <String, dynamic>{'deleted': true},
      };

      final MediaListEntry removed = await requests.remove(7, user);

      expect(graphQLService.queries, <String>[anilist_queries.mediaListEntryQuery]);
      expect(graphQLService.mutations, <String>[anilist_queries.deleteMediaListEntryQuery]);
      expect(MediaListEntryModel.isNoStatus(removed.status), isTrue);
    });

    test('an entry that is not on the list is an already-done removal', () async {
      graphQLService.payloadByQuery[anilist_queries.mediaListEntryQuery] = <String, dynamic>{
        'Media': <String, dynamic>{'mediaListEntry': null},
      };

      await requests.remove(7, user);

      expect(graphQLService.queries, <String>[anilist_queries.mediaListEntryQuery]);
      expect(graphQLService.mutations, isEmpty);
    });
  });
}
