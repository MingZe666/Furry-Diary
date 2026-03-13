import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../widgets/health_card.dart';
import 'timeline_page.dart';
import 'estrus_home_page.dart';

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

  bool _hasFemaleUnspayedPets() {
    final pets = localStore.allPets();
    return pets.any((pet) {
      final isFemale = pet.gender?.contains('母') == true ||
          pet.gender?.toLowerCase().contains('female') == true;
      final isNotNeutered = pet.isNeutered != true;
      return isFemale && isNotNeutered;
    });
  }

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

    final showEstrusCard = _hasFemaleUnspayedPets();

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
        itemCount: types.length + (showEstrusCard ? 1 : 0),
        itemBuilder: (context, index) {
          if (showEstrusCard && index == types.length) {
            return _buildEstrusCard(context, l10n)
                .animate()
                .fadeIn(delay: (index * 50).ms, duration: 400.ms)
                .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack);
          }

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

  Widget _buildEstrusCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EstrusHomePage(
              localStore: localStore,
              isPro: isPro,
            ),
          ));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.estrus,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.estrusRecord,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEC407A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.estrusPrediction,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
