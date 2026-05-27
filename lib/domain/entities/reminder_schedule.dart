import 'package:cleartodrive/domain/enums/document_enums.dart';

class ReminderSchedule {
  const ReminderSchedule({
    required this.id,
    required this.documentId,
    required this.triggerAt,
    required this.offsetDays,
    required this.status,
    required this.notificationId,
  });

  final String id;
  final String documentId;
  final DateTime triggerAt;
  final int offsetDays;
  final ReminderStatus status;
  final int notificationId;
}
