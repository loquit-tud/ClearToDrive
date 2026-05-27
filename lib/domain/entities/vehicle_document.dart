import 'package:cleartodrive/domain/enums/document_enums.dart';

class VehicleDocument {
  const VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.expiryDate,
    required this.source,
    this.imagePath,
    required this.confirmedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vehicleId;
  final DocumentType type;
  final DateTime expiryDate;
  final DocumentSource source;
  final String? imagePath;
  final DateTime confirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleDocument copyWith({
    DocumentType? type,
    DateTime? expiryDate,
    DocumentSource? source,
    String? imagePath,
    DateTime? confirmedAt,
    DateTime? updatedAt,
  }) {
    return VehicleDocument(
      id: id,
      vehicleId: vehicleId,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
