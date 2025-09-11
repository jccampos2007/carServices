// models/vehicle.dart

class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int initialMileage;
  final int currentMileage;
  final DateTime lastServiceDate;
  final int lastServiceMileage;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.initialMileage,
    required this.currentMileage,
    required this.lastServiceDate,
    required this.lastServiceMileage,
  });

  // Convierte un objeto Vehicle en un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'initialMileage': initialMileage,
      'currentMileage': currentMileage,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
    };
  }

  // Crea un objeto Vehicle a partir de un mapa de la base de datos.
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      make: map['make'] as String,
      model: map['model'] as String,
      initialMileage: map['initialMileage'] as int,
      currentMileage: map['currentMileage'] as int,
      lastServiceDate: DateTime.parse(map['lastServiceDate'] as String),
      lastServiceMileage: map['lastServiceMileage'] as int,
    );
  }
}
