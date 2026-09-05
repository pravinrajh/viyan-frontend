import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/providers/core_providers.dart';
import 'package:md_eao/core/storage/token_storage.dart';
import 'package:md_eao/features/auth/presentation/register_screen.dart';
import 'package:md_eao/features/auth/providers/auth_providers.dart';
import 'package:md_eao/features/auth/repositories/mock_auth_repository.dart';

void main() {
  testWidgets('register shell validates required name', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(
            MockAuthRepository(delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pump();

    expect(find.text('Enter name'), findsOneWidget);
  });
}
