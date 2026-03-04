import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../widgets/health_card.dart';
import 'timeline_page.dart';

class HealthGridPage extends StatelessWidget {
  const HealthGridPage({
    super.key,
    required this.localStore,
    required this.isPro,
    this.bottomNavigationBar,
  });

  final LocalStore localStore;
  final bool isPro;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const types = [
      RecordType.vaccine,
      RecordType.deworm,
      RecordType.checkup,
      RecordType.medication,
      RecordType.bath,
      RecordType.weight,
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(l10n.healthRecordsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final records = localStore.recordsByType(type);
          final latest = records.isEmpty ? null : records.first;
          return HealthCard(
            type: type,
            lastRecordAt: latest?.date,
            nextDueDate: latest?.nextDueDate,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return TimelinePage(
                    localStore: localStore, type: type, isPro: isPro);
              }));
            },
          ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack);
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
