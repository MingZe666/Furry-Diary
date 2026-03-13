import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

import '../services/local_store.dart';
import '../services/estrus_service.dart';

class EstrusStatsPage extends StatelessWidget {
  const EstrusStatsPage({
    super.key,
    required this.localStore,
    required this.petId,
    required this.isPro,
  });

  final LocalStore localStore;
  final String petId;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final estrusService = EstrusService(localStore);
    final stats = estrusService.getStatistics(petId);
    final symptomStats = estrusService.getSymptomStatistics(petId);
    final records = localStore.estrusRecordsByPet(petId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.estrusStatsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(stats, l10n, colorScheme),
            const SizedBox(height: 24),
            if (isPro) ...[
              _buildCycleTrendCard(records, l10n, colorScheme),
              const SizedBox(height: 24),
              _buildSymptomStatsCard(symptomStats, l10n, colorScheme),
            ] else ...[
              _buildProFeatureCard(l10n, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    Map<String, int> stats,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
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
              l10n.estrusStatsTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.estrusTotalRecords,
                    '${stats['totalRecords'] ?? 0}',
                    Icons.history,
                    const Color(0xFFF48FB1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    l10n.estrusAverageCycle,
                    '${stats['averageCycle'] ?? 0}${l10n.estrusDays(0).replaceAll('0', '')}',
                    Icons.calendar_month,
                    const Color(0xFFEC407A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.estrusAverageDuration,
                    '${stats['averageDuration'] ?? 0}${l10n.estrusDays(0).replaceAll('0', '')}',
                    Icons.timelapse,
                    const Color(0xFFAB47BC),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCycleTrendCard(
    List records,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
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
            Row(
              children: [
                const Icon(Icons.show_chart, color: Color(0xFFF48FB1)),
                const SizedBox(width: 8),
                Text(
                  l10n.estrusCycleTrend,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (records.length < 2)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '需要至少2条记录才能显示趋势',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: _buildSimpleChart(records, colorScheme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(List records, ColorScheme colorScheme) {
    final estrusService = EstrusService(localStore);
    final cycleLengths = estrusService.calculateCycleLengths(records);

    if (cycleLengths.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final maxLength = cycleLengths.reduce((a, b) => a > b ? a : b).toDouble();
    final minLength = cycleLengths.reduce((a, b) => a < b ? a : b).toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: cycleLengths.asMap().entries.map((entry) {
        final index = entry.key;
        final length = entry.value;
        final normalizedHeight = maxLength > 0
            ? ((length - minLength) / (maxLength - minLength + 1)) * 100 + 20
            : 50.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$length',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: normalizedHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFF48FB1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '#${index + 1}',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSymptomStatsCard(
    Map<String, int> symptomStats,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final sortedSymptoms = symptomStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Color(0xFFF48FB1)),
                const SizedBox(width: 8),
                Text(
                  l10n.estrusSymptomStats,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (sortedSymptoms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '暂无症状记录',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ...sortedSymptoms.take(5).map((entry) {
                final percentage = symptomStats.values.isEmpty
                    ? 0
                    : (entry.value / symptomStats.values.reduce((a, b) => a + b) * 100).round();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF48FB1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF48FB1),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildProFeatureCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.estrusProFeature,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '升级到 Pro 版本解锁周期趋势图和症状统计功能',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
