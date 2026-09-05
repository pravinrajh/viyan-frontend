import '../constants/app_constants.dart';

/// Shared latency helper for local mock repositories.
Future<T> withMockDelay<T>(T value, {Duration? delay}) async {
  await Future<void>.delayed(delay ?? AppConstants.mockNetworkDelay);
  return value;
}

Future<void> mockDelay({Duration? delay}) {
  return Future<void>.delayed(delay ?? AppConstants.mockNetworkDelay);
}
