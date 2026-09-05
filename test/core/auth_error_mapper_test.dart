import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/network/api_error_mapper.dart';
import 'package:md_eao/core/network/api_endpoints.dart';
import 'package:md_eao/features/auth/models/auth_user.dart';

void main() {
  DioException dio({
    int? status,
    Object? data,
    DioExceptionType type = DioExceptionType.badResponse,
    String path = '/api/v1/auth/login',
  }) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      type: type,
      response: status == null
          ? null
          : Response(
              requestOptions: RequestOptions(path: path),
              statusCode: status,
              data: data,
            ),
    );
  }

  test('401 login maps to invalid credentials', () {
    final error = ApiErrorMapper.fromDio(
      dio(
        status: 401,
        data: {
          'success': false,
          'message': 'Invalid email or password',
          'errors': [],
        },
      ),
    );
    expect(error.message, 'Invalid email or password');
    expect(error.statusCode, 401);
  });

  test('409 uses the backend duplicate-account message', () {
    final error = ApiErrorMapper.fromDio(
      dio(
        status: 409,
        path: ApiEndpoints.register,
        data: {
          'success': false,
          'message': 'Email is already registered',
          'errors': [],
        },
      ),
    );
    expect(error.message, 'Email is already registered');
  });

  test('422 joins field validation messages', () {
    final error = ApiErrorMapper.fromDio(
      dio(
        status: 422,
        data: {
          'success': false,
          'message': 'Validation failed',
          'errors': [
            {
              'field': 'phone',
              'message': 'Phone must be a valid 10-digit Indian mobile number',
            },
            {
              'field': 'password',
              'message': 'Password must be at least 8 characters',
            },
          ],
        },
      ),
    );
    expect(
      error.message,
      contains('Phone must be a valid 10-digit Indian mobile number'),
    );
    expect(error.message, contains('Password must be at least 8 characters'));
  });

  test('connection errors are user-friendly', () {
    final error = ApiErrorMapper.fromDio(
      dio(type: DioExceptionType.connectionError),
    );
    expect(error.message, 'Unable to connect to the server. Please try again.');
  });

  test('timeouts are user-friendly', () {
    final error = ApiErrorMapper.fromDio(
      dio(type: DioExceptionType.connectionTimeout),
    );
    expect(error.message, 'The request timed out. Please try again.');
  });

  test('AuthUser parses the live backend user payload', () {
    final user = AuthUser.fromJson({
      'id': '6a8735e92dc25c77949ad5c0',
      'name': 'Flutter Auth Test',
      'email': 'flutter.auth@example.com',
      'phone': '9876546057',
      'role': 'EMPLOYEE',
      'status': 'ACTIVE',
      'isActive': true,
      'lastLoginAt': '2026-08-20T17:14:18.133Z',
      'createdAt': '2026-08-20T17:14:17.632Z',
      'updatedAt': '2026-08-20T17:14:18.134Z',
    });
    expect(user.id, '6a8735e92dc25c77949ad5c0');
    expect(user.role, 'EMPLOYEE');
    expect(user.isActive, isTrue);
  });

  test('AuthSession requires access and refresh tokens', () {
    expect(
      () => AuthSession.fromJson({
        'user': {'id': '1', 'name': 'A', 'email': 'a@b.c', 'role': 'EMPLOYEE'},
        'accessToken': '',
        'refreshToken': 'refresh',
      }),
      throwsFormatException,
    );
  });
}
