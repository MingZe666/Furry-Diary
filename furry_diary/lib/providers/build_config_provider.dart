import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/build_config.dart';

final accountModeProvider = Provider<AccountMode>((ref) {
  return BuildConfig.accountMode;
});
