// External dependencies
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/core/services/api/http/api_response.dart';
import 'package:unyo/core/services/api/http/http_service.dart';

/// Replaces [HttpService] at the HTTP boundary of the GraphQL services.
///
/// It answers every POST with one captured Shikimori payload (a fixture from
/// `test/data/fixtures/shikimori/`, copied from the live captures in
/// `research/unyo-64-shikimori-parity-proof/raws/api/`) and records the request
/// so repository tests can assert the document, its variables and the mandatory
/// `User-Agent` header — the whole DTO/mapper chain runs for real.
class FakeGraphQlHttpService implements HttpService {
  FakeGraphQlHttpService(this.payload);

  /// Raw response body, envelope (`{"data": …}`) included.
  final Map<String, dynamic> payload;

  String? lastEndpoint;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;
  int calls = 0;

  @override
  http.Client get client => throw UnimplementedError('the fake only answers post()');

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
    throw UnimplementedError('the fake only answers post()');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    calls++;
    lastEndpoint = endpoint;
    lastHeaders = headers;
    // GraphQLService hands the request map to HttpService, which is what would
    // encode it; accept both shapes so the captured body is always a map.
    lastBody = body == null ? null : jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    return ApiResponse<T>(
      data: fromJson(payload),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }
}
