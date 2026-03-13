import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../services/estrus_service.dart';

class EstrusFormPage extends StatefulWidget {
  const EstrusFormPage({
    super.key,
    required this.localStore,
    required this.petId,
    required this.isPro,
    this.existingRecord,
  });

  final LocalStore localStore;
  final String petId;
  final bool isPro;
  final EstrusRecord? existingRecord;

  @override
  State<EstrusFormPage> createState() => _EstrusFormPageState();
}

class _EstrusFormPageState extends State<EstrusFormPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  DateTime? _endDate;
  EstrusPhase? _phase;
  String? _dischargeColor;
  DischargeAmount? _dischargeAmount;
  SwellingLevel? _vulvaSwelling;
  final List<String> _selectedBehaviors = [];
  final List<String> _selectedSymptoms = [];
  final _noteController = TextEditingController();

  late EstrusService _estrusService;
  bool _isFirstRecord = false;

  final List<String> _behaviorOptions = [
    '烦躁不安',
    '情绪低落',
    '更加粘人',
    '食欲下降',
    '频繁排尿',
    '舔舐外阴',
    '寻找配偶',
    '攻击性增强',
    '活动减少',
  ];

  final List<String> _symptomOptions = [
    '外阴肿胀',
    '乳房胀大',
    '体温升高',
    '饮水量增加',
  ];

  final List<String> _dischargeColors = [
    '粉红',
    '鲜红',
    '暗红',
    '淡黄',
    '透明',
  ];

  @override
  void initState() {
    super.initState();
    _estrusService = EstrusService(widget.localStore);

    if (widget.existingRecord != null) {
      _startDate = widget.existingRecord!.startDate;
      _endDate = widget.existingRecord!.endDate;
      _phase = widget.existingRecord!.phase;
      _dischargeColor = widget.existingRecord!.dischargeColor;
      _dischargeAmount = widget.existingRecord!.dischargeAmount;
      _vulvaSwelling = widget.existingRecord!.vulvaSwelling;
      _selectedBehaviors.addAll(widget.existingRecord!.behaviorChanges);
      _selectedSymptoms.addAll(widget.existingRecord!.symptoms);
      _noteController.text = widget.existingRecord!.note ?? '';
    } else {
      _startDate = DateTime.now();
      _isFirstRecord = widget.localStore.estrusRecordsByPet(widget.petId).isEmpty;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.estrusEditRecord : l10n.estrusAddRecord,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, l10n),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildPhaseSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildDischargeSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildSwellingSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildBehaviorSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildSymptomSection(l10n, colorScheme),
              const SizedBox(height: 24),
              _buildNoteSection(l10n, colorScheme),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF48FB1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusStartDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartDate(context),
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
                      _formatDate(_startDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.estrusEndDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectEndDate(context),
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
                      _endDate != null ? _formatDate(_endDate!) : l10n.estrusInProgress,
                      style: TextStyle(
                        fontSize: 16,
                        color: _endDate != null ? null : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (_endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _endDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_endDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.estrusDurationDays}: ${_calculateDuration()}${l10n.estrusDays(0).replaceAll('0', '')}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusPhase,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EstrusPhase.values.map((phase) {
                final isSelected = _phase == phase;
                return ChoiceChip(
                  label: Text(_getPhaseLabel(phase, l10n)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  onSelected: (selected) {
                    setState(() {
                      _phase = selected ? phase : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDischargeSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusDischargeColor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dischargeColors.map((color) {
                final isSelected = _dischargeColor == color;
                return ChoiceChip(
                  label: Text(color),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  onSelected: (selected) {
                    setState(() {
                      _dischargeColor = selected ? color : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.estrusDischargeAmount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DischargeAmount.values.map((amount) {
                final isSelected = _dischargeAmount == amount;
                return ChoiceChip(
                  label: Text(_getAmountLabel(amount, l10n)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  onSelected: (selected) {
                    setState(() {
                      _dischargeAmount = selected ? amount : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwellingSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusVulvaSwelling,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SwellingLevel.values.map((level) {
                final isSelected = _vulvaSwelling == level;
                return ChoiceChip(
                  label: Text(_getSwellingLabel(level, l10n)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  onSelected: (selected) {
                    setState(() {
                      _vulvaSwelling = selected ? level : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusBehaviorChanges,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _behaviorOptions.map((behavior) {
                final isSelected = _selectedBehaviors.contains(behavior);
                return FilterChip(
                  label: Text(behavior),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  checkmarkColor: const Color(0xFFEC407A),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedBehaviors.add(behavior);
                      } else {
                        _selectedBehaviors.remove(behavior);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusSymptoms,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptomOptions.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFCE4EC),
                  checkmarkColor: const Color(0xFFEC407A),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.estrusNote,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.estrusNote,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  int _calculateDuration() {
    if (_endDate == null) return 0;
    return _endDate!.difference(_startDate).inDays + 1;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 14)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveRecord() {
    final pet = widget.localStore.allPets().firstWhere((p) => p.id == widget.petId);
    final previousRecords = widget.localStore.estrusRecordsByPet(widget.petId);

    final durationDays = _endDate != null ? _calculateDuration() : null;

    final record = EstrusRecord(
      id: widget.existingRecord?.id ?? const Uuid().v4(),
      petId: widget.petId,
      startDate: _startDate,
      endDate: _endDate,
      durationDays: durationDays,
      phase: _phase,
      dischargeColor: _dischargeColor,
      dischargeAmount: _dischargeAmount,
      vulvaSwelling: _vulvaSwelling,
      behaviorChanges: List.from(_selectedBehaviors),
      symptoms: List.from(_selectedSymptoms),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isAbnormal: false,
      abnormalReasons: [],
      isSynced: false,
      createdAt: widget.existingRecord?.createdAt,
      updatedAt: DateTime.now(),
    );

    final abnormalReasons = _estrusService.detectAbnormalReasons(record, previousRecords);
    final finalRecord = record.copyWith(
      isAbnormal: abnormalReasons.isNotEmpty,
      abnormalReasons: abnormalReasons,
    );

    widget.localStore.upsertEstrusRecord(finalRecord);

    Navigator.of(context).pop();
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.estrusDeleteRecord),
        content: Text(l10n.estrusDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.localStore.deleteEstrusRecord(widget.existingRecord!.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
