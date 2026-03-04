import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/app_models.dart';

class HealthCard extends StatelessWidget {
  const HealthCard({
    super.key,
    required this.type,
    required this.lastRecordAt,
    required this.nextDueDate,
    required this.onTap,
  });

  final RecordType type;
  final DateTime? lastRecordAt;
  final DateTime? nextDueDate;
  final VoidCallback onTap;

  String _getStatusText(AppLocalizations l10n) {
    if (nextDueDate == null) {
      return l10n.statusUnplanned;
    }
    final now = DateTime.now();
    if (nextDueDate!.isBefore(now)) {
      return l10n.statusOverdue;
    }
    if (nextDueDate!.difference(now).inDays <= 3) {
      return l10n.statusDueSoon;
    }
    return l10n.statusNormal;
  }

  Color _getStatusColor(BuildContext context) {
    if (nextDueDate == null) return Colors.grey;
    final now = DateTime.now();
    if (nextDueDate!.isBefore(now)) return Colors.red;
    if (nextDueDate!.difference(now).inDays <= 3) return Colors.orange;
    return Colors.green;
  }

  String _getTypeName(AppLocalizations l10n) {
    switch (type) {
      case RecordType.vaccine:
        return l10n.typeVaccine;
      case RecordType.deworm:
        return l10n.typeDeworm;
      case RecordType.checkup:
        return l10n.typeCheckup;
      case RecordType.medication:
        return l10n.typeMedication;
      case RecordType.bath:
        return l10n.typeBath;
      case RecordType.weight:
        return l10n.typeWeight;
      case RecordType.other:
        return '其他';
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case RecordType.vaccine:
        return Icons.vaccines;
      case RecordType.deworm:
        return Icons.bug_report;
      case RecordType.checkup:
        return Icons.medical_services;
      case RecordType.medication:
        return Icons.medication;
      case RecordType.bath:
        return Icons.bathtub;
      case RecordType.weight:
        return Icons.monitor_weight;
      case RecordType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getTypeIcon(),
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getTypeName(l10n),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  lastRecordAt == null
                      ? l10n.noRecords
                      : l10n.lastRecord(dateFormat.format(lastRecordAt!)),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  nextDueDate == null
                      ? l10n.nextReminderUnplanned
                      : l10n.nextReminder(dateFormat.format(nextDueDate!)),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(l10n),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
