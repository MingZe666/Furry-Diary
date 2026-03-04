import re
with open("lib/pages/settings_page.dart", "r", encoding="utf-8") as f:
    text = f.read()

# Add auth_provider and login_page
if "auth_provider.dart" not in text:
    text = text.replace("import '../providers/locale_provider.dart';", "import '../providers/locale_provider.dart';\nimport '../providers/auth_provider.dart';\nimport 'login_page.dart';")

# Replace first buildSection containing account status
match = re.search(r'_buildSection\(\s*context,\s*children: \[\s*ListTile\(.*?\)\,', text, re.DOTALL)
if match:
    old_section = text[match.start():text.find('if (!isPro) ...[', match.start())]
    
    new_section = """_buildSection(
            context,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authProvider);
                  final isGuest = user?.isGuest ?? true;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: (user?.avatarPath != null && user!.avatarPath!.isNotEmpty) 
                          ? NetworkImage(user.avatarPath!) as ImageProvider 
                          : null,
                      child: (user?.avatarPath == null || user!.avatarPath!.isEmpty)
                          ? Icon(Icons.person, size: 36, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    title: Text(
                      isGuest ? '点击登录/注册' : (user?.nickname ?? user?.phone ?? '未知用户'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isGuest ? '登录后可云端同步数据，防丢失' : (user?.isPro == true ? l10n.proUser : l10n.freeUser),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (isGuest) {
                        // 跳转到登录页面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Consumer(
                              builder: (ctx, r, _) => LoginPage(
                                authService: r.watch(authServiceProvider),
                                // mock syncManager with null or skip
                              ),
                            ),
                          ),
                        );
                      } else {
                        // 跳转到个人资料页面 (TBD)
                      }
                    },
                  );
                }
              ),
              """
    
    text = text.replace(old_section, new_section)

# Handle sync info display and signout at bottom
last_children_index = text.rfind('          _buildSection(')
if last_children_index != -1:
    end_of_children_list = text.find('        ],', last_children_index)
    if end_of_children_list != -1:
        insert_code = """          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(authProvider);
              if (user == null || user.isGuest) return const SizedBox.shrink();
              
              return _buildSection(
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
                    leading: const Icon(Icons.security),
                    title: const Text('账号与安全'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: theme.colorScheme.error),
                    title: Text('退出登录', style: TextStyle(color: theme.colorScheme.error)),
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
                              child: Text('退出', style: TextStyle(color: theme.colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          ),\n"""
        text = text[:end_of_children_list] + insert_code + text[end_of_children_list:]

with open("lib/pages/settings_page.dart", "w", encoding="utf-8") as f:
    f.write(text)
