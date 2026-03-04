import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/build_config.dart';
import '../pages/login_page.dart';
import '../pages/pro_purchase_page.dart';
import '../providers/auth_provider.dart';
import '../providers/build_config_provider.dart';

Future<void> openProUpgradeFlow(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final mode = container.read(accountModeProvider);

  if (mode == AccountMode.cloud) {
    final user = container.read(authProvider);
    final needLogin = user == null || user.isGuest;

    if (needLogin) {
      final loginSuccess = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            authService: container.read(authServiceProvider),
            syncManager: container.read(syncManagerProvider),
          ),
        ),
      );

      if (loginSuccess != true) {
        return;
      }
    }
  }

  if (!context.mounted) {
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ProPurchasePage()),
  );
}
