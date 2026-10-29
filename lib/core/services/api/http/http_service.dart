//External dependencies
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:retry/retry.dart';

// Internal dependencies
import 'package:unyo/config/config.dart' as config;
import 'package:unyo/core/di/locator.dart';
import 'api_response.dart';
import 'http_exception.dart';
import 'response_cache_scope.dart';

class HttpService {
  final http.Client client;
  final Logger _logger = sl<Logger>();
  final Duration timeout;
  final RetryOptions retryOptions;
  final Duration cacheTtl = const Duration(minutes: 20);
  final Map<String, (int, dynamic)> _apiResponseCache = {};

  HttpService({
    this.timeout = const Duration(seconds: 10),
    this.retryOptions = const RetryOptions(maxAttempts: 2),
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Resolved on use, not at construction: test doubles of [HttpService] that
  /// override [get]/[post] never touch the cache and must not need the scope.
  ResponseCacheScope get _cacheScope => sl<ResponseCacheScope>();

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    _logger.d("GET request to $endpoint attempting to return instance of $T");
    if (!ignoreCache) {
      ApiResponse<T>? cachedApiResponse = _getCachedResponse<T>(
        'GET',
        endpoint,
        headers: headers,
        fromJson: fromJson,
      );
      if (cachedApiResponse != null) {
        _logger.d("Returning cached response instance of $T for $endpoint ");
        return cachedApiResponse;
      }
    } else {
      if (_isCacheable(endpoint)) {
        _deleteCacheEntry(_cacheKey('GET', endpoint, headers: headers, fromJson: fromJson));
      }
    }
    ApiResponse<T> apiResponse = await _request(
      'GET',
      endpoint,
      fromJson: fromJson,
      headers: headers,
    );
    _cacheResponse(
      apiResponse,
      'GET',
      endpoint,
      headers: headers,
      fromJson: fromJson,
    );
    return apiResponse;
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool ignoreCache = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    _logger.d("POST request to $endpoint attempting to return instance of $T");
    final encodedBody = json.encode(body);
    if (!ignoreCache) {
      ApiResponse<T>? cachedApiResponse = _getCachedResponse<T>(
        'POST',
        endpoint,
        headers: headers,
        body: encodedBody,
        fromJson: fromJson,
      );
      if (cachedApiResponse != null) {
        _logger.d("Returning cached response instance of $T for $endpoint ");
        return cachedApiResponse;
      }
    } else {
      if (_isCacheable(endpoint)) {
        _deleteCacheEntry(
          _cacheKey('POST', endpoint, headers: headers, body: encodedBody, fromJson: fromJson),
        );
      }
    }
    ApiResponse<T> apiResponse = await _request(
      'POST',
      endpoint,
      fromJson: fromJson,
      headers: headers,
      body: encodedBody,
    );
    _cacheResponse(
      apiResponse,
      'POST',
      endpoint,
      headers: headers,
      body: encodedBody,
      fromJson: fromJson
    );
    return apiResponse;
  }

  ApiResponse<T>? _getCachedResponse<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (!_isCacheable(endpoint)) return null;
    final cacheKey = _cacheKey(method, endpoint, headers: headers, body: body, fromJson: fromJson);
    if (_apiResponseCache.containsKey(cacheKey)) {
      _logger.d("Cached response found for $endpoint");
      try {
        final (expiry, cachedResponse as ApiResponse<T>) =
        _apiResponseCache[cacheKey]!;
        if (expiry < DateTime.now().millisecondsSinceEpoch) {
          _logger.d(
            "Cached response for $endpoint has expired, making new request",
          );
          _apiResponseCache.remove(cacheKey);
        } else {
          _logger.d("Cached response for $endpoint is still valid for ${(expiry - DateTime.now().millisecondsSinceEpoch) / 1000}s");
          return cachedResponse;
        }
      } catch (e, stackTrace) {
        _logger.e(
          "Error while retrieving cached response for $endpoint: $e",
          stackTrace: stackTrace,
        );
        _apiResponseCache.remove(cacheKey);
        return null;
      }
    }
    _logger.d("No cached response found for $endpoint");
    return null;
  }

  void _cacheResponse<T>(
    ApiResponse<T> response,
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (response.statusCode >= 300) {
      _logger.w("Not caching response for $endpoint due to client error with status code ${response.statusCode}");
      return;
    }
    if (!_isCacheable(endpoint)) return;
    _logger.d("Caching response for $endpoint");
    final cacheKey = _cacheKey(method, endpoint, headers: headers, body: body, fromJson: fromJson);
    _apiResponseCache[cacheKey] =
        (
          DateTime.now().millisecondsSinceEpoch + cacheTtl.inMilliseconds,
          response,
        );
  }

