import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'local_store.dart';

class AutoBackupService {
  AutoBackupService._();

  static final AutoBackupService instance = AutoBackupService._();
  static const int maxBackupFiles = 10;
  bool _isRunning = false;

  Future<void> onDataChanged(LocalStore localStore) async {
    if (_isRunning) {
      return;
    }

    if (!localStore.getAutoBackupEnabled()) {
      return;
    }

    if (localStore.getAutoBackupFrequency() !=
        LocalStore.autoBackupFrequencyDaily) {
      return;
    }

    final now = DateTime.now();
    final lastBackup = localStore.getLastAutoBackupAt();
    if (lastBackup != null &&
        lastBackup.year == now.year &&
        lastBackup.month == now.month &&
        lastBackup.day == now.day) {
      return;
    }

    _isRunning = true;
    try {
      final dataMap = await localStore.exportDataMap();
      final backupDir = await _getBackupDirectory();
      final timestamp = now.millisecondsSinceEpoch;
      final file = File('${backupDir.path}/auto_backup_$timestamp.json');
      await file.writeAsString(jsonEncode(dataMap));

      await _cleanupOldBackups(backupDir);
      await localStore.saveLastAutoBackupAt(now);
    } catch (error) {
      debugPrint('自动备份失败: $error');
    } finally {
      _isRunning = false;
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/furry_diary_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> _cleanupOldBackups(Directory backupDir) async {
    final entities = await backupDir.list().toList();
    final files = entities
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    if (files.length <= maxBackupFiles) {
      return;
    }

    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
    final overflow = files.length - maxBackupFiles;
    for (var index = 0; index < overflow; index++) {
      await files[index].delete();
    }
  }
}
