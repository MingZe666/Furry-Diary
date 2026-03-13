import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_models.dart';

import 'package:flutter/foundation.dart';

class LocalStore {
  static const String autoBackupEnabledKey = 'auto_backup_enabled';
  static const String autoBackupFrequencyKey = 'auto_backup_frequency';
  static const String lastAutoBackupAtKey = 'last_auto_backup_at';
  static const String autoBackupFrequencyDaily = 'daily';
  static const String reminderAdvanceDaysKey = 'reminder_advance_days';
  static const String reminderRepeatCycleKey = 'reminder_repeat_cycle';
  static const String reminderChannelsKey = 'reminder_channels';

  static const String reminderRepeatCycleOnce = 'once';
  static const String reminderRepeatCycleDaily = 'daily';
  static const String reminderRepeatCycleWeekly = 'weekly';
  static const String reminderRepeatCycleMonthly = 'monthly';

  static const String reminderChannelPush = 'push';
  static const String reminderChannelSms = 'sms';
  static const String reminderChannelEmail = 'email';

  final ValueNotifier<int> dataChangedNotifier = ValueNotifier<int>(0);

  void notifyDataChanged() {
    dataChangedNotifier.value++;
  }

  static const String userBoxName = 'user_box';
  static const String recordsBoxName = 'records_box';
  static const String syncBoxName = 'sync_box';
  static const String petsBoxName = 'pets_box';
  static const String estrusBoxName = 'estrus_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(userBoxName);
    await Hive.openBox<Map>(recordsBoxName);
    await Hive.openBox<String>(syncBoxName);
    await Hive.openBox<Map>(petsBoxName);
    await Hive.openBox<Map>(estrusBoxName);
  }

  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<Map>(userBoxName);
    await box.put('current', user.toJson());
  }

  UserModel? getCurrentUser() {
    final raw = Hive.box<Map>(userBoxName).get('current');
    if (raw == null) {
      return null;
    }
    return UserModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> clearUser() async {
    final box = Hive.box<Map>(userBoxName);
    await box.delete('current');
  }

  Future<void> upsertRecords(List<HealthRecord> records) async {
    final box = Hive.box<Map>(recordsBoxName);
    for (final record in records) {
      await box.put(record.id, record.toJson());
    }
    notifyDataChanged();
  }

  Future<void> deleteRecord(String recordId) async {
    final box = Hive.box<Map>(recordsBoxName);
    await box.delete(recordId);
    notifyDataChanged();
  }

  List<HealthRecord> allRecords() {
    final box = Hive.box<Map>(recordsBoxName);
    return box.values
        .map((value) => HealthRecord.fromJson(Map<String, dynamic>.from(value)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<HealthRecord> recordsByType(RecordType type) {
    return allRecords().where((record) => record.type == type).toList();
  }

  Future<void> saveLastSyncedAt(DateTime time) async {
    await Hive.box<String>(syncBoxName)
        .put('last_synced_at', time.toIso8601String());
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    await Hive.box<String>(syncBoxName)
        .put(autoBackupEnabledKey, enabled ? '1' : '0');
  }

  bool getAutoBackupEnabled() {
    final value = Hive.box<String>(syncBoxName).get(autoBackupEnabledKey);
    return value == '1';
  }

  Future<void> setAutoBackupFrequency(String frequency) async {
    await Hive.box<String>(syncBoxName).put(autoBackupFrequencyKey, frequency);
  }

  String getAutoBackupFrequency() {
    return Hive.box<String>(syncBoxName).get(autoBackupFrequencyKey) ??
        autoBackupFrequencyDaily;
  }

  Future<void> setReminderAdvanceDays(int days) async {
    await Hive.box<String>(syncBoxName).put(reminderAdvanceDaysKey, '$days');
  }

  int getReminderAdvanceDays() {
    final value = Hive.box<String>(syncBoxName).get(reminderAdvanceDaysKey);
    final parsed = value == null ? null : int.tryParse(value);
    return parsed ?? 3;
  }

  Future<void> setReminderRepeatCycle(String cycle) async {
    await Hive.box<String>(syncBoxName).put(reminderRepeatCycleKey, cycle);
  }

  String getReminderRepeatCycle() {
    return Hive.box<String>(syncBoxName).get(reminderRepeatCycleKey) ??
        reminderRepeatCycleOnce;
  }

  Future<void> setReminderChannels(Set<String> channels) async {
    final sorted = channels.toList()..sort();
    await Hive.box<String>(syncBoxName).put(reminderChannelsKey, sorted.join(','));
  }

  Set<String> getReminderChannels() {
    final value = Hive.box<String>(syncBoxName).get(reminderChannelsKey);
    if (value == null || value.trim().isEmpty) {
      return {reminderChannelPush};
    }
    final channels = value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    if (channels.isEmpty) {
      return {reminderChannelPush};
    }
    return channels;
  }

  Future<void> saveLastAutoBackupAt(DateTime time) async {
    await Hive.box<String>(syncBoxName)
        .put(lastAutoBackupAtKey, time.toIso8601String());
  }

  DateTime? getLastAutoBackupAt() {
    final value = Hive.box<String>(syncBoxName).get(lastAutoBackupAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  DateTime? getLastSyncedAt() {
    final value = Hive.box<String>(syncBoxName).get('last_synced_at');
    return value == null ? null : DateTime.tryParse(value);
  }

  List<PetProfile> allPets() {
    final box = Hive.box<Map>(petsBoxName);
    return box.values
        .map((value) => PetProfile.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> upsertPet(PetProfile pet) async {
    final box = Hive.box<Map>(petsBoxName);
    await box.put(pet.id, pet.toJson());
    notifyDataChanged();
  }

  Future<void> deletePet(String petId) async {
    final box = Hive.box<Map>(petsBoxName);
    await box.delete(petId);

    // 级联删除该宠物的所有健康记录
    final recBox = Hive.box<Map>(recordsBoxName);
    final keysToDelete = recBox.keys.where((key) {
      final value = recBox.get(key);
      if (value != null) {
        final record = HealthRecord.fromJson(Map<String, dynamic>.from(value));
        return record.petId == petId;
      }
      return false;
    }).toList();

    await recBox.deleteAll(keysToDelete);
    notifyDataChanged();
  }

  Future<Map<String, dynamic>> exportDataMap() async {
    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'pets': allPets().map((e) => e.toJson()).toList(),
      'records': allRecords().map((e) => e.toJson()).toList(),
      'reminder_settings': {
        'advance_days': getReminderAdvanceDays(),
        'repeat_cycle': getReminderRepeatCycle(),
        'channels': getReminderChannels().toList(),
      },
    };
  }

  Future<void> importDataMap(Map<String, dynamic> data) async {
    // 导入宠物
    if (data.containsKey('pets') && data['pets'] is List) {
      final petBox = Hive.box<Map>(petsBoxName);
      await petBox.clear();
      for (final petJson in data['pets']) {
        final pet = PetProfile.fromJson(Map<String, dynamic>.from(petJson));
        await petBox.put(pet.id, pet.toJson());
      }
    }

    // 导入记录
    if (data.containsKey('records') && data['records'] is List) {
      final recBox = Hive.box<Map>(recordsBoxName);
      await recBox.clear();
      for (final recJson in data['records']) {
        final rec = HealthRecord.fromJson(Map<String, dynamic>.from(recJson));
        await recBox.put(rec.id, rec.toJson());
      }
    }

    if (data.containsKey('reminder_settings') &&
        data['reminder_settings'] is Map) {
      final reminderSettings =
          Map<String, dynamic>.from(data['reminder_settings']);
      final advanceDays = reminderSettings['advance_days'];
      if (advanceDays is int) {
        await setReminderAdvanceDays(advanceDays);
      }
      final repeatCycle = reminderSettings['repeat_cycle'];
      if (repeatCycle is String && repeatCycle.isNotEmpty) {
        await setReminderRepeatCycle(repeatCycle);
      }
      final channels = reminderSettings['channels'];
      if (channels is List) {
        final parsedChannels = channels
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet();
        if (parsedChannels.isNotEmpty) {
          await setReminderChannels(parsedChannels);
        }
      }
    }

    notifyDataChanged();
  }

  List<EstrusRecord> allEstrusRecords() {
    final box = Hive.box<Map>(estrusBoxName);
    return box.values
        .map((value) => EstrusRecord.fromJson(Map<String, dynamic>.from(value)))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  List<EstrusRecord> estrusRecordsByPet(String petId) {
    return allEstrusRecords().where((record) => record.petId == petId).toList();
  }

  Future<void> upsertEstrusRecord(EstrusRecord record) async {
    final box = Hive.box<Map>(estrusBoxName);
    await box.put(record.id, record.toJson());
    notifyDataChanged();
  }

  Future<void> upsertEstrusRecords(List<EstrusRecord> records) async {
    final box = Hive.box<Map>(estrusBoxName);
    for (final record in records) {
      await box.put(record.id, record.toJson());
    }
    notifyDataChanged();
  }

  Future<void> deleteEstrusRecord(String recordId) async {
    final box = Hive.box<Map>(estrusBoxName);
    await box.delete(recordId);
    notifyDataChanged();
  }

  EstrusRecord? getEstrusRecord(String recordId) {
    final box = Hive.box<Map>(estrusBoxName);
    final raw = box.get(recordId);
    if (raw == null) return null;
    return EstrusRecord.fromJson(Map<String, dynamic>.from(raw));
  }
}
