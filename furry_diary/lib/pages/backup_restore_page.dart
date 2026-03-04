import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  bool _isLoading = false;
  List<File> _backupFiles = [];

  bool _isAutoBackupFile(File file) {
    final name =
        file.uri.pathSegments.isEmpty ? '' : file.uri.pathSegments.last;
    return name.startsWith('auto_backup_');
  }

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/furry_diary_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> _loadBackupFiles() async {
    setState(() => _isLoading = true);
    try {
      final backupDir = await _getBackupDirectory();
      final entities = await backupDir.list().toList();
      final files = entities
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      // 按时间倒序排序
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
        _backupFiles = files;
      });
    } catch (e) {
      debugPrint('加载备份文件失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _exportData() async {
    try {
      setState(() => _isLoading = true);
      final localStore = ref.read(localStoreProvider);
      final dataMap = await localStore.exportDataMap();
      final jsonString = jsonEncode(dataMap);

      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${backupDir.path}/backup_$timestamp.json');
      await file.writeAsString(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已成功创建备份数据')),
        );
      }

      await _loadBackupFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importData(File file) async {
    try {
      setState(() => _isLoading = true);
      final jsonString = await file.readAsString();
      final dataMap = jsonDecode(jsonString);

      if (dataMap is Map<String, dynamic> && dataMap.containsKey('version')) {
        final localStore = ref.read(localStoreProvider);
        await localStore.importDataMap(dataMap);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('数据恢复成功！')),
          );
          // 回到首页，强制重载外层逻辑 (如果使用了标准的路由返回方式)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无效的备份数据')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _buildExportFileName() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'furry_diary_backup_$date$time.json';
  }

  Future<void> _exportAndShareData() async {
    try {
      setState(() => _isLoading = true);
      final localStore = ref.read(localStoreProvider);
      final dataMap = await localStore.exportDataMap();
      final jsonString = jsonEncode(dataMap);

      final tempDir = await getTemporaryDirectory();
      final exportFile = File('${tempDir.path}/${_buildExportFileName()}');
      await exportFile.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(exportFile.path)],
        text: '毛孩子日记备份文件，请妥善保存，用于卸载后恢复数据。',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已生成并唤起分享，请保存到微信文件或云盘')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出分享失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndImportData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final selected = result.files.first;
      if (selected.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法读取所选文件，请重试')),
          );
        }
        return;
      }

      await _importData(File(selected.path!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择备份文件失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteBackup(File file) async {
    try {
      await file.delete();
      await _loadBackupFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出与恢复'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Icon(Icons.security, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  '您的宠物和记录数据完全存储在本地设备中。为了防止数据丢失，建议您定期创建备份。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: const Text(
                    '重要：卸载应用会清空本地数据。卸载前请先点击“导出并分享备份文件”，将备份保存到微信文件、云盘或电脑。',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.playlist_add_check),
                  label: const Text('立即创建本地备份'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _exportAndShareData,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('导出并分享备份文件（防卸载丢失）'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickAndImportData,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('从系统文件导入备份'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '现有备份记录',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_backupFiles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      '暂无备份记录',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ..._backupFiles.map((file) {
                    final modified = file.lastModifiedSync();
                    final size = (file.lengthSync() / 1024).toStringAsFixed(2);
                    final isAuto = _isAutoBackupFile(file);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isAuto ? Icons.schedule : Icons.description,
                          color: isAuto ? Colors.orange : Colors.teal,
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(_formatDate(modified))),
                            if (isAuto)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '自动创建',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle:
                            Text('$size KB · ${isAuto ? '自动备份' : '手动备份'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore),
                              tooltip: '恢复此备份',
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('确认恢复数据？'),
                                    content: const Text(
                                      '从该选项恢复将覆盖您当前应用内的所有数据。如果您最近有新增数据，建议先创建一个新备份再恢复。',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _importData(file);
                                        },
                                        child: const Text('确认恢复'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: '删除备份',
                              color: Colors.red,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('确认删除备份？'),
                                    content: const Text('删除后无法找回该备份。'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _deleteBackup(file);
                                        },
                                        child: const Text('确认删除',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
