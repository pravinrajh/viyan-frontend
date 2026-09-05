import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/providers/core_providers.dart';
import 'package:md_eao/core/storage/token_storage.dart';
import 'package:md_eao/features/auth/presentation/login_screen.dart';
import 'package:md_eao/features/auth/providers/auth_providers.dart';
import 'package:md_eao/features/auth/repositories/mock_auth_repository.dart';

ProviderScope _scope({required Widget child, MockAuthRepository? repository}) {
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      authRepositoryProvider.overrideWithValue(
        repository ?? MockAuthRepository(delay: Duration.zero),
      ),
    ],
    child: child,
  );
}

void main() {
  testWidgets('login shell validates empty email', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _scope(child: const MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter email'), findsOneWidget);
  });

  testWidgets('login shell shows the executive title', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _scope(child: const MaterialApp(home: LoginScreen())),
    );
    await tester.pump();

    expect(find.text('Viyan'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('login shows a friendly error for invalid credentials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _scope(
        repository: MockAuthRepository(delay: Duration.zero, failLogin: true),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'WrongPass1');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}
