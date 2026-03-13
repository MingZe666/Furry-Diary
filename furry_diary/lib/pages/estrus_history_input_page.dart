import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import 'estrus_form_page.dart';

class HistoryRecord {
  DateTime? startDate;
  DateTime? endDate;

  HistoryRecord({this.startDate, this.endDate});
}

class EstrusHistoryInputPage extends StatefulWidget {
  const EstrusHistoryInputPage({
    super.key,
    required this.localStore,
    required this.petId,
    required this.isPro,
  });

  final LocalStore localStore;
  final String petId;
  final bool isPro;

  @override
  State<EstrusHistoryInputPage> createState() => _EstrusHistoryInputPageState();
}

class _EstrusHistoryInputPageState extends State<EstrusHistoryInputPage> {
  final List<HistoryRecord> _historyRecords = [HistoryRecord()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.estrusHistoryInputTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFEC407A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.estrusHistoryInputHint,
                      style: const TextStyle(color: Color(0xFFEC407A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._historyRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return _buildHistoryRecordCard(index, record, l10n, colorScheme);
            }),
            if (_historyRecords.length < 3)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _historyRecords.add(HistoryRecord());
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.estrusAddMoreRecords),
              ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.estrusSkipAndContinue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveHistoryRecords,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.estrusSaveAndContinue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRecordCard(
    int index,
    HistoryRecord record,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.estrusRecord} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_historyRecords.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _historyRecords.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectStartDate(context, index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      record.startDate != null
                          ? _formatDate(record.startDate!)
                          : l10n.estrusStartDate,
                      style: TextStyle(
                        color: record.startDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectEndDate(context, index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      record.endDate != null
                          ? _formatDate(record.endDate!)
                          : '${l10n.estrusEndDate} (${l10n.estrusStartDate}之后)',
                      style: TextStyle(
                        color: record.endDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  Future<void> _selectStartDate(BuildContext context, int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _historyRecords[index].startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _historyRecords[index].startDate = picked;
        if (_historyRecords[index].endDate != null &&
            _historyRecords[index].endDate!.isBefore(picked)) {
          _historyRecords[index].endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context, int index) async {
    if (_historyRecords[index].startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择开始日期')),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _historyRecords[index].endDate ??
          _historyRecords[index].startDate!.add(const Duration(days: 14)),
      firstDate: _historyRecords[index].startDate!,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _historyRecords[index].endDate = picked;
      });
    }
  }

  void _saveHistoryRecords() {
    final validRecords = _historyRecords.where((r) => r.startDate != null).toList();

    if (validRecords.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    for (final historyRecord in validRecords) {
      final durationDays = historyRecord.endDate != null
          ? historyRecord.endDate!.difference(historyRecord.startDate!).inDays + 1
          : null;

      final record = EstrusRecord(
        id: const Uuid().v4(),
        petId: widget.petId,
        startDate: historyRecord.startDate!,
        endDate: historyRecord.endDate,
        durationDays: durationDays,
        isSynced: false,
      );

      widget.localStore.upsertEstrusRecord(record);
    }

    Navigator.of(context).pop();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EstrusFormPage(
        localStore: widget.localStore,
        petId: widget.petId,
        isPro: widget.isPro,
      ),
    ));
  }
}
