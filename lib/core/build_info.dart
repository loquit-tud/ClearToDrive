/// QA build metadata (override label in CI via --dart-define=BUILD_LABEL=...).
class BuildInfo {
  static const appVersion = '0.3.8';
  static const buildNumber = '11';
  static const buildLabel = String.fromEnvironment(
    'BUILD_LABEL',
    defaultValue: 'v0.4-doc-template-parser',
  );
}
