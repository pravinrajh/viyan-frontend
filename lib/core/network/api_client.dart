import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'api_envelope.dart';
import 'api_error_mapper.dart';

/// HTTP boundary for Sathish's separate Node.js backend (MD_EAO_BACKEND).
/// Widgets and feature notifiers must never call [Dio] directly.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    Dio? dio,
    String? baseUrl,
    this.onUnauthorized,
  }) : _tokenStorage = tokenStorage, // ignore: prefer_initializing_formals
       _baseUrl = baseUrl ?? AppConfig.apiBaseUrl {
    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    _dio = dio ?? Dio(options);
    _refreshDio = Dio(options);
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  final TokenStorage _tokenStorage;
  final String _baseUrl;
  late final Dio _dio;
  late final Dio _refreshDio;
  Future<String?>? _ongoingRefresh;

  /// Fired once when a refresh token is rejected or exhausted mid-session,
  /// so a listener (the auth layer) can force sign-out and route to login
  /// instead of leaving every subsequent screen stuck on a 401.
  final VoidCallback? onUnauthorized;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _guard(() => _dio.post<T>(path, data: data));
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return _guard(() => _dio.put<T>(path, data: data));
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _guard(() => _dio.patch<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path, {Object? data}) {
    return _guard(() => _dio.delete<T>(path, data: data));
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiErrorMapper.fromDio(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'Unable to connect to the server. Please try again.',
      );
    }
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuthPath(options.path)) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final status = error.response?.statusCode;
    final retried = error.requestOptions.extra['authRetried'] == true;
    if (status != 401 || _isPublicAuthPath(error.requestOptions.path)) {
      handler.next(error);
      return;
    }
    if (retried) {
      // The refreshed token was itself rejected: the session is truly over.
      await _tokenStorage.clear();
      onUnauthorized?.call();
      handler.next(error);
      return;
    }

    final accessToken = await _refreshAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStorage.clear();
      onUnauthorized?.call();
      handler.next(error);
      return;
    }

    try {
      final request = error.requestOptions;
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.extra['authRetried'] = true;
      final response = await _dio.fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() {
    final existing = _ongoingRefresh;
    if (existing != null) return existing;
    final future = _doRefresh();
    _ongoingRefresh = future;
    return future.whenComplete(() => _ongoingRefresh = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = ApiEnvelope.dataMap(response.data);
      final accessToken = data['accessToken'] as String?;
      final nextRefresh = data['refreshToken'] as String? ?? refreshToken;
      if (accessToken == null || accessToken.isEmpty) return null;
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefresh,
      );
      return accessToken;
    } catch (_) {
      return null;
    }
  }

  static bool _isPublicAuthPath(String path) {
    return path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refresh);
  }
}
