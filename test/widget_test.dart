import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/app/app.dart';
import 'package:md_eao/core/providers/core_providers.dart';
import 'package:md_eao/core/storage/token_storage.dart';
import 'package:md_eao/features/auth/providers/auth_providers.dart';
import 'package:md_eao/features/auth/repositories/mock_auth_repository.dart';

void main() {
  testWidgets('app launches on the login shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          authRepositoryProvider.overrideWithValue(
            MockAuthRepository(delay: Duration.zero),
          ),
        ],
        child: const MdOfficeApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Viyan'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
