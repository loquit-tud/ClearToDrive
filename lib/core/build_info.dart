/// QA build metadata (override label in CI via --dart-define=BUILD_LABEL=...).
class BuildInfo {
  static const appVersion = '0.3.5';
  static const buildNumber = '8';
  static const buildLabel = String.fromEnvironment(
    'BUILD_LABEL',
    defaultValue: 'v0.3.5-rca-expiry-date-fix',
  );
}
