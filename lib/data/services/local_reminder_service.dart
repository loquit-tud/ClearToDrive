import 'dart:convert';

import 'package:cleartodrive/core/utils/reminder_date_calculator.dart';
import 'package:cleartodrive/data/repositories/drift_reminder_schedule_repository.dart';
import 'package:cleartodrive/data/services/notification_scheduler.dart';
import 'package:cleartodrive/data/services/timezone_service.dart';
import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:cleartodrive/domain/services/reminder_service.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalReminderService implements ReminderService {
  LocalReminderService(
    this._schedulesRepo,
    this._scheduler,
  );

  final DriftReminderScheduleRepository _schedulesRepo;
  final NotificationScheduler _scheduler;

  static const _channelId = 'expiry_reminders';
  static const _channelName = 'Expiry reminders';

  @override
  Future<void> cancelForDocument(String documentId) async {
    final existing = await _schedulesRepo.getForDocument(documentId);
    for (final schedule in existing) {
      await _scheduler.cancel(schedule.notificationId);
    }
    await _schedulesRepo.deleteForDocument(documentId);
  }

  @override
  Future<List<ReminderSchedule>> getSchedulesForDocument(
    String documentId,
  ) async {
    return _schedulesRepo.getForDocument(documentId);
  }

  @override
  Future<void> scheduleForDocument(
    VehicleDocument document,
    ReminderPolicy policy,
  ) async {
    await TimezoneService.ensureInitialized();
    await _scheduler.initialize();

    // Idempotent: cancel then recreate.
    await cancelForDocument(document.id);

    final triggers = ReminderDateCalculator.calculateTriggers(
      expiryDate: document.expiryDate,
      policy: policy,
    );

    final schedules = <ReminderSchedule>[];
    final enabled = await _scheduler.areNotificationsEnabled();

    for (final t in triggers) {
      final notificationId = _notificationId(document.id, t.offsetDays);
      final payload = jsonEncode({
        'documentId': document.id,
      });

      final title = _titleFor(document.type);
      final body = _bodyFor(document, t.offsetDays);

      final scheduledAt = tz.TZDateTime.from(t.triggerAt, tz.local);

      if (enabled) {
        await _scheduler.scheduleZoned(
          notificationId: notificationId,
          channelId: _channelId,
          channelName: _channelName,
          title: title,
          body: body,
          scheduledAt: scheduledAt,
          payload: payload,
        );
      }

      schedules.add(
        ReminderSchedule(
          id: '${document.id}_${t.offsetDays}',
          documentId: document.id,
          triggerAt: t.triggerAt,
          offsetDays: t.offsetDays,
          status: ReminderStatus.scheduled,
          notificationId: notificationId,
        ),
      );
    }

    await _schedulesRepo.upsertSchedules(schedules);
  }

  static int _notificationId(String documentId, int offsetDays) {
    // Stable, within 32-bit signed range.
    final input = '$documentId|$offsetDays';
    return input.hashCode & 0x7fffffff;
  }

  static String _titleFor(DocumentType type) {
    return switch (type) {
      DocumentType.rca => 'RCA',
      DocumentType.itp => 'ITP',
      DocumentType.rovinieta => 'Rovinietă',
    };
  }

  static String _bodyFor(VehicleDocument doc, int offsetDays) {
    if (offsetDays == 0) {
      return 'Expiră azi.';
    }
    return 'Expiră în $offsetDays zile.';
  }
}

