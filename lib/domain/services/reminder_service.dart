import 'package:cleartodrive/domain/entities/reminder_policy.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';

abstract class ReminderService {
  Future<void> scheduleForDocument(
    VehicleDocument document,
    ReminderPolicy policy,
  );

  Future<void> cancelForDocument(String documentId);

  Future<List<ReminderSchedule>> getSchedulesForDocument(String documentId);
}
