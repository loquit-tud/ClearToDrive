/// QA build metadata (override label in CI via --dart-define=BUILD_LABEL=...).
class BuildInfo {
  static const appVersion = '0.3.2';
  static const buildNumber = '5';
  static const buildLabel = String.fromEnvironment(
    'BUILD_LABEL',
    defaultValue: 'v0.3.2-rca-date-fix',
  );
}
