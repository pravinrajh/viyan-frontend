import 'package:md_eao/features/auth/models/auth_user.dart';
import 'package:md_eao/features/auth/providers/auth_providers.dart';
// ignore: depend_on_referenced_packages
import 'package:riverpod/misc.dart' show Override;

const testAuthSession = AuthSession(
  accessToken: 'test-access',
  refreshToken: 'test-refresh',
  user: AuthUser(
    id: 'test-user-id',
    name: 'Test MD',
    email: 'md@test.local',
    role: 'MD',
    phone: '9876500000',
    status: 'ACTIVE',
    isActive: true,
  ),
);

const testEmployeeSession = AuthSession(
  accessToken: 'test-access',
  refreshToken: 'test-refresh',
  user: AuthUser(
    id: 'test-employee-id',
    name: 'Meena Krishnan',
    email: 'meena@test.local',
    role: 'EMPLOYEE',
    phone: '9876500001',
    status: 'ACTIVE',
    isActive: true,
  ),
);

/// Auth override that stays authenticated (skips token restore).
class SeededAuthNotifier extends AuthNotifier {
  SeededAuthNotifier([this.session = testAuthSession]);

  final AuthSession session;

  @override
  AuthState build() => AuthState.authenticated(session);
}

Override authOverride([AuthSession session = testAuthSession]) {
  return authProvider.overrideWith(() => SeededAuthNotifier(session));
}
