import 'package:cleartodrive/data/database/converters/enum_converters.dart';
import 'package:cleartodrive/data/database/tables/vehicles_table.dart';
import 'package:drift/drift.dart';

class VehicleDocumentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(VehiclesTable, #id)();
  TextColumn get type => text().map(const DocumentTypeConverter())();
  DateTimeColumn get expiryDate => dateTime()();
  TextColumn get source => text().map(const DocumentSourceConverter())();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get confirmedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

