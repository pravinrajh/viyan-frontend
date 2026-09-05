import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/providers/core_providers.dart';
import 'package:md_eao/core/storage/token_storage.dart';
import 'package:md_eao/features/auth/models/auth_user.dart';
import 'package:md_eao/features/auth/providers/auth_providers.dart';
import 'package:md_eao/features/auth/repositories/mock_auth_repository.dart';

void main() {
  ProviderContainer containerWith({
    MockAuthRepository? repository,
    TokenStorage? storage,
  }) {
    return ProviderContainer.test(
      overrides: [
        tokenStorageProvider.overrideWithValue(
          storage ?? InMemoryTokenStorage(),
        ),
        authRepositoryProvider.overrideWithValue(
          repository ?? MockAuthRepository(delay: Duration.zero),
        ),
      ],
    );
  }

  test('restoreSession without tokens is unauthenticated', () async {
    final container = containerWith();
    await container.read(authProvider.notifier).restoreSession();
    expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    expect(container.read(sessionProvider), isNull);
  });

  test('login stores tokens and becomes authenticated', () async {
    final storage = InMemoryTokenStorage();
    final container = containerWith(storage: storage);

    await container
        .read(authProvider.notifier)
        .login(email: 'md@eao.local', password: 'SecurePass123');

    final state = container.read(authProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.session?.user.email, 'md@eao.local');
    expect(await storage.readAccessToken(), 'mock-access-token');
    expect(await storage.readRefreshToken(), 'mock-refresh-token');
  });

  test('login failure stays unauthenticated with a friendly error', () async {
    final container = containerWith(
      repository: MockAuthRepository(delay: Duration.zero, failLogin: true),
    );

    await container
        .read(authProvider.notifier)
        .login(email: 'md@eao.local', password: 'WrongPass1');

    final state = container.read(authProvider);
    expect(state.status, AuthStatus.error);
    expect(state.message, 'Invalid email or password.');
    expect(state.isAuthenticated, isFalse);
  });

  test('register then logout clears the session', () async {
    final storage = InMemoryTokenStorage();
    final container = containerWith(storage: storage);

    await container
        .read(authProvider.notifier)
        .register(
          name: 'Priya Sharma',
          email: 'priya@example.com',
          phone: '9876500801',
          password: 'SecurePass123',
        );
    expect(container.read(authProvider).isAuthenticated, isTrue);

    await container.read(authProvider.notifier).logout();
    expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    expect(await storage.readAccessToken(), isNull);
    expect(await storage.readRefreshToken(), isNull);
  });

  test('network failure on login shows a connection error', () async {
    final container = containerWith(
      repository: MockAuthRepository(delay: Duration.zero, failNetwork: true),
    );

    await container
        .read(authProvider.notifier)
        .login(email: 'md@eao.local', password: 'SecurePass123');

    expect(
      container.read(authProvider).message,
      'Unable to connect to the server. Please try again.',
    );
  });
}
