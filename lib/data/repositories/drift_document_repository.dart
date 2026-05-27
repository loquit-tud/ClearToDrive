import 'package:cleartodrive/data/database/app_database.dart';
import 'package:cleartodrive/domain/entities/vehicle_document.dart';
import 'package:cleartodrive/domain/repositories/document_repository.dart';
import 'package:drift/drift.dart';

class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.vehicleDocumentsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<VehicleDocument>> getAll({String? vehicleId}) async {
    final query = _db.select(_db.vehicleDocumentsTable);
    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.expiryDate)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<VehicleDocument?> getById(String id) async {
    final row = await (_db.select(_db.vehicleDocumentsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<VehicleDocument> save(VehicleDocument document) async {
    await _db.into(_db.vehicleDocumentsTable).insertOnConflictUpdate(
          VehicleDocumentsTableCompanion.insert(
            id: document.id,
            vehicleId: document.vehicleId,
            type: document.type,
            expiryDate: document.expiryDate,
            source: document.source,
            imagePath: Value(document.imagePath),
            confirmedAt: document.confirmedAt,
            createdAt: document.createdAt,
            updatedAt: document.updatedAt,
          ),
        );
    return document;
  }

  VehicleDocument _toEntity(VehicleDocumentsTableData row) {
    return VehicleDocument(
      id: row.id,
      vehicleId: row.vehicleId,
      type: row.type,
      expiryDate: row.expiryDate,
      source: row.source,
      imagePath: row.imagePath,
      confirmedAt: row.confirmedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

