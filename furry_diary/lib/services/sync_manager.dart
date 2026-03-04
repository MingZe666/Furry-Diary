import 'package:dio/dio.dart';

import '../models/app_models.dart';
import 'local_store.dart';

class SyncManager {
  SyncManager(this._dio, this._localStore);

  final Dio _dio;
  final LocalStore _localStore;

  DateTime? get lastSyncedAt => _localStore.getLastSyncedAt();

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
    final localData = _localStore.allRecords();
    if (localData.isEmpty) {
      return;
    }

    await _dio.post('/api/v1/sync', data: {
      'lastSyncedAt': null,
      'dirty': localData.map((e) => e.toJson()).toList()
    });
    for (final record in localData) {
      record.isSynced = true;
    }
    await _localStore.upsertRecords(localData);
    await _localStore.saveLastSyncedAt(DateTime.now());
  }
}
