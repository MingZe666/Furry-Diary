import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/app_models.dart';
import 'local_store.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleReminder(
    HealthRecord record,
    String petName,
    LocalStore localStore,
  ) async {
    final due = record.nextDueDate;
    if (due == null) {
      return;
    }

    final channels = localStore.getReminderChannels();
    if (!channels.contains(LocalStore.reminderChannelPush)) {
      return;
    }

    final advanceDays = localStore.getReminderAdvanceDays();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'health_reminders',
        'Health Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      record.id.hashCode,
      '$petName ${record.type.name} 提醒',
      '请在${advanceDays == 0 ? '当天' : '提前$advanceDays天'}关注 ${record.type.name} 事项',
      details,
    );
  }
}
