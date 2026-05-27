import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/domain/entities/reminder_schedule.dart';
import 'package:drift/drift.dart';

class DriftReminderScheduleRepository {
  DriftReminderScheduleRepository(this._db);

  final AppDatabase _db;

  Future<void> deleteForDocument(String documentId) async {
    await (_db.delete(_db.reminderSchedulesTable)
          ..where((t) => t.documentId.equals(documentId)))
        .go();
  }

  Future<List<ReminderSchedule>> getForDocument(String documentId) async {
    final rows = await (_db.select(_db.reminderSchedulesTable)
          ..where((t) => t.documentId.equals(documentId))
          ..orderBy([(t) => OrderingTerm(expression: t.triggerAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> upsertSchedules(List<ReminderSchedule> schedules) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.reminderSchedulesTable,
        schedules
            .map(
              (s) => ReminderSchedulesTableCompanion.insert(
                id: s.id,
                documentId: s.documentId,
                triggerAt: s.triggerAt,
                offsetDays: s.offsetDays,
                status: s.status,
                notificationId: s.notificationId,
              ),
            )
            .toList(),
      );
    });
  }

  ReminderSchedule _toEntity(ReminderSchedulesTableData row) {
    return ReminderSchedule(
      id: row.id,
      documentId: row.documentId,
      triggerAt: row.triggerAt,
      offsetDays: row.offsetDays,
      status: row.status,
      notificationId: row.notificationId,
    );
  }
}

