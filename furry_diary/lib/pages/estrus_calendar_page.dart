import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../services/estrus_service.dart';
import 'estrus_detail_page.dart';

class EstrusCalendarPage extends StatefulWidget {
  const EstrusCalendarPage({
    super.key,
    required this.localStore,
    required this.petId,
  });

  final LocalStore localStore;
  final String petId;

  @override
  State<EstrusCalendarPage> createState() => _EstrusCalendarPageState();
}

class _EstrusCalendarPageState extends State<EstrusCalendarPage> {
  late DateTime _currentMonth;
  late List<EstrusRecord> _records;
  EstrusPrediction? _prediction;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadData();
    widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
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
    _records = widget.localStore.estrusRecordsByPet(widget.petId);
    final pet = widget.localStore.allPets().firstWhere((p) => p.id == widget.petId);
    final estrusService = EstrusService(widget.localStore);
    _prediction = estrusService.predictNextEstrus(
      _records,
      species: pet.type,
      breed: pet.breed,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.estrusCalendar,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildLegend(l10n, colorScheme),
          _buildMonthNavigation(l10n, colorScheme),
          _buildCalendarHeader(l10n, colorScheme),
          Expanded(
            child: _buildCalendarGrid(l10n, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: const Color(0xFFFCE4EC),
            text: l10n.estrusProestrus,
          ),
          _buildLegendItem(
            color: const Color(0xFFF8BBD9),
            text: l10n.estrusEstrus,
          ),
          _buildLegendItem(
            color: const Color(0xFFEF9A9A),
            text: l10n.estrusDiestrus,
          ),
          _buildLegendItem(
            color: Colors.grey.withOpacity(0.3),
            text: l10n.estrusPredicted,
            isDashed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isDashed
                ? Border.all(color: Colors.grey, width: 1, style: BorderStyle.solid)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMonthNavigation(AppLocalizations l10n, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            '${_currentMonth.year}年${_currentMonth.month}月',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(AppLocalizations l10n, ColorScheme colorScheme) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(AppLocalizations l10n, ColorScheme colorScheme) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    for (var i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildDayCell(date, l10n, colorScheme));
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(16),
      children: days,
    );
  }

  Widget _buildDayCell(DateTime date, AppLocalizations l10n, ColorScheme colorScheme) {
    final records = _getRecordsForDate(date);
    final isPredicted = _isPredictedDate(date);
    final isToday = _isToday(date);

    Color? backgroundColor;
    Color? textColor;
    EstrusRecord? recordForDay;
    EstrusPhase? phaseForDay;

    if (records.isNotEmpty) {
      recordForDay = records.first;
      phaseForDay = recordForDay.phase ?? EstrusPhase.estrus;
      backgroundColor = _getPhaseColor(phaseForDay);
      textColor = Colors.black87;
    } else if (isPredicted) {
      backgroundColor = Colors.grey.withOpacity(0.3);
      textColor = colorScheme.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: recordForDay != null
          ? () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EstrusDetailPage(
                  localStore: widget.localStore,
                  record: recordForDay!,
                  isPro: false,
                ),
              ));
            }
          : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: const Color(0xFFEC407A), width: 2)
              : null,
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: textColor ?? colorScheme.onSurface,
                ),
              ),
              if (isPredicted && records.isEmpty)
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<EstrusRecord> _getRecordsForDate(DateTime date) {
    return _records.where((record) {
      if (record.endDate != null) {
        return date.isAfter(record.startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(record.endDate!.add(const Duration(days: 1)));
      } else {
        return date.year == record.startDate.year &&
            date.month == record.startDate.month &&
            date.day == record.startDate.day;
      }
    }).toList();
  }

  bool _isPredictedDate(DateTime date) {
    if (_prediction == null) return false;
    final predictedStart = _prediction!.predictedDate;
    final predictedEnd = _prediction!.predictedEndDate;

    return date.isAfter(predictedStart.subtract(const Duration(days: 1))) &&
        date.isBefore(predictedEnd.add(const Duration(days: 1)));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Color _getPhaseColor(EstrusPhase phase) {
    switch (phase) {
      case EstrusPhase.proestrus:
        return const Color(0xFFFCE4EC);
      case EstrusPhase.estrus:
        return const Color(0xFFF8BBD9);
      case EstrusPhase.diestrus:
        return const Color(0xFFEF9A9A);
      case EstrusPhase.anestrus:
        return Colors.grey.withOpacity(0.3);
    }
  }
}
