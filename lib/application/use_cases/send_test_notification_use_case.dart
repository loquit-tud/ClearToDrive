import 'dart:convert';

import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:cleartodrive/data/services/timezone_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SendTestNotificationUseCase {
  SendTestNotificationUseCase(this._scheduler);

  final NotificationScheduler _scheduler;

  static const _channelId = 'qa_debug';
  static const _channelName = 'QA / Debug';

  Future<void> execute() async {
    await TimezoneService.ensureInitialized();
    await _scheduler.initialize();

    final notificationId = _testNotificationId();
    await _scheduler.cancel(notificationId);

    final payload = jsonEncode({'type': 'test'});
    final scheduledAt = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));

    await _scheduler.scheduleZoned(
      notificationId: notificationId,
      channelId: _channelId,
      channelName: _channelName,
      title: 'Notificare de test',
      body: 'Dacă vezi acest mesaj, notificările funcționează.',
      scheduledAt: scheduledAt,
      payload: payload,
    );
  }

  static int _testNotificationId() {
    // Stable id so QA can retry without stacking.
    return 'cleartodrive_test_notification'.hashCode & 0x7fffffff;
  }
}

