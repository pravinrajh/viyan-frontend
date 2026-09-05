import '../../../core/errors/app_exception.dart';
import '../../../core/utils/mock_delay.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// Test double only. Production auth always uses [ApiAuthRepository].
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.delay,
    this.failLogin = false,
    this.failNetwork = false,
  });

  final Duration? delay;
  final bool failLogin;
  final bool failNetwork;

  static const _user = AuthUser(
    id: '64f0c2a1b8e4d12a9c7f0011',
    name: 'Managing Director',
    email: 'md@eao.local',
    role: 'MD',
    phone: '9876500000',
    status: 'ACTIVE',
    isActive: true,
  );

  static const _session = AuthSession(
    accessToken: 'mock-access-token',
    refreshToken: 'mock-refresh-token',
    user: _user,
  );

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await mockDelay(delay: delay);
    _throwIfConfigured();
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty) {
      throw const AppException('Name, email, phone and password are required');
    }
    return AuthSession(
      accessToken: _session.accessToken,
      refreshToken: _session.refreshToken,
      user: AuthUser(
        id: _user.id,
        name: name.trim(),
        email: email.trim(),
        role: 'EMPLOYEE',
        phone: phone.trim(),
        status: 'ACTIVE',
        isActive: true,
      ),
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await mockDelay(delay: delay);
    _throwIfConfigured();
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const AppException('Email and password are required');
    }
    return _session;
  }

  @override
  Future<AuthUser> me() async {
    await mockDelay(delay: delay);
    _throwIfConfigured();
    return _user;
  }

  @override
  Future<AuthUser> updateProfile({String? name, String? phone}) async {
    await mockDelay(delay: delay);
    _throwIfConfigured();
    return AuthUser(
      id: _user.id,
      name: name?.trim().isNotEmpty == true ? name!.trim() : _user.name,
      email: _user.email,
      role: _user.role,
      phone: phone?.trim().isNotEmpty == true ? phone!.trim() : _user.phone,
      status: _user.status,
      isActive: _user.isActive,
    );
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    await mockDelay(delay: delay);
  }

  void _throwIfConfigured() {
    if (failNetwork) {
      throw const AppException(
        'Unable to connect to the server. Please try again.',
      );
    }
    if (failLogin) {
      throw const AppException('Invalid email or password.');
    }
  }
}
