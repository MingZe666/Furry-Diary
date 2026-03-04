import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/app_models.dart';
import '../services/local_store.dart';
import '../navigation/pro_upgrade_flow.dart';
import 'health_form_page.dart';
import 'health_record_detail_page.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({
    super.key,
    required this.localStore,
    required this.type,
    required this.isPro,
  });

  final LocalStore localStore;
  final RecordType type;
  final bool isPro;

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final Set<String> _deletingRecordIds = <String>{};
  List<HealthRecord> _visibleRecords = <HealthRecord>[];

  @override
  void initState() {
    super.initState();
    _reloadRecords();
  }

  @override
  void didUpdateWidget(covariant TimelinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.localStore != widget.localStore) {
      _reloadRecords();
    }
  }

  void _reloadRecords() {
    _visibleRecords = widget.localStore.recordsByType(widget.type);
  }

  String _getTypeName(RecordType type) {
    switch (type) {
      case RecordType.vaccine:
        return '疫苗';
      case RecordType.deworm:
        return '驱虫';
      case RecordType.checkup:
        return '体检';
      case RecordType.medication:
        return '用药';
      case RecordType.bath:
        return '洗澡';
      case RecordType.weight:
        return '体重';
      case RecordType.other:
        return '其他';
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _visibleRecords;
    final petsById = {
      for (final pet in widget.localStore.allPets()) pet.id: pet.name,
    };
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('${_getTypeName(widget.type)}记录',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('暂无记录',
                      style: TextStyle(
                          color: theme.colorScheme.outline, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (_, index) {
                final record = records[index];
                final petName = petsById[record.petId];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Slidable(
                    key: ValueKey('slidable_${record.id}'),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (actionContext) async {
                            if (_deletingRecordIds.contains(record.id)) {
                              return;
                            }

                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final removedIndex =
                                records.indexWhere((r) => r.id == record.id);
                            final removedRecord = removedIndex >= 0
                                ? records[removedIndex]
                                : null;

                            setState(() {
                              _deletingRecordIds.add(record.id);
                              if (removedIndex >= 0) {
                                _visibleRecords.removeAt(removedIndex);
                              }
                            });

                            try {
                              await widget.localStore.deleteRecord(record.id);

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _deletingRecordIds.remove(record.id);
                              });
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('记录已删除')),
                              );
                            } catch (e) {
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _deletingRecordIds.remove(record.id);
                                if (removedRecord != null) {
                                  final insertIndex = removedIndex >= 0 &&
                                          removedIndex <= _visibleRecords.length
                                      ? removedIndex
                                      : _visibleRecords.length;
                                  _visibleRecords.insert(
                                      insertIndex, removedRecord);
                                }
                              });
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('删除失败：$e')),
                              );
                            }
                          },
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: '删除',
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ],
                    ),
                    child: Card(
                      key: ValueKey(record.id),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => HealthRecordDetailPage(
                                recordId: record.id,
                                localStore: widget.localStore,
                                isPro: widget.isPro,
                                typeName: _getTypeName(widget.type),
                                petName: petName,
                              ),
                            ),
                          )
                              .then((_) {
                            if (mounted) {
                              setState(() {
                                _reloadRecords();
                              });
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 48), // leave space for pet name
                                    child: Text(
                                      record.title ?? _getTypeName(widget.type),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14,
                                          color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(dateFormat
                                          .format(record.date.toLocal())),
                                    ],
                                  ),
                                  if (record.note != null &&
                                      record.note!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      record.note!,
                                      style: TextStyle(color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (petName != null)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    petName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!widget.isPro && records.length >= 10) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('升级 Pro 会员',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content:
                    const Text('免费用户每类健康记录最多只可添加 10 条。\n\n升级 Pro 会员即可畅享无限制记录。'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('暂时不要')),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await openProUpgradeFlow(context);
                    },
                    child: const Text('了解 Pro'),
                  ),
                ],
              ),
            );
            return;
          }

          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return HealthFormPage(
                lockedType: widget.type,
                isPro: widget.isPro,
                localStore: widget.localStore);
          })).then((_) {
            setState(() {
              _reloadRecords();
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
