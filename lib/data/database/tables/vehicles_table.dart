import 'package:drift/drift.dart';

class VehiclesTable extends Table {
  TextColumn get id => text()();
  TextColumn get licensePlate => text()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(license_plate)',
      ];
}

