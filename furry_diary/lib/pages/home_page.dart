import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/local_store.dart';
import '../models/app_models.dart';
import '../providers/auth_provider.dart';
import 'health_record_detail_page.dart';
import 'health_form_page.dart';
import 'pet_profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    required this.localStore,
    this.bottomNavigationBar,
  });

  final LocalStore localStore;
  final Widget? bottomNavigationBar;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<PetProfile> pets = [];
  List<HealthRecord> upcomingRecords = [];

  void _onDataChanged() {
    if (!mounted) {
      return;
    }
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localStore != widget.localStore) {
      oldWidget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
      widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
      _loadData();
    }
  }

  @override
  void dispose() {
    widget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _loadData() {
    final now = DateTime.now();
    final advanceDays = widget.localStore.getReminderAdvanceDays();
    // 自定义提前天数内到期或已过期的待办
    final allRecords = widget.localStore.allRecords();
    final urgentReminders = allRecords.where((r) {
      if (r.nextDueDate == null) return false;
      final daysDiff = r.nextDueDate!.difference(now).inDays;
      return daysDiff <= advanceDays;
    }).toList();

    // 按照紧急程度（时间先后）排序
    urgentReminders.sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));

    setState(() {
      pets = widget.localStore.allPets();
      upcomingRecords = urgentReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final isProUser = user?.isPro ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.homeTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              _buildPetsSection(context, l10n, theme)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              _buildUpcomingReminders(context, l10n, theme, isProUser)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthFormPage(
                localStore: widget.localStore,
                isPro: isProUser,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }

  Widget _buildPetsSection(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    if (pets.isEmpty) {
      return GestureDetector(
        onTap: () {
          final user = ref.read(authProvider);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetProfilePage(
                localStore: widget.localStore,
                isPro: user?.isPro ?? false,
              ),
            ),
          ).then((_) => _loadData());
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pets_rounded,
                        size: 48, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.addPetDesc,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetProfilePage(
                    localStore: widget.localStore,
                    isPro: ref.read(authProvider)?.isPro ?? false,
                    initialPetId: pet.id,
                  ),
                ),
              ).then((_) => _loadData());
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Hero(
                    tag: 'pet_avatar_${pet.id}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: pet.avatarPath != null
                          ? FileImage(File(pet.avatarPath!))
                          : null,
                      child: pet.avatarPath == null
                          ? Icon(Icons.pets,
                              size: 32,
                              color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingReminders(BuildContext context, AppLocalizations l10n,
      ThemeData theme, bool isProUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthRecordsTitle,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (upcomingRecords.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_available_rounded,
                          size: 48, color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noRecords,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingRecords.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = upcomingRecords[index];
              final pet = pets.firstWhere((p) => p.id == record.petId,
                  orElse: () => PetProfile(
                        id: '',
                        name: '未知宠物',
                      ));
              final formattedDate = record.nextDueDate != null
                  ? DateFormat('yyyy-MM-dd').format(record.nextDueDate!)
                  : '';

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.vaccines, color: Colors.redAccent),
                  title: Text(record.title ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${pet.name} · 到期: $formattedDate'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthRecordDetailPage(
                          recordId: record.id,
                          localStore: widget.localStore,
                          isPro: isProUser,
                          typeName: record.type.toString().split('.').last,
                          petName: pet.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
