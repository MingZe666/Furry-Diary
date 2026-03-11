import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/local_store.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nicknameController.text = user?.nickname ?? '';
    _emailController.text = '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // TODO: 上传头像到服务器
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像上传功能开发中')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || nickname.length < 2 || nickname.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称长度需在2-20个字符之间')),
      );
      return;
    }

    // TODO: 调用API更新用户信息
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存成功')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('编辑'),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('保存'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _isEditing ? _pickAvatar : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: (user?.avatarPath != null &&
                            user!.avatarPath!.isNotEmpty)
                        ? NetworkImage(user.avatarPath!) as ImageProvider
                        : null,
                    child: (user?.avatarPath == null || user!.avatarPath!.isEmpty)
                        ? Icon(Icons.person,
                            size: 50,
                            color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildField(
            label: '昵称',
            controller: _nicknameController,
            enabled: _isEditing,
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '手机号',
            value: _maskPhone(user?.phone ?? ''),
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '邮箱',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            hint: '未绑定',
          ),
          const SizedBox(height: 32),
          _buildBindingSection(user),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    int? maxLength,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  Widget _buildBindingSection(UserModel? user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: const Text('微信'),
            trailing: Text(
              '未绑定',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('微信绑定功能开发中')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.qq_logo, color: Colors.blue),
            title: const Text('QQ'),
            trailing: Text(
              '未绑定',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QQ绑定功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }
}
