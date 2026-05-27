import 'dart:io';

import 'package:cleartodrive/data/database/converters/enum_converters.dart';
import 'package:cleartodrive/data/database/tables/app_settings_table.dart';
import 'package:cleartodrive/data/database/tables/reminder_schedules_table.dart';
import 'package:cleartodrive/data/database/tables/vehicle_documents_table.dart';
import 'package:cleartodrive/data/database/tables/vehicles_table.dart';
import 'package:cleartodrive/domain/enums/document_enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    VehiclesTable,
    VehicleDocumentsTable,
    ReminderSchedulesTable,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor) : super();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}cleartodrive.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

