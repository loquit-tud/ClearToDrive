import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/data/repositories/drift_reminder_schedule_repository.dart';
import 'package:cleartodrive/data/services/local_reminder_service.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

class FakeScheduler implements NotificationScheduler {
  final scheduled = <int, tz.TZDateTime>{};
  final cancelled = <int>[];
  var enabled = true;

  @override
  Future<bool> areNotificationsEnabled() async => enabled;

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
    scheduled.remove(notificationId);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissionIfNeeded() async => enabled;

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
    scheduled[notificationId] = scheduledAt;
  }
}

void main() {
  test('LocalReminderService is idempotent on reschedule', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final schedulesRepo = DriftReminderScheduleRepository(db);
    final scheduler = FakeScheduler();
    final service = LocalReminderService(schedulesRepo, scheduler);

    final doc = VehicleDocument(
      id: 'doc1',
      vehicleId: 'veh1',
      type: DocumentType.rca,
      expiryDate: DateTime.now().add(const Duration(days: 40)),
      source: DocumentSource.manual,
      confirmedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await service.scheduleForDocument(doc, const ReminderPolicy(daysBefore: {30, 14, 7, 1}));
    final firstSchedules = await schedulesRepo.getForDocument('doc1');
    expect(firstSchedules.length, 4);

    final firstIds = firstSchedules.map((s) => s.notificationId).toSet();
    expect(firstIds.length, 4);

    // Reschedule same doc should cancel + recreate with same notification ids.
    await service.scheduleForDocument(doc, const ReminderPolicy(daysBefore: {30, 14, 7, 1}));
    final secondSchedules = await schedulesRepo.getForDocument('doc1');
    final secondIds = secondSchedules.map((s) => s.notificationId).toSet();
    expect(secondIds, firstIds);

    await db.close();
  });

  test('LocalReminderService does not crash when notifications are disabled', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final schedulesRepo = DriftReminderScheduleRepository(db);
    final scheduler = FakeScheduler()..enabled = false;
    final service = LocalReminderService(schedulesRepo, scheduler);

    final doc = VehicleDocument(
      id: 'doc2',
      vehicleId: 'veh1',
      type: DocumentType.rovinieta,
      expiryDate: DateTime.now().add(const Duration(days: 40)),
      source: DocumentSource.manual,
      confirmedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await service.scheduleForDocument(
      doc,
      const ReminderPolicy(daysBefore: {30, 14, 7, 1}),
    );

    // Schedules are persisted even if the OS notifications are disabled.
    final schedules = await schedulesRepo.getForDocument('doc2');
    expect(schedules.length, 4);

    await db.close();
  });
}

