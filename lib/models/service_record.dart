// models/service_record.dart

class ServiceRecord {
  final int? id;
  final int vehicleId;
  final String serviceName;
  final int mileage;
  final DateTime date;
  final String iconName;
  final String? notes;
  final String? vehicleMake;
  final String? vehicleModel;

  ServiceRecord({
    this.id,
    required this.vehicleId,
    required this.serviceName,
    required this.mileage,
    required this.date,
    required this.iconName,
    this.notes,
    this.vehicleMake,
    this.vehicleModel,
  });

  // Convierte un objeto ServiceRecord en un mapa.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceName': serviceName,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'iconName': iconName,
      'notes': notes,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
    };
  }

  // Crea un objeto ServiceRecord a partir de un mapa.
  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      vehicleModel: map['vehicleModel'] as String?,
      mileage: map['mileage'] as int,
      date: DateTime.parse(map['date'] as String),
      iconName: map['iconName'] as String,
      notes: map['notes'] as String?,
      serviceName: map['serviceName'] as String,
      vehicleMake: map['vehicleMake'] as String?,
    );
  }
}
