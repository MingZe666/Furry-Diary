import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import 'estrus_form_page.dart';

class EstrusDetailPage extends StatelessWidget {
  const EstrusDetailPage({
    super.key,
    required this.localStore,
    required this.record,
    required this.isPro,
  });

  final LocalStore localStore;
  final EstrusRecord record;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.estrusRecord,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EstrusFormPage(
                  localStore: localStore,
                  petId: record.petId,
                  isPro: isPro,
                  existingRecord: record,
                ),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.isAbnormal) _buildAbnormalWarning(l10n, colorScheme),
            _buildBasicInfoCard(l10n, colorScheme),
            const SizedBox(height: 16),
            if (record.phase != null ||
                record.dischargeColor != null ||
                record.dischargeAmount != null ||
                record.vulvaSwelling != null)
              _buildSymptomsCard(l10n, colorScheme),
            if (record.behaviorChanges.isNotEmpty)
              _buildBehaviorCard(l10n, colorScheme),
            if (record.symptoms.isNotEmpty)
              _buildPhysicalSymptomsCard(l10n, colorScheme),
            if (record.note != null && record.note!.isNotEmpty)
              _buildNoteCard(l10n, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAbnormalWarning(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                l10n.estrusAbnormalTitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...record.abnormalReasons.map((reason) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reason,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
            '建议咨询兽医',
            style: TextStyle(
              color: Colors.red.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              l10n.estrusStartDate,
              _formatDate(record.startDate),
              colorScheme,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.event_available,
              l10n.estrusEndDate,
              record.endDate != null ? _formatDate(record.endDate!) : l10n.estrusInProgress,
              colorScheme,
              valueColor: record.endDate == null ? const Color(0xFFEC407A) : null,
            ),
            if (record.durationDays != null || record.endDate != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.timelapse,
                l10n.estrusDurationDays,
                '${record.durationDays ?? record.calculateDurationDays() ?? '-'}${l10n.estrusDays(0).replaceAll('0', '')}',
                colorScheme,
              ),
            ],
            if (record.phase != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.category,
                l10n.estrusPhase,
                _getPhaseLabel(record.phase!, l10n),
                colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusSymptoms,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (record.dischargeColor != null)
              _buildInfoRow(
                Icons.color_lens,
                l10n.estrusDischargeColor,
                record.dischargeColor!,
                colorScheme,
              ),
            if (record.dischargeAmount != null) ...[
              if (record.dischargeColor != null) const Divider(height: 16),
              _buildInfoRow(
                Icons.water_drop,
                l10n.estrusDischargeAmount,
                _getAmountLabel(record.dischargeAmount!, l10n),
                colorScheme,
              ),
            ],
            if (record.vulvaSwelling != null) ...[
              if (record.dischargeColor != null || record.dischargeAmount != null)
                const Divider(height: 16),
              _buildInfoRow(
                Icons.healing,
                l10n.estrusVulvaSwelling,
                _getSwellingLabel(record.vulvaSwelling!, l10n),
                colorScheme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusBehaviorChanges,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.behaviorChanges.map((behavior) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    behavior,
                    style: const TextStyle(
                      color: Color(0xFFEC407A),
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalSymptomsCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusSymptoms,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.symptoms.map((symptom) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusNote,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              record.note!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _getPhaseLabel(EstrusPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case EstrusPhase.proestrus:
        return l10n.estrusProestrus;
      case EstrusPhase.estrus:
        return l10n.estrusEstrus;
      case EstrusPhase.diestrus:
        return l10n.estrusDiestrus;
      case EstrusPhase.anestrus:
        return l10n.estrusAnestrus;
    }
  }

  String _getAmountLabel(DischargeAmount amount, AppLocalizations l10n) {
    switch (amount) {
      case DischargeAmount.light:
        return l10n.estrusLight;
      case DischargeAmount.moderate:
        return l10n.estrusModerate;
      case DischargeAmount.heavy:
        return l10n.estrusHeavy;
    }
  }

  String _getSwellingLabel(SwellingLevel level, AppLocalizations l10n) {
    switch (level) {
      case SwellingLevel.none:
        return l10n.estrusSwellingNone;
      case SwellingLevel.mild:
        return l10n.estrusSwellingMild;
      case SwellingLevel.moderate:
        return l10n.estrusSwellingModerate;
      case SwellingLevel.severe:
        return l10n.estrusSwellingSevere;
    }
  }
}
