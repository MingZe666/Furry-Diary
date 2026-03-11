import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import '../config/build_config.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  List<Device> _devices = [];
  int _maxDevices = 1;
  bool _isLoading = true;
  String? _currentDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final user = ref.read(authProvider);
    if (user == null || user.isGuest) return;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/v1/devices');

      final devicesData = response.data['devices'] as List;
      setState(() {
        _devices = devicesData.map((d) => Device.fromJson(d)).toList();
        _maxDevices = response.data['max_devices'] ?? 1;
        // 添加空列表检查，避免空列表时调用 first 抛出 StateError
        if (_devices.isNotEmpty) {
          final currentDevice = _devices.firstWhere(
            (d) => d.isCurrent,
            orElse: () => _devices.first,
          );
          _currentDeviceId = currentDevice.deviceId;
        } else {
          _currentDeviceId = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载设备列表失败: $e')),
        );
      }
    }
  }

  Future<void> _removeDevice(Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除设备'),
        content: Text('确定要移除设备 "${device.deviceName}" 吗？\n移除后该设备需要重新登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/api/v1/devices/${device.id}');

      setState(() {
        _devices.removeWhere((d) => d.id == device.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设备已移除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移除失败: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '未知';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';

    return '${time.month}月${time.day}日 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getDeviceIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'ios':
      case 'iphone':
      case 'ipad':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isPro = user?.isPro ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设备管理'),
        actions: [
          if (isPro)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme, isPro),
    );
  }

  Widget _buildBody(ThemeData theme, bool isPro) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!isPro) _buildFreeUserBanner(theme),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '已登录设备',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_devices.length}/$_maxDevices',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._devices.map((device) => _buildDeviceItem(device, theme)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            title: const Text('设备管理说明'),
            subtitle: Text(
              isPro
                  ? 'Pro用户最多可在${BuildConfig.maxDevicesForPro}个设备上同时登录'
                  : '免费用户仅限${BuildConfig.maxDevicesForFree}个设备登录，升级Pro可支持多设备',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreeUserBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '单设备使用限制',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '升级Pro可在多设备登录',
                  style: TextStyle(fontSize: 12, color: Colors.amber[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 跳转Pro升级页面
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber[800],
            ),
            child: const Text('立即升级'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(Device device, ThemeData theme) {
    final isCurrent = device.isCurrent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: isCurrent ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '当前',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '最后活跃: ${_formatTime(device.lastActiveAt ?? device.lastLoginAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              onPressed: () => _removeDevice(device),
            ),
        ],
      ),
    );
  }
}
