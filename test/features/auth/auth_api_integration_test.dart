import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/network/api_client.dart';
import 'package:md_eao/core/network/api_endpoints.dart';
import 'package:md_eao/core/storage/token_storage.dart';
import 'package:md_eao/features/auth/repositories/api_auth_repository.dart';

void main() {
  test('live auth register/login/me/logout against localhost:5050', () async {
    final probe = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:5050',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 8),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    try {
      final health = await probe.get<Map<String, dynamic>>(ApiEndpoints.health);
      if (health.statusCode != 200) {
        markTestSkipped('Backend health did not return 200 at localhost:5050');
        return;
      }
    } catch (_) {
      markTestSkipped('Backend is not reachable at http://localhost:5050');
      return;
    }

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    final email = 'flutter.live.$stamp@example.com';
    final phone = '98${stamp.substring(stamp.length - 8)}';
    final storage = InMemoryTokenStorage();
    final repo = ApiAuthRepository(
      ApiClient(tokenStorage: storage, baseUrl: 'http://localhost:5050'),
    );

    final registered = await repo.register(
      name: 'Flutter Live Test',
      email: email,
      phone: phone,
      password: 'SecurePass123',
    );
    expect(registered.accessToken, isNotEmpty);
    expect(registered.refreshToken, isNotEmpty);
    expect(registered.user.email, email);

    await storage.saveTokens(
      accessToken: registered.accessToken,
      refreshToken: registered.refreshToken,
    );

    final loggedIn = await repo.login(email: email, password: 'SecurePass123');
    expect(loggedIn.user.email, email);
    await storage.saveTokens(
      accessToken: loggedIn.accessToken,
      refreshToken: loggedIn.refreshToken,
    );

    final me = await repo.me();
    expect(me.email, email);

    await repo.logout(refreshToken: loggedIn.refreshToken);
    await storage.clear();
    expect(await storage.readAccessToken(), isNull);

    await expectLater(
      repo.login(email: email, password: 'WrongPass1'),
      throwsA(
        predicate(
          (error) => error.toString().contains('Invalid email or password'),
        ),
      ),
    );
  });
}
