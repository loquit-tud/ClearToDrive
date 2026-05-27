import 'package:cleartodrive/application/use_cases/send_test_notification_use_case.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

class FakeScheduler implements NotificationScheduler {
  var initialized = false;
  int? lastId;
  String? lastTitle;
  tz.TZDateTime? lastScheduledAt;
  var cancelCalls = 0;

  @override
  Future<bool> areNotificationsEnabled() async => true;

  @override
  Future<void> cancel(int notificationId) async {
    cancelCalls++;
  }

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermissionIfNeeded() async => true;

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
    lastId = notificationId;
    lastTitle = title;
    lastScheduledAt = scheduledAt;
  }
}

void main() {
  test('SendTestNotificationUseCase schedules a near-immediate notification', () async {
    final scheduler = FakeScheduler();
    final useCase = SendTestNotificationUseCase(scheduler);

    await useCase.execute();

    expect(scheduler.initialized, isTrue);
    expect(scheduler.cancelCalls, 1);
    expect(scheduler.lastId, isNotNull);
    expect(scheduler.lastTitle, 'Notificare de test');
    expect(scheduler.lastScheduledAt, isNotNull);
  });
}

