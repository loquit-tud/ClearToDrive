import 'package:cleartodrive/data/database/converters/enum_converters.dart';
import 'package:cleartodrive/data/database/tables/vehicle_documents_table.dart';
import 'package:drift/drift.dart';

class ReminderSchedulesTable extends Table {
  TextColumn get id => text()(); // {documentId}_{offsetDays}
  TextColumn get documentId => text().references(VehicleDocumentsTable, #id)();
  DateTimeColumn get triggerAt => dateTime()();
  IntColumn get offsetDays => integer()();
  TextColumn get status => text().map(const ReminderStatusConverter())();
  IntColumn get notificationId => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(document_id, offset_days)',
      ];
}

