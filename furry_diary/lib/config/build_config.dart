enum AccountMode {
  localOnly,
  cloud,
}

class BuildConfig {
  static const String _rawMode =
      String.fromEnvironment('ACCOUNT_MODE', defaultValue: 'local');

  static AccountMode get accountMode {
    switch (_rawMode) {
      case 'cloud':
        return AccountMode.cloud;
      case 'local':
      default:
        return AccountMode.localOnly;
    }
  }

  static bool get isCloudAccountMode => accountMode == AccountMode.cloud;
}
