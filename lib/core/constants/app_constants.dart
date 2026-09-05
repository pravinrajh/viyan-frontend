/// App-wide display constants for the Flutter frontend.
abstract final class AppConstants {
  static const String appName = 'Viyan';
  static const String appSubtitle = 'ArchNova Technologies LLP';

  static const Duration mockNetworkDelay = Duration(milliseconds: 280);

  static const String mockMdName = 'Managing Director';
  /// Display-only until a Company tenant API exists (safe-track single-tenant).
  static const String organizationLabel = 'Organization';
}
