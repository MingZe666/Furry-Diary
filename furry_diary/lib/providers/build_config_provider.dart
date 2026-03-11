import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/build_config.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  return BuildConfig.apiBaseUrl;
});

final wechatAppIdProvider = Provider<String>((ref) {
  return BuildConfig.wechatAppId;
});

final qqAppIdProvider = Provider<String>((ref) {
  return BuildConfig.qqAppId;
});

final syncIntervalProvider = Provider<int>((ref) {
  return BuildConfig.syncIntervalMinutes;
});

final maxDevicesProvider = Provider<int>((ref) {
  return BuildConfig.maxDevicesForFree;
});
