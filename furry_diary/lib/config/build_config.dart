class BuildConfig {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

  static const String wechatAppId =
      String.fromEnvironment('WECHAT_APP_ID', defaultValue: '');

  static const String qqAppId =
      String.fromEnvironment('QQ_APP_ID', defaultValue: '');

  static const int syncIntervalMinutes = 5;

  static const int tokenRefreshThresholdDays = 1;

  static const int maxDevicesForFree = 1;
  static const int maxDevicesForPro = 3;
}
