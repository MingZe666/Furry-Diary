import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../navigation/pro_upgrade_flow.dart';
import '../services/local_store.dart';
import 'login_page.dart';
import 'backup_restore_page.dart';
import 'profile_page.dart';
import 'devices_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    required this.isPro,
    this.bottomNavigationBar,
  });

  final bool isPro;
  final Widget? bottomNavigationBar;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _autoBackupEnabled = false;
  String _autoBackupFrequency = LocalStore.autoBackupFrequencyDaily;
  bool _isAutoBackupLoading = true;
  int _reminderAdvanceDays = 3;
  String _reminderRepeatCycle = LocalStore.reminderRepeatCycleOnce;
  Set<String> _reminderChannels = {LocalStore.reminderChannelPush};

  @override
  void initState() {
    super.initState();
    _loadAutoBackupSettings();
  }

  Future<void> _loadAutoBackupSettings() async {
    final localStore = ref.read(localStoreProvider);
    if (!mounted) {
      return;
    }
    setState(() {
      _autoBackupEnabled = localStore.getAutoBackupEnabled();
      _autoBackupFrequency = localStore.getAutoBackupFrequency();
      _reminderAdvanceDays = localStore.getReminderAdvanceDays();
      _reminderRepeatCycle = localStore.getReminderRepeatCycle();
      _reminderChannels = localStore.getReminderChannels();
      _isAutoBackupLoading = false;
    });
  }

  String _repeatCycleLabel(String value) {
    return switch (value) {
      LocalStore.reminderRepeatCycleDaily => '每天',
      LocalStore.reminderRepeatCycleWeekly => '每周',
      LocalStore.reminderRepeatCycleMonthly => '每月',
      _ => '一次',
    };
  }

  String _channelLabel(String value) {
    return switch (value) {
      LocalStore.reminderChannelSms => '短信',
      LocalStore.reminderChannelEmail => '邮件',
      _ => '推送',
    };
  }

  Future<void> _openReminderSettings() async {
    var tempAdvanceDays = _reminderAdvanceDays;
    var tempRepeatCycle = _reminderRepeatCycle;
    var tempChannels = Set<String>.from(_reminderChannels);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '自定义提醒',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: tempAdvanceDays,
                      decoration: const InputDecoration(
                        labelText: '提前天数',
                        border: OutlineInputBorder(),
                      ),
                      items: const [0, 1, 2, 3, 5, 7, 14]
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d == 0 ? '当天提醒' : '提前$d天'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() => tempAdvanceDays = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: tempRepeatCycle,
                      decoration: const InputDecoration(
                        labelText: '重复周期',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: LocalStore.reminderRepeatCycleOnce,
                            child: Text('一次')),
                        DropdownMenuItem(
                            value: LocalStore.reminderRepeatCycleDaily,
                            child: Text('每天')),
                        DropdownMenuItem(
                            value: LocalStore.reminderRepeatCycleWeekly,
                            child: Text('每周')),
                        DropdownMenuItem(
                            value: LocalStore.reminderRepeatCycleMonthly,
                            child: Text('每月')),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() => tempRepeatCycle = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('提醒方式'),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('推送'),
                      value: tempChannels.contains(LocalStore.reminderChannelPush),
                      onChanged: (v) {
                        setModalState(() {
                          if (v == true) {
                            tempChannels.add(LocalStore.reminderChannelPush);
                          } else {
                            tempChannels.remove(LocalStore.reminderChannelPush);
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('短信（预留）'),
                      value: tempChannels.contains(LocalStore.reminderChannelSms),
                      onChanged: (v) {
                        setModalState(() {
                          if (v == true) {
                            tempChannels.add(LocalStore.reminderChannelSms);
                          } else {
                            tempChannels.remove(LocalStore.reminderChannelSms);
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('邮件（预留）'),
                      value:
                          tempChannels.contains(LocalStore.reminderChannelEmail),
                      onChanged: (v) {
                        setModalState(() {
                          if (v == true) {
                            tempChannels.add(LocalStore.reminderChannelEmail);
                          } else {
                            tempChannels.remove(LocalStore.reminderChannelEmail);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (tempChannels.isEmpty) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('请至少选择一种提醒方式')),
                              );
                            }
                            return;
                          }

                          final localStore = ref.read(localStoreProvider);
                          await localStore.setReminderAdvanceDays(tempAdvanceDays);
                          await localStore.setReminderRepeatCycle(tempRepeatCycle);
                          await localStore.setReminderChannels(tempChannels);

                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _reminderAdvanceDays = tempAdvanceDays;
                            _reminderRepeatCycle = tempRepeatCycle;
                            _reminderChannels = Set<String>.from(tempChannels);
                          });
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('保存提醒设置'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setAutoBackupEnabled(bool value) async {
    final localStore = ref.read(localStoreProvider);
    await localStore.setAutoBackupEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _autoBackupEnabled = value;
    });
  }

  Future<void> _setAutoBackupFrequency(String frequency) async {
    final localStore = ref.read(localStoreProvider);
    await localStore.setAutoBackupFrequency(frequency);
    if (!mounted) {
      return;
    }
    setState(() {
      _autoBackupFrequency = frequency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            children: [
              Consumer(builder: (context, ref, child) {
                final user = ref.watch(authProvider);
                final isGuest = user?.isGuest ?? true;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: (user?.avatarPath != null &&
                            user!.avatarPath!.isNotEmpty)
                        ? NetworkImage(user.avatarPath!) as ImageProvider
                        : null,
                    child:
                        (user?.avatarPath == null || user!.avatarPath!.isEmpty)
                            ? Icon(Icons.person,
                                size: 36,
                                color: theme.colorScheme.onPrimaryContainer)
                            : null,
                  ),
                  title: Text(
                    isGuest
                        ? '点击登录/注册'
                        : (user?.nickname ?? user?.phone ?? '未知用户'),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isGuest
                        ? '登录后可云端同步数据，防丢失'
                        : (user?.isPro == true
                            ? l10n.proUser
                            : l10n.freeUser),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Consumer(
                            builder: (ctx, r, _) => LoginPage(
                              authService: r.watch(authServiceProvider),
                              syncManager: r.watch(syncManagerProvider),
                            ),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    }
                  },
                );
              }),
              if (!widget.isPro) ...[
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.2),
                    child: const Icon(Icons.star, color: Colors.amber),
                  ),
                  title: Text(l10n.upgradePro,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.upgradeProDesc,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    openProUpgradeFlow(context);
                  },
                ),
              ],
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          Consumer(builder: (context, ref, child) {
            final user = ref.watch(authProvider);
            if (user == null || user.isGuest) return const SizedBox.shrink();

            return Column(children: [
              _buildSection(
                context,
                children: [
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('数据同步'),
                    subtitle: const Text('上次同步：刚刚'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('设备管理'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DevicesPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('账号与安全'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        Icon(Icons.exit_to_app, color: theme.colorScheme.error),
                    title: Text('退出登录',
                        style: TextStyle(color: theme.colorScheme.error)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('退出登录'),
                          content: const Text('退出后将无法自动同步本地宠物数据，但本地数据不会被删除。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(authProvider.notifier).logout();
                                Navigator.pop(ctx);
                              },
                              child: Text('退出',
                                  style: TextStyle(
                                      color: theme.colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideX(begin: 0.1, end: 0),
              const SizedBox(height: 24),
            ]);
          }),
          _buildSection(
            context,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.language, color: Colors.blue),
                ),
                title: Text(l10n.language),
                trailing: DropdownButton<String>(
                  value: currentLocale.languageCode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.expand_more),
                  items: [
                    DropdownMenuItem(
                        value: 'zh', child: Text(l10n.languageChinese)),
                    DropdownMenuItem(
                        value: 'en', child: Text(l10n.languageEnglish)),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      ref.read(localeProvider.notifier).state = Locale(
                          newValue);
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications, color: Colors.green),
                ),
                title: Text(l10n.notificationSettings),
                trailing: const Icon(Icons.chevron_right),
                subtitle: Text(
                  '提前$_reminderAdvanceDays天 · ${_repeatCycleLabel(_reminderRepeatCycle)} · ${_reminderChannels.map(_channelLabel).join('/')}',
                ),
                onTap: _openReminderSettings,
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.privacy_tip, color: Colors.purple),
                ),
                title: Text(l10n.privacySettings),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildSection(
            context,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.data_saver_on, color: Colors.teal),
                ),
                title: const Text('数据备份与恢复'),
                subtitle: const Text('导出本地数据或从备份中恢复'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupRestorePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.backup, color: Colors.orange),
                ),
                title: const Text('自动备份'),
                subtitle: Text(
                  _isAutoBackupLoading
                      ? '读取中...'
                      : (_autoBackupEnabled ? '已开启' : '已关闭'),
                ),
                value: _isAutoBackupLoading ? false : _autoBackupEnabled,
                onChanged: _isAutoBackupLoading
                    ? null
                    : (v) => _setAutoBackupEnabled(v),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.indigo),
                ),
                title: const Text('自动备份频率'),
                trailing: DropdownButton<String>(
                  value: _autoBackupFrequency,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: LocalStore.autoBackupFrequencyDaily,
                      child: Text('每天'),
                    ),
                  ],
                  onChanged: _isAutoBackupLoading || !_autoBackupEnabled
                      ? null
                      : (value) {
                          if (value != null) {
                            _setAutoBackupFrequency(value);
                          }
                        },
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
