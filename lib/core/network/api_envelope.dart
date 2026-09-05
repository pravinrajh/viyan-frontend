import '../errors/app_exception.dart';

/// Helpers for the backend `{ success, message, data }` envelope.
abstract final class ApiEnvelope {
  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const AppException('Unexpected response from the server.');
  }

  static Map<String, dynamic> dataMap(Object? body) {
    return asMap(asMap(body)['data']);
  }

  static List<Map<String, dynamic>> dataList(Object? body) {
    final data = asMap(body)['data'];
    if (data == null) return const [];
    if (data is! List) {
      throw const AppException('Unexpected response from the server.');
    }
    return data.map(asMap).toList();
  }

  static Map<String, dynamic>? meta(Object? body) {
    final value = asMap(body)['meta'];
    if (value == null) return null;
    return asMap(value);
  }
}
