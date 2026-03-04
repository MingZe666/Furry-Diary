import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/sync_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authService,
    required this.syncManager,
  });

  final AuthService authService;
  final SyncManager syncManager;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手机号登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '手机号'),
            ),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '验证码'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await widget.authService
                        .requestSmsCode(_phoneController.text);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('验证码已发送')));
                  },
                  child: const Text('获取验证码'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    await widget.authService.loginByPhone(
                      phone: _phoneController.text,
                      code: _codeController.text,
                    );
                    await widget.syncManager.mergeGuestDataAfterLogin();
                    if (!mounted) return;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('登录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
