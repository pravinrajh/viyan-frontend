import '../models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSession> login({required String email, required String password});

  Future<AuthUser> me();

  Future<AuthUser> updateProfile({String? name, String? phone});

  Future<void> logout({String? refreshToken});
}
