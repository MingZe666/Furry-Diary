import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import 'local_store.dart';
import 'network_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  offline,
}

class SyncManager {
  SyncManager(this._dio, this._localStore);

  final Dio _dio;
  final LocalStore _localStore;
  
  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;
  String? _lastError;
  Timer? _autoSyncTimer;

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get currentStatus => _currentStatus;
  String? get lastError => _lastError;
  DateTime? get lastSyncedAt => _localStore.getLastSyncedAt();

  void startAutoSync({int intervalMinutes = 5}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (_) => syncAll(),
    );
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<void> syncAll() async {
    if (_currentStatus == SyncStatus.syncing) return;

    _updateStatus(SyncStatus.syncing);
    _lastError = null;

    try {
      await syncUp();
      await syncDown();
      _updateStatus(SyncStatus.success);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _updateStatus(SyncStatus.offline);
      } else {
        _lastError = e.message ?? '同步失败';
        _updateStatus(SyncStatus.failed);
      }
    } catch (e) {
      _lastError = e.toString();
      _updateStatus(SyncStatus.failed);
    }
  }

  Future<void> syncUp() async {
    final pets = _localStore.allPets();
    final records = _localStore.allRecords();

    final dirtyPets = pets.where((p) => !p.isSynced).toList();
    final dirtyRecords = records.where((r) => !r.isSynced).toList();

    if (dirtyPets.isEmpty && dirtyRecords.isEmpty) return;

    final response = await _dio.post('/api/v1/sync/upload', data: {
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'pets': dirtyPets.map((p) => {
        'id': p.id,
        'name': p.name,
        'type': p.type,
        'breed': p.breed,
        'gender': p.gender,
        'color': p.color,
        'chip_no': p.chipNo,
        'avatar_url': p.avatarPath,
        'birthday': p.birthday?.toIso8601String(),
        'updated_at': p.updatedAt?.toIso8601String(),
        'deleted_at': p.deletedAt?.toIso8601String(),
      }).toList(),
      'records': dirtyRecords.map((r) => {
        'id': r.id,
        'pet_id': r.petId,
        'type': r.type.name,
        'title': r.title,
        'note': r.note,
        'date': r.date.toIso8601String(),
        'next_due_date': r.nextDueDate?.toIso8601String(),
        'updated_at': r.updatedAt.toIso8601String(),
        'deleted_at': r.deletedAt?.toIso8601String(),
      }).toList(),
    });

    for (final record in dirtyRecords) {
      record.isSynced = true;
    }
    await _localStore.upsertRecords(dirtyRecords);

    // 同步成功后更新宠物的 isSynced 状态
    for (final pet in dirtyPets) {
      final syncedPet = pet.copyWith(isSynced: true);
      await _localStore.upsertPet(syncedPet);
    }

    final syncedAt = DateTime.parse(response.data['synced_at']);
    await _localStore.saveLastSyncedAt(syncedAt);
  }

  Future<void> syncDown() async {
    final response = await _dio.get(
      '/api/v1/sync/download',
      queryParameters: {
        'last_synced_at': lastSyncedAt?.toIso8601String(),
      },
    );

    final petsData = response.data['pets'] as List;
    final recordsData = response.data['records'] as List;

    final serverPets = petsData.map((p) => PetProfile.fromJson(Map<String, dynamic>.from(p))).toList();
    final serverRecords = recordsData.map((r) => HealthRecord.fromJson(Map<String, dynamic>.from(r))).toList();

    for (final serverPet in serverPets) {
      if (serverPet.deletedAt != null) {
        // 删除本地宠物
        await _localStore.deletePet(serverPet.id);
      } else {
        await _localStore.upsertPet(serverPet);
      }
    }

    for (final serverRecord in serverRecords) {
      if (serverRecord.deletedAt != null) {
        await _localStore.deleteRecord(serverRecord.id);
      } else {
        serverRecord.isSynced = true;
        await _localStore.upsertRecords([serverRecord]);
      }
    }

    final syncedAt = DateTime.parse(response.data['synced_at']);
    await _localStore.saveLastSyncedAt(syncedAt);
  }

  Future<void> syncNow() async {
    final dirty =
        _localStore.allRecords().where((record) => !record.isSynced).toList();
    final payload =
        SyncPayload(lastSyncedAt: lastSyncedAt, dirty: dirty).toJson();

    final response = await _dio.post('/api/v1/sync', data: payload);
    final updates = (response.data['records'] as List<dynamic>)
        .map((item) =>
            HealthRecord.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    for (final record in dirty) {
      record.isSynced = true;
      record.updatedAt = DateTime.now();
    }

    await _localStore.upsertRecords([...updates, ...dirty]);
    await _localStore.saveLastSyncedAt(DateTime.now());
  }

  Future<void> mergeGuestDataAfterLogin() async {
    final localPets = _localStore.allPets();
    final localRecords = _localStore.allRecords();

    if (localPets.isEmpty && localRecords.isEmpty) {
      return;
    }

    try {
      await _dio.post('/api/v1/sync/upload', data: {
        'last_synced_at': null,
        'pets': localPets.map((p) => {
          'id': p.id,
          'name': p.name,
          'type': p.type,
          'breed': p.breed,
          'gender': p.gender,
          'color': p.color,
          'chip_no': p.chipNo,
          'avatar_url': p.avatarPath,
          'birthday': p.birthday?.toIso8601String(),
          'updated_at': p.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }).toList(),
        'records': localRecords.map((r) => {
          'id': r.id,
          'pet_id': r.petId,
          'type': r.type.name,
          'title': r.title,
          'note': r.note,
          'date': r.date.toIso8601String(),
          'next_due_date': r.nextDueDate?.toIso8601String(),
          'updated_at': r.updatedAt.toIso8601String(),
        }).toList(),
      });

      for (final record in localRecords) {
        record.isSynced = true;
      }
      await _localStore.upsertRecords(localRecords);
      await _localStore.saveLastSyncedAt(DateTime.now());
    } catch (e) {
      // 合并失败不影响登录流程
    }
  }

  void dispose() {
    _autoSyncTimer?.cancel();
    _statusController.close();
  }
}

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.statusStream;
});
