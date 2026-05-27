import 'package:cleartodrive/core/validators/license_plate_validator.dart';
import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/domain/entities/vehicle.dart';
import 'package:cleartodrive/domain/repositories/vehicle_repository.dart';
import 'package:drift/drift.dart';

class DriftVehicleRepository implements VehicleRepository {
  DriftVehicleRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.vehiclesTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<Vehicle?> findByPlate(String normalizedPlate) async {
    final plate = LicensePlateValidator.normalize(normalizedPlate);
    final row = await (_db.select(_db.vehiclesTable)
          ..where((t) => t.licensePlate.equals(plate)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<Vehicle>> getAll() async {
    final rows = await (_db.select(_db.vehiclesTable)
          ..orderBy([(t) => OrderingTerm(expression: t.licensePlate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Vehicle?> getById(String id) async {
    final row = await (_db.select(_db.vehiclesTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<Vehicle> upsert(Vehicle vehicle) async {
    await _db.into(_db.vehiclesTable).insertOnConflictUpdate(
          VehiclesTableCompanion.insert(
            id: vehicle.id,
            licensePlate: vehicle.licensePlate,
            displayName: Value(vehicle.displayName),
            createdAt: vehicle.createdAt,
            updatedAt: vehicle.updatedAt,
          ),
        );
    return vehicle;
  }

  Vehicle _toEntity(VehiclesTableData row) {
    return Vehicle(
      id: row.id,
      licensePlate: row.licensePlate,
      displayName: row.displayName,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

