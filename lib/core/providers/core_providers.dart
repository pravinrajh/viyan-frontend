import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/secure_token_storage.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

/// Bumped whenever [ApiClient] gives up on the session (refresh token
/// rejected or exhausted). The auth layer listens for this and forces
/// sign-out; kept here (not in the auth feature) so [apiClientProvider]
/// has no dependency on auth and there is no import cycle.
final sessionExpiredNotifierProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Shared Dio wrapper. Feature repositories must use this client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionExpired = ref.watch(sessionExpiredNotifierProvider);
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    onUnauthorized: () => sessionExpired.value++,
  );
});
