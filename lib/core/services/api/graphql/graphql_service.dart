import 'package:logger/logger.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/api/http/http_service.dart';
import 'package:unyo/core/services/api/shikimori/shikimori_rate_limiter.dart';

import 'graphql_response.dart';

class GraphQLService {
  final HttpService _httpService;
  final String _endpoint;

  /// Optional shared budget (WP #64 subpart (d)). Only the shikimori-named
  /// instance gets one: AniList has no documented per-IP cap this app has to
  /// respect, and a limiter there would slow the whole UI for nothing.
  final ShikimoriRateLimiter? _rateLimiter;
  final Logger _logger = sl<Logger>();

  GraphQLService({
    required HttpService httpService,
    required String endpoint,
    ShikimoriRateLimiter? rateLimiter,
  })  : _httpService = httpService,
        _endpoint = endpoint,
        _rateLimiter = rateLimiter;

  Future<ApiGraphQLResponse<T>> query<T>({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    bool ignoreCache = false,
  }) async {
    _logger.d("Executing GraphQL QUERY operation");
    return _sendRequest(
      query: query,
      variables: variables,
      headers: headers,
      fromJson: fromJson,
      ignoreCache: ignoreCache
    );
  }

  Future<ApiGraphQLResponse<T>> mutation<T>({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    bool ignoreCache = true,
  }) async {
    _logger.d("Executing GraphQL MUTATION operation");
    return _sendRequest(
      query: query,
      variables: variables,
      headers: headers,
      fromJson: fromJson,
      ignoreCache: ignoreCache
    );
  }

  Future<ApiGraphQLResponse<T>> _sendRequest<T>({
    required String query,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
    required bool ignoreCache,
  }) async {
    final body = {
      "query": query,
      "variables": variables ?? {},
    };
    _logger.i("Sending GraphQL request to $_endpoint");
    await _rateLimiter?.acquire(reason: "GraphQL $_endpoint");
    final response = await _httpService.post<ApiGraphQLResponse<T>>(
      _endpoint,
      headers: headers,
      body: body,
      fromJson: (json) => ApiGraphQLResponse<T>.fromJson(
        json,
        fromJson,
      ),
      ignoreCache: ignoreCache
    );
    return response.data;
  }
}
