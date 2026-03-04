import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/generated/app_localizations.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../services/local_store.dart';
import '../navigation/pro_upgrade_flow.dart';

class PetProfilePage extends StatefulWidget {
  const PetProfilePage({
    super.key,
    required this.localStore,
    required this.isPro,
    this.bottomNavigationBar,
    this.initialPetId,
  });

  final LocalStore localStore;
  final bool isPro;
  final Widget? bottomNavigationBar;
  final String? initialPetId;

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  List<PetProfile> pets = [];
  final ImagePicker imagePicker = ImagePicker();

  void _reloadPets() {
    if (!mounted) {
      return;
    }
    setState(() {
      pets = widget.localStore.allPets();
    });
  }

  void _onDataChanged() {
    _reloadPets();
  }

  @override
  void initState() {
    super.initState();
    widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
    pets = widget.localStore.allPets();
  }

  @override
  void didUpdateWidget(covariant PetProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localStore != widget.localStore) {
      oldWidget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
      widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
      _reloadPets();
    }
  }

  @override
  void dispose() {
    widget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> openPetEditor({PetProfile? existing}) async {
    if (existing == null && !widget.isPro && pets.length >= 2) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('升级 Pro 会员',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content:
              const Text('免费用户最多只能添加 2 只宠物。\n\n升级 Pro 测试您的会员权限，无限制添加，解锁更多关爱！'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('暂时不要')),
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

    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final breedController = TextEditingController(text: existing?.breed ?? '');
    final weightController =
        TextEditingController(text: existing?.weight?.toString() ?? '');
    String? avatarPath = existing?.avatarPath;
    String? selectedType = existing?.type ?? 'Cat';
    String? selectedGender = existing?.gender ?? 'Boy';
    bool? isNeutered = existing?.isNeutered ?? false;
    DateTime? birthday = existing?.birthday;
    DateTime? adoptionDate = existing?.adoptionDate;
    final dateFormat = DateFormat('yyyy-MM-dd');

    final saved = await showDialog<PetProfile>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? l10n.addPet : l10n.editPet),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    if (picked != null) {
                      dialogSetState(() {
                        avatarPath = picked.path;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: avatarPath == null
                        ? null
                        : FileImage(File(avatarPath!)),
                    child: avatarPath == null
                        ? Icon(Icons.add_a_photo,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.selectAvatar,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.petName,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: '宠物类型', // TODO: l10n
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Cat', child: Text('猫咪')),
                          DropdownMenuItem(value: 'Dog', child: Text('狗狗')),
                          DropdownMenuItem(value: 'Other', child: Text('其他')),
                        ],
                        onChanged: (val) =>
                            dialogSetState(() => selectedType = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: breedController,
                        decoration: InputDecoration(
                          labelText: l10n.petBreed,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedGender,
                        decoration: InputDecoration(
                          labelText: l10n.petGender,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Boy', child: Text('弟弟')),
                          DropdownMenuItem(value: 'Girl', child: Text('妹妹')),
                        ],
                        onChanged: (val) =>
                            dialogSetState(() => selectedGender = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        initialValue: isNeutered,
                        decoration: InputDecoration(
                          labelText: '是否绝育', // TODO: l10n
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        items: const [
                          DropdownMenuItem(value: true, child: Text('已绝育')),
                          DropdownMenuItem(value: false, child: Text('未绝育')),
                        ],
                        onChanged: (val) =>
                            dialogSetState(() => isNeutered = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '体重 (kg)', // TODO: l10n
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: birthday ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dialogSetState(() => birthday = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '生日', // TODO: l10n
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Text(birthday == null
                        ? '未设置'
                        : dateFormat.format(birthday!)),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: adoptionDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dialogSetState(() => adoptionDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '收养时间', // TODO: l10n
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Text(adoptionDate == null
                        ? '未设置'
                        : dateFormat.format(adoptionDate!)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(
                  context,
                  PetProfile(
                    id: existing?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    avatarPath: avatarPath,
                    type: selectedType,
                    breed: breedController.text.trim().isEmpty
                        ? null
                        : breedController.text.trim(),
                    gender: selectedGender,
                    isNeutered: isNeutered,
                    weight: double.tryParse(weightController.text.trim()),
                    color: existing?.color,
                    chipNo: existing?.chipNo,
                    birthday: birthday,
                    adoptionDate: adoptionDate,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved == null) {
      return;
    }

    await widget.localStore.upsertPet(saved);
    _reloadPets();
  }

  Future<void> deletePet(PetProfile pet) async {
    await widget.localStore.deletePet(pet.id);
    _reloadPets();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.petProfilesTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.addPetDesc,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pets.length,
              itemBuilder: (_, index) {
                final pet = pets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: ValueKey(pet.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete_sweep,
                          color: Colors.white, size: 32),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(l10n.delete),
                            content: Text(l10n.deleteConfirm),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel)),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(l10n.delete,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (_) => deletePet(pet),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => openPetEditor(existing: pet),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'avatar_${pet.id}',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                          width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundColor: theme
                                          .colorScheme.primaryContainer
                                          .withValues(alpha: 0.5),
                                      backgroundImage: pet.avatarPath == null
                                          ? null
                                          : FileImage(File(pet.avatarPath!)),
                                      child: pet.avatarPath == null
                                          ? Icon(Icons.pets,
                                              size: 36,
                                              color: theme.colorScheme.primary)
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            pet.name,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          if (pet.gender != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              pet.gender == 'Boy' ||
                                                      pet.gender == '公' ||
                                                      pet.gender == 'Male'
                                                  ? Icons.male
                                                  : (pet.gender == 'Girl' ||
                                                          pet.gender == '母' ||
                                                          pet.gender == 'Female'
                                                      ? Icons.female
                                                      : Icons.help_outline),
                                              color: pet.gender == 'Boy' ||
                                                      pet.gender == '公' ||
                                                      pet.gender == 'Male'
                                                  ? Colors.blue
                                                  : (pet.gender == 'Girl' ||
                                                          pet.gender == '母' ||
                                                          pet.gender == 'Female'
                                                      ? Colors.pink
                                                      : Colors.grey),
                                              size: 20,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          if (pet.type != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme
                                                    .tertiaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                pet.type == 'Cat'
                                                    ? '猫咪'
                                                    : (pet.type == 'Dog'
                                                        ? '狗狗'
                                                        : '其他'),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onTertiaryContainer,
                                                ),
                                              ),
                                            ),
                                          if (pet.breed != null &&
                                              pet.breed!.isNotEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                pet.breed!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                              ),
                                            ),
                                          if (pet.isNeutered != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme
                                                    .secondaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                pet.isNeutered! ? '已绝育' : '未绝育',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          if (pet.weight != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${pet.weight} kg',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openPetEditor(),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPet),
      )
          .animate()
          .scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
