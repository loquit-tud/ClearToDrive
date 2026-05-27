import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationScheduler {
  Future<void> initialize();
  Future<bool> requestPermissionIfNeeded();
  Future<bool> areNotificationsEnabled();

  Future<void> scheduleZoned({
    required int notificationId,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required String payload,
  });

  Future<void> cancel(int notificationId);
}

class FlutterLocalNotificationsScheduler implements NotificationScheduler {
  FlutterLocalNotificationsScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _defaultIcon = '@mipmap/ic_launcher';

  @override
  Future<void> initialize() async {
    const android = AndroidInitializationSettings(_defaultIcon);
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _plugin.initialize(settings: settings);
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? true;
    }
    // iOS/others: assume enabled (permission UX handled when iOS ships).
    return true;
  }

  @override
  Future<bool> requestPermissionIfNeeded() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final iOS = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iOS != null) {
      final granted = await iOS.requestPermissions(alert: true, sound: true);
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> scheduleZoned({
    required int notificationId,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledAt,
      notificationDetails: details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

