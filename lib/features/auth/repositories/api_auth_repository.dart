import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
      ).toJson(),
    );
    return _sessionFrom(response.data);
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );
    return _sessionFrom(response.data);
  }

  @override
  Future<AuthUser> me() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    return AuthUser.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<AuthUser> updateProfile({String? name, String? phone}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (phone != null) body['phone'] = phone.trim();
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.me,
      data: body,
    );
    return AuthUser.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.logout,
      data: {'refreshToken': ?refreshToken},
    );
  }

  AuthSession _sessionFrom(Object? body) {
    try {
      return AuthSession.fromJson(ApiEnvelope.dataMap(body));
    } on FormatException {
      throw const AppException('Authentication response was incomplete.');
    }
  }
}
