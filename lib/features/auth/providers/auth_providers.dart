import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../models/auth_user.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(ref.watch(apiClientProvider));
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Derived session for existing UI (shell, assistant). Auth state lives in
/// [authProvider].
final sessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(authProvider).session;
});

class AuthNotifier extends Notifier<AuthState> {
  int _operation = 0;

  @override
  AuthState build() {
    // ApiClient bumps this when a refresh token is rejected or exhausted
    // mid-session, so an expired session ends the app-wide auth state
    // instead of leaving every screen stuck retrying a dead token.
    final sessionExpired = ref.watch(sessionExpiredNotifierProvider);
    sessionExpired.addListener(_handleSessionExpired);
    ref.onDispose(() => sessionExpired.removeListener(_handleSessionExpired));

    Future<void>.microtask(restoreSession);
    return const AuthState.initial();
  }

  bool _isCurrent(int operation) => ref.mounted && operation == _operation;

  void _handleSessionExpired() {
    if (state.status != AuthStatus.authenticated) return;
    final operation = ++_operation;
    if (!_isCurrent(operation)) return;
    state = const AuthState.unauthenticated();
  }

  Future<void> restoreSession() async {
    if (state.status != AuthStatus.initial) return;
    final operation = _operation;
    final storage = ref.read(tokenStorageProvider);
    String? accessToken;
    String? refreshToken;
    try {
      accessToken = await storage.readAccessToken();
      refreshToken = await storage.readRefreshToken();
    } catch (_) {
      if (!_isCurrent(operation) || state.status != AuthStatus.initial) return;
      state = const AuthState.unauthenticated();
      return;
    }
    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      if (!_isCurrent(operation) || state.status != AuthStatus.initial) {
        return;
      }
      state = const AuthState.unauthenticated();
      return;
    }

    if (!_isCurrent(operation) || state.status != AuthStatus.initial) return;
    state = const AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).me();
      final nextAccess = await storage.readAccessToken() ?? accessToken ?? '';
      final nextRefresh =
          await storage.readRefreshToken() ?? refreshToken ?? '';
      if (nextAccess.isEmpty || nextRefresh.isEmpty) {
        await storage.clear();
        if (!_isCurrent(operation)) return;
        state = const AuthState.unauthenticated();
        return;
      }
      if (!_isCurrent(operation)) return;
      state = AuthState.authenticated(
        AuthSession(
          accessToken: nextAccess,
          refreshToken: nextRefresh,
          user: user,
        ),
      );
    } on AppException catch (error) {
      if (error.statusCode == 401) {
        await storage.clear();
        if (!_isCurrent(operation)) return;
        state = const AuthState.unauthenticated();
        return;
      }
      if (!_isCurrent(operation)) return;
      state = AuthState.error(error.message);
    } catch (_) {
      if (!_isCurrent(operation)) return;
      state = const AuthState.error(
        'Unable to connect to the server. Please try again.',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final operation = ++_operation;
    state = AuthState.loading(session: state.session);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email.trim(), password: password);
      await _persist(session);
      if (!_isCurrent(operation)) return;
      state = AuthState.authenticated(session);
    } on AppException catch (error) {
      if (!_isCurrent(operation)) return;
      state = AuthState.error(error.message);
    } catch (_) {
      if (!_isCurrent(operation)) return;
      state = const AuthState.error(
        'Unable to connect to the server. Please try again.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final operation = ++_operation;
    state = AuthState.loading(session: state.session);
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .register(
            name: name.trim(),
            email: email.trim(),
            phone: phone.trim(),
            password: password,
          );
      await _persist(session);
      if (!_isCurrent(operation)) return;
      state = AuthState.authenticated(session);
    } on AppException catch (error) {
      if (!_isCurrent(operation)) return;
      state = AuthState.error(error.message);
    } catch (_) {
      if (!_isCurrent(operation)) return;
      state = const AuthState.error(
        'Unable to connect to the server. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    final operation = ++_operation;
    final refreshToken = state.session?.refreshToken;
    try {
      await ref.read(authRepositoryProvider).logout(refreshToken: refreshToken);
    } catch (_) {
      // Local sign-out still proceeds if the backend call fails.
    }
    await ref.read(tokenStorageProvider).clear();
    if (!_isCurrent(operation)) return;
    state = const AuthState.unauthenticated();
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    final session = state.session;
    if (session == null) {
      state = const AuthState.error('Sign in to update your profile.');
      return;
    }
    final operation = ++_operation;
    state = AuthState.loading(session: session);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .updateProfile(name: name, phone: phone);
      if (!_isCurrent(operation)) return;
      state = AuthState.authenticated(
        AuthSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          user: user,
        ),
      );
    } on AppException catch (error) {
      if (!_isCurrent(operation)) return;
      state = AuthState.error(error.message, session: session);
    } catch (_) {
      if (!_isCurrent(operation)) return;
      state = AuthState.error(
        'Unable to connect to the server. Please try again.',
        session: session,
      );
    }
  }

  Future<void> _persist(AuthSession session) {
    return ref
        .read(tokenStorageProvider)
        .saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
  }
}
