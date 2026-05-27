import 'package:cleartodrive/domain/entities/vehicle_document.dart';

abstract class DocumentRepository {
  Future<List<VehicleDocument>> getAll({String? vehicleId});
  Future<VehicleDocument?> getById(String id);
  Future<VehicleDocument> save(VehicleDocument document);
  Future<void> delete(String id);
}
