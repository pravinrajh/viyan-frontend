import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import 'api_endpoints.dart';

/// Maps Dio / HTTP failures to user-facing [AppException] messages.
abstract final class ApiErrorMapper {
  static AppException fromDio(DioException error) {
    final status = error.response?.statusCode;
    final backendMessage = _backendMessage(error.response?.data);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        'The request timed out. Please try again.',
        statusCode: status,
        cause: error,
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return AppException(
        'Unable to connect to the server. Please try again.',
        statusCode: status,
        cause: error,
      );
    }

    switch (status) {
      case 400:
        return AppException(
          backendMessage ?? 'The request could not be processed.',
          statusCode: status,
          cause: error,
        );
      case 401:
        return AppException(
          backendMessage ?? _unauthorizedMessage(error.requestOptions.path),
          statusCode: status,
          cause: error,
        );
      case 403:
        return AppException(
          backendMessage ??
              'You do not have permission to perform this action.',
          statusCode: status,
          cause: error,
        );
      case 404:
        return AppException(
          backendMessage ?? 'The requested resource was not found.',
          statusCode: status,
          cause: error,
        );
      case 409:
        return AppException(
          backendMessage ?? 'An account with these details already exists.',
          statusCode: status,
          cause: error,
        );
      case 422:
        return AppException(
          backendMessage ??
              'Please check the highlighted fields and try again.',
          statusCode: status,
          cause: error,
        );
      case 429:
        return AppException(
          backendMessage ?? 'Too many requests. Please try again later.',
          statusCode: status,
          cause: error,
        );
      case 500:
      case 502:
      case 503:
        return AppException(
          'Unable to complete the request. Please try again.',
          statusCode: status,
          cause: error,
        );
      default:
        return AppException(
          backendMessage ?? 'Something went wrong. Please try again.',
          statusCode: status,
          cause: error,
        );
    }
  }

  static String _unauthorizedMessage(String path) {
    if (path.contains(ApiEndpoints.login)) {
      return 'Invalid email or password.';
    }
    return 'Your session has expired. Please sign in again.';
  }

  static String? _backendMessage(Object? data) {
    if (data is! Map) return null;

    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parts = <String>[];
      for (final item in errors) {
        if (item is Map && item['message'] is String) {
          final text = (item['message'] as String).trim();
          if (text.isNotEmpty && !parts.contains(text)) parts.add(text);
        }
      }
      final joined = parts.join(' ');
      if (_isSafe(joined)) return joined;
    }

    final message = data['message'];
    if (message is String && _isSafe(message)) return message.trim();
    return null;
  }

  static bool _isSafe(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.length > 180) return false;
    final lower = trimmed.toLowerCase();
    if (trimmed.contains('\n')) return false;
    if (lower.contains('stack') ||
        lower.contains('mongo') ||
        lower.contains('exception') ||
        lower.contains('authorization:')) {
      return false;
    }
    return true;
  }
}
