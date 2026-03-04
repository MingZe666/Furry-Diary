import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import 'health_form_page.dart';

class HealthRecordDetailPage extends StatefulWidget {
  const HealthRecordDetailPage({
    super.key,
    required this.recordId,
    required this.localStore,
    required this.isPro,
    required this.typeName,
    this.petName,
  });

  final String recordId;
  final LocalStore localStore;
  final bool isPro;
  final String typeName;
  final String? petName;

  @override
  State<HealthRecordDetailPage> createState() => _HealthRecordDetailPageState();
}

class _HealthRecordDetailPageState extends State<HealthRecordDetailPage> {
  HealthRecord? _record;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  void _loadRecord() {
    // Finding record by ID
    final recs = widget.localStore
        .allRecords()
        .where((r) => r.id == widget.recordId)
        .toList();
    if (recs.isNotEmpty) {
      if (mounted) setState(() => _record = recs.first);
    } else {
      if (mounted) setState(() => _record = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('记录详情')),
        body: const Center(child: Text('记录已删除或不存在')),
      );
    }

    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final record = _record!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title:
            const Text('记录详情', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HealthFormPage(
                    localStore: widget.localStore,
                    isPro: widget.isPro,
                    existingRecord: record,
                  ),
                ),
              );
              _loadRecord();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title ?? widget.typeName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        theme, Icons.pets, '所属宠物', widget.petName ?? '未知宠物'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        theme, Icons.category, '记录类型', widget.typeName),
                    const SizedBox(height: 12),
                    _buildInfoRow(theme, Icons.calendar_today, '记录日期',
                        dateFormat.format(record.date.toLocal())),
                    if (record.nextDueDate != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(theme, Icons.event_available, '下次提醒',
                          dateFormat.format(record.nextDueDate!.toLocal())),
                    ],
                    if (record.note != null && record.note!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('备注',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(record.note!, style: const TextStyle(fontSize: 16)),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}