  /// Cache key for a request: request identity plus the provider scope the
  /// response was fetched under ([ResponseCacheScope.revision]). Everything
  /// cached under an earlier scope stays unreachable, so a provider switch can
  /// never hand a lazy tab the previous provider's rows.
  String _cacheKey<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return "${_cacheScope.revision}${method.hashCode}${endpoint.hashCode}"
        "${json.encode(_cacheEnabledHeaders(headers)).hashCode}${body.hashCode}${fromJson.runtimeType.hashCode}";
  }

  bool _isCacheable(String endpoint) {
    if (config.cacheDisabledEndpoints.contains(endpoint)){
      _logger.w("Endpoint $endpoint is disabled for caching");
      return false;
    }
    if (config.cacheDisabledHosts.contains(Uri.parse(endpoint).host)) {
      _logger.w("Host ${Uri.parse(endpoint).host} is disabled for caching");
      return false;
    }
    return true;
  }

  Map<String, String>? _cacheEnabledHeaders(
    Map<String, String>? headers,
  ) {
    if (headers == null) return null;
    return Map.fromEntries(
      headers.entries.where((entry) => !config.cacheIgnoredHeaders.contains(entry.key)),
    );
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(endpoint);
    _logger.d("Handling $method request to $uri");
    try {
      final response = await retryOptions.retry(() async {
        final request = switch (method) {
          'POST' => client.post(
            uri,
            headers: _defaultHeaders(headers),
            body: body,
          ),
          'GET' => client.get(uri, headers: _defaultHeaders(headers)),
          'PUT' => client.put(
            uri,
            headers: _defaultHeaders(headers),
            body: body,
          ),
          'PATCH' => client.patch(
            uri,
            headers: _defaultHeaders(headers),
            body: body,
          ),
          'DELETE' => client.delete(uri, headers: _defaultHeaders(headers)),
          _ => throw UnsupportedError('Method not supported'),
        };
        return await request.timeout(timeout);
      }, retryIf: (e) => e is SocketException || e is TimeoutException);
      _logger.d(
        "Handling response received from $uri with status code ${response.statusCode}",
      );
      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      _logger.e("SocketException occurred while handling request to $uri");
      rethrow;
    } on TimeoutException {
      _logger.e("TimeoutException occurred while handling request to $uri");
      rethrow;
    } on http.ClientException {
      _logger.e(
        "ClientException occurred while handling request to $uri",
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error occurred while handling request to $uri: $e",
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      _logger.d("Response from server is successful with status code $status");
      if (response.body.isEmpty) {
        _logger.d("Response body is empty, returning empty ApiResponse");
        return ApiResponse(
          data: fromJson({}),
          bodyBytes: response.bodyBytes,
          statusCode: status,
          headers: response.headers,
        );
      }
      if (json.decode(response.body) is List<dynamic>) {
        final jsonList = json.decode(response.body) as List<dynamic>;
        return ApiResponse(
            data: fromJson({'list': jsonList}),
            bodyBytes: response.bodyBytes,
            statusCode: status,
            headers: response.headers
        );
      }
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        data: fromJson(jsonMap),
        bodyBytes: response.bodyBytes,
        statusCode: status,
        headers: response.headers,
      );
    }
    // TODO if status is specific number saying no more requests available return specific exception
    _logger.e(
      "Response from server failed with status code $status: ${response.body}",
    );
    throw HttpServerException(status, response.body);
  }

  Map<String, String> _defaultHeaders(Map<String, String>? override) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?override,
    };
  }

  void _deleteCacheEntry(String cacheKey) {
    if (_apiResponseCache.containsKey(cacheKey)) {
      (int, dynamic)? cacheEntry = _apiResponseCache.remove(cacheKey);
      _logger.d("Deleted cache entry ${cacheEntry?.$2} with expiration ${cacheEntry?.$1}");
      return;
    }
    _logger.w("No cache entry found for key $cacheKey to delete. Current cache: \n${_cacheToString()}");
  }

  String _cacheToString() {
    return _apiResponseCache.entries.map((entry) {
      final cacheKey = entry.key;
      final (expiry, cachedResponse) = entry.value;
      return "CacheKey: $cacheKey, Expiry: ${DateTime.fromMillisecondsSinceEpoch(expiry)}, CachedResponse: $cachedResponse";
    }).join("\n");
  }
}
