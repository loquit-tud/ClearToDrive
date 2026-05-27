class Vehicle {
  const Vehicle({
    required this.id,
    required this.licensePlate,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String licensePlate;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle copyWith({
    String? licensePlate,
    String? displayName,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id,
      licensePlate: licensePlate ?? this.licensePlate,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
