import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_models.dart';
import '../services/local_store.dart';

class HealthFormPage extends StatefulWidget {
  const HealthFormPage({
    super.key,
    this.lockedType,
    this.isPro = false,
    required this.localStore,
    this.existingRecord,
  });

  final RecordType? lockedType;
  final bool isPro;
  final LocalStore localStore;
  final HealthRecord? existingRecord;

  @override
  State<HealthFormPage> createState() => _HealthFormPageState();
}

class _HealthFormPageState extends State<HealthFormPage> {
  late RecordType _type;
  String? _selectedPetId;
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _costController = TextEditingController();
  DateTime _recordDate = DateTime.now();
  DateTime? _nextDueDate;
  List<PetProfile> _pets = [];

  @override
  void initState() {
    super.initState();
    _pets = widget.localStore.allPets();

    if (widget.existingRecord != null) {
      final rec = widget.existingRecord!;
      _type = rec.type;
      _selectedPetId = rec.petId;
      if (rec.title != null) _titleController.text = rec.title!;
      if (rec.note != null) _noteController.text = rec.note!;
      _recordDate = rec.date;
      _nextDueDate = rec.nextDueDate;
    } else {
      _type = widget.lockedType ?? RecordType.vaccine;
      if (_pets.isNotEmpty) {
        _selectedPetId = _pets.first.id;
      }
    }
  }

  String _getTypeName(RecordType type, AppLocalizations l10n) {
    return switch (type) {
      RecordType.vaccine => l10n.typeVaccine,
      RecordType.deworm => l10n.typeDeworm,
      RecordType.checkup => l10n.typeCheckup,
      RecordType.medication => l10n.typeMedication,
      RecordType.bath => l10n.typeBath,
      RecordType.weight => l10n.typeWeight,
      RecordType.other => '其他', // TODO: l10n
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('录入健康记录',
            style: TextStyle(fontWeight: FontWeight.bold)), // TODO: l10n
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_pets.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedPetId,
                decoration: InputDecoration(
                  labelText: '选择宠物',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPetId = value);
                  }
                },
                items: _pets
                    .map((pet) => DropdownMenuItem(
                          value: pet.id,
                          child: Text(pet.name),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<RecordType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: '记录类型', // TODO: l10n
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: widget.lockedType == null
                  ? (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    }
                  : null,
              items: RecordType.values
                  .map((type) => DropdownMenuItem(
                      value: type, child: Text(_getTypeName(type, l10n))))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题', // TODO: l10n
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _recordDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _recordDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '记录日期', // TODO: l10n
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),
                child: Text(dateFormat.format(_recordDate)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextDueDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _nextDueDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '下次提醒日期 (选填)', // TODO: l10n
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),
                child: Text(_nextDueDate == null
                    ? '未设置'
                    : dateFormat.format(_nextDueDate!)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '花费 (选填)', // TODO: l10n
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                prefixText: '¥ ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '备注 (选填)', // TODO: l10n
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_pets.isEmpty || _selectedPetId == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('请先添加宠物')));
                  return;
                }

                final currentRecords = widget.localStore.recordsByType(_type);
                if (widget.existingRecord == null &&
                    !widget.isPro &&
                    currentRecords.length >= 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('免费版每类健康记录最多 10 条记录')));
                  return;
                }

                final newRecord = HealthRecord(
                  id: widget.existingRecord?.id ?? const Uuid().v4(),
                  petId: _selectedPetId!,
                  type: _type,
                  date: _recordDate,
                  nextDueDate: _nextDueDate,
                  note: _noteController.text.isEmpty
                      ? null
                      : _noteController.text,
                  title: _titleController.text.isEmpty
                      ? null
                      : _titleController.text,
                );

                widget.localStore.upsertRecords([newRecord]);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('保存成功')));
                Navigator.of(context).pop();
              },
              child: const Text('保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
