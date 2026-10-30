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
///
/// REST calls (`GET /api/calendar`) are answered from [getPayload]; a top-level
/// JSON array is wrapped as `{'list': [...]}`, exactly what the real
/// [HttpService] does with a list body.
class FakeGraphQlHttpService implements HttpService {
  FakeGraphQlHttpService(this.payload, {this.getPayload, this.payloadsByQueryMarker = const <String, Map<String, dynamic>>{}});

  /// Raw response body, envelope (`{"data": …}`) included.
  final Map<String, dynamic> payload;

  /// Raw body answered by [get] (before the list-wrapping rule).
  final Object? getPayload;

  /// Per-document payloads: the first marker contained in the request document
  /// wins, otherwise [payload] answers. Lets one test cover a genres lookup and
  /// a search with different captured responses.
  final Map<String, Map<String, dynamic>> payloadsByQueryMarker;

  String? lastEndpoint;
  String? lastMethod;
  Map<String, String>? lastHeaders;
  Map<String, dynamic>? lastBody;
  String? lastGetEndpoint;
  int calls = 0;

  /// Body answered by the write verbs ([patch], [put], [delete]). The GraphQL
  /// repository tests never write; the REST list-entry tests use it.
  Map<String, dynamic> writePayload = <String, dynamic>{};

  @override
  http.Client get client => throw UnimplementedError('the fake only answers get() and post()');

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  RetryOptions get retryOptions => const RetryOptions(maxAttempts: 1);

  @override
  Duration get cacheTtl => const Duration(minutes: 20);

  @override
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _write<T>('PATCH', endpoint, headers: headers, body: body, fromJson: fromJson);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _write<T>('PUT', endpoint, headers: headers, body: body, fromJson: fromJson);
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _write<T>('DELETE', endpoint, headers: headers, fromJson: fromJson);
  }

  ApiResponse<T> _write<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    calls++;
    lastMethod = method;
    lastEndpoint = endpoint;
    lastHeaders = headers;
    lastBody = body is Map<dynamic, dynamic>
        ? jsonDecode(jsonEncode(body)) as Map<String, dynamic>
        : null;
    return ApiResponse<T>(
      data: fromJson(writePayload),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    calls++;
    lastGetEndpoint = endpoint;
    lastEndpoint = endpoint;
    lastHeaders = headers;
    final Object? body = getPayload;
    final Map<String, dynamic> json = body is List<dynamic>
        ? <String, dynamic>{'list': body}
        : (body as Map<String, dynamic>? ?? <String, dynamic>{});
    return ApiResponse<T>(
      data: fromJson(json),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
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
    final String document = lastBody?['query']?.toString() ?? '';
    Map<String, dynamic> chosen = payload;
    for (final MapEntry<String, Map<String, dynamic>> entry in payloadsByQueryMarker.entries) {
      if (document.contains(entry.key)) {
        chosen = entry.value;
        break;
      }
    }
    return ApiResponse<T>(
      data: fromJson(chosen),
      bodyBytes: Uint8List(0),
      statusCode: 200,
      headers: const <String, String>{},
    );
  }
}
