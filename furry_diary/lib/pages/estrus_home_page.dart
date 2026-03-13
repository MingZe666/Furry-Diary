import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../services/estrus_service.dart';
import 'estrus_form_page.dart';
import 'estrus_detail_page.dart';
import 'estrus_calendar_page.dart';
import 'estrus_stats_page.dart';

class EstrusHomePage extends StatefulWidget {
  const EstrusHomePage({
    super.key,
    required this.localStore,
    required this.isPro,
    this.initialPetId,
  });

  final LocalStore localStore;
  final bool isPro;
  final String? initialPetId;

  @override
  State<EstrusHomePage> createState() => _EstrusHomePageState();
}

class _EstrusHomePageState extends State<EstrusHomePage> {
  late EstrusService _estrusService;
  List<PetProfile> _femalePets = [];
  PetProfile? _selectedPet;
  List<EstrusRecord> _records = [];
  EstrusPrediction? _prediction;

  @override
  void initState() {
    super.initState();
    _estrusService = EstrusService(widget.localStore);
    widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
    _loadData();
  }

  @override
  void dispose() {
    widget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (!mounted) return;
    _loadData();
  }

  void _loadData() {
    final allPets = widget.localStore.allPets();
    _femalePets = allPets.where((pet) {
      final isFemale = pet.gender?.contains('母') == true ||
          pet.gender?.toLowerCase().contains('female') == true;
      final isNotNeutered = pet.isNeutered != true;
      return isFemale && isNotNeutered;
    }).toList();

    if (_femalePets.isEmpty) {
      setState(() {
        _selectedPet = null;
        _records = [];
        _prediction = null;
      });
      return;
    }

    if (_selectedPet == null || !_femalePets.contains(_selectedPet)) {
      if (widget.initialPetId != null) {
        _selectedPet = _femalePets.firstWhere(
          (p) => p.id == widget.initialPetId,
          orElse: () => _femalePets.first,
        );
      } else {
        _selectedPet = _femalePets.first;
      }
    }

    _records = widget.localStore.estrusRecordsByPet(_selectedPet!.id);
    _prediction = _estrusService.predictNextEstrus(
      _records,
      species: _selectedPet!.type,
      breed: _selectedPet!.breed,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_femalePets.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.estrus,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  l10n.estrusOnlyFemalePets,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.estrusOnlyUnspayedPets,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.estrus,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EstrusCalendarPage(
                  localStore: widget.localStore,
                  petId: _selectedPet!.id,
                ),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EstrusStatsPage(
                  localStore: widget.localStore,
                  petId: _selectedPet!.id,
                  isPro: widget.isPro,
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
            if (_femalePets.length > 1) _buildPetSelector(l10n, colorScheme),
            _buildCurrentStatusCard(l10n, colorScheme),
            const SizedBox(height: 16),
            _buildPredictionCard(l10n, colorScheme),
            const SizedBox(height: 24),
            _buildRecordsList(l10n, colorScheme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.estrusAddRecord),
        backgroundColor: const Color(0xFFF48FB1),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPetSelector(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PetProfile>(
          value: _selectedPet,
          isExpanded: true,
          items: _femalePets.map((pet) {
            return DropdownMenuItem(
              value: pet,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: pet.avatarPath != null
                        ? AssetImage(pet.avatarPath!)
                        : null,
                    child: pet.avatarPath == null
                        ? Text(pet.name[0], style: const TextStyle(fontSize: 14))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(pet.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (pet) {
            if (pet != null) {
              setState(() {
                _selectedPet = pet;
                _records = widget.localStore.estrusRecordsByPet(pet.id);
                _prediction = _estrusService.predictNextEstrus(
                  _records,
                  species: pet.type,
                  breed: pet.breed,
                );
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(AppLocalizations l10n, ColorScheme colorScheme) {
    final ongoingRecord = _estrusService.getLatestOngoingRecord(_selectedPet!.id);
    final isOngoing = ongoingRecord != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isOngoing
                ? [const Color(0xFFFCE4EC), const Color(0xFFF8BBD9)]
                : [colorScheme.surface, colorScheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOngoing
                        ? const Color(0xFFEC407A)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOngoing ? l10n.estrusInProgress : l10n.estrusPredicted,
                    style: TextStyle(
                      color: isOngoing ? Colors.white : colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (_selectedPet!.avatarPath != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(_selectedPet!.avatarPath!),
                  )
                else
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF48FB1),
                    child: Text(
                      _selectedPet!.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedPet!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isOngoing) ...[
              Text(
                '${l10n.estrusStartDate}: ${_formatDate(ongoingRecord.startDate)}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              if (ongoingRecord.durationDays != null)
                Text(
                  '${l10n.estrusDurationDays}: ${l10n.estrusDays(ongoingRecord.durationDays!)}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
            ] else if (_prediction != null) ...[
              Text(
                '${l10n.estrusNextPrediction}: ${_formatDate(_prediction!.predictedDate)}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                l10n.estrusDaysUntilNext(_prediction!.daysUntilNext),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPredictionCard(AppLocalizations l10n, ColorScheme colorScheme) {
    if (_prediction == null) return const SizedBox.shrink();

    final confidenceColor = _prediction!.confidence == PredictionConfidence.high
        ? Colors.green
        : _prediction!.confidence == PredictionConfidence.medium
            ? Colors.orange
            : Colors.grey;

    final confidenceText = _prediction!.confidence == PredictionConfidence.high
        ? l10n.estrusPredictionConfidenceHigh
        : _prediction!.confidence == PredictionConfidence.medium
            ? l10n.estrusPredictionConfidenceMedium
            : l10n.estrusPredictionConfidenceLow;

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
                const Icon(Icons.insights, color: Color(0xFFF48FB1)),
                const SizedBox(width: 8),
                Text(
                  l10n.estrusPrediction,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n.estrusAverageCycle,
                    '${_prediction!.averageCycle}${l10n.estrusDays(0).replaceAll('0', '')}',
                    Icons.calendar_month,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n.estrusAverageDuration,
                    _prediction!.averageDuration != null
                        ? '${_prediction!.averageDuration}${l10n.estrusDays(0).replaceAll('0', '')}'
                        : '-',
                    Icons.timelapse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: confidenceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: confidenceColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      confidenceText,
                      style: TextStyle(
                        color: confidenceColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFFF48FB1)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.estrusRecord,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.estrusTotalRecords(_records.length),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_records.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.estrusNoRecords,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _records.length > 10 ? 10 : _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return _buildRecordItem(record, l10n, colorScheme)
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 300.ms);
            },
          ),
      ],
    );
  }

  Widget _buildRecordItem(
    EstrusRecord record,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final isOngoing = record.endDate == null;
    final isAbnormal = record.isAbnormal;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAbnormal
              ? Colors.red.withOpacity(0.5)
              : isOngoing
                  ? const Color(0xFFF48FB1).withOpacity(0.5)
                  : colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isOngoing
                ? const Color(0xFFFCE4EC)
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isAbnormal ? Icons.warning : Icons.event,
            color: isAbnormal
                ? Colors.red
                : isOngoing
                    ? const Color(0xFFEC407A)
                    : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          _formatDate(record.startDate),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          record.endDate != null
              ? '${l10n.estrusDurationDays}: ${record.durationDays ?? record.calculateDurationDays() ?? '-'}${l10n.estrusDays(0).replaceAll('0', '')}'
              : l10n.estrusInProgress,
        ),
        trailing: isAbnormal
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.estrusAbnormalTitle,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EstrusDetailPage(
              localStore: widget.localStore,
              record: record,
              isPro: widget.isPro,
            ),
          ));
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _navigateToForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EstrusFormPage(
        localStore: widget.localStore,
        petId: _selectedPet!.id,
        isPro: widget.isPro,
      ),
    ));
  }
}
