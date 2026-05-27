import 'package:cleartodrive/domain/entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAll();
  Future<Vehicle?> getById(String id);
  Future<Vehicle?> findByPlate(String normalizedPlate);
  Future<Vehicle> upsert(Vehicle vehicle);
  Future<void> delete(String id);
}
