/// Compile-time / dart-define configuration for the Flutter frontend.
///
/// Pass values at run/build time, for example:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:5050`
///
/// See `.env.example` for the documented variable names.
/// Secrets must never be committed.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5050',
  );

  /// Leftover dart-define. Live feature providers now bind Api*Repository
  /// regardless of this flag. Mock repositories remain for tests.
  static const bool useMockRepositories = bool.fromEnvironment(
    'USE_MOCK_REPOSITORIES',
    defaultValue: false,
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
