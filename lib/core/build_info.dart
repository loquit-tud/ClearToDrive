/// QA build metadata (override label in CI via --dart-define=BUILD_LABEL=...).
class BuildInfo {
  static const appVersion = '0.3.3';
  static const buildNumber = '6';
  static const buildLabel = String.fromEnvironment(
    'BUILD_LABEL',
    defaultValue: 'v0.3.3-day-month-fix',
  );
}
