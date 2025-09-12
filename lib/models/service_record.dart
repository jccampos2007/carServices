// models/service_record.dart

class ServiceRecord {
  final int? id;
  final int vehicleId;
  final int serviceId;
  final int mileage;
  final DateTime date;
  final String? notes;

  ServiceRecord({
    this.id,
    required this.vehicleId,
    required this.serviceId,
    required this.mileage,
    required this.date,
    this.notes,
  });

  // Convierte un objeto ServiceRecord en un mapa.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Crea un objeto ServiceRecord a partir de un mapa.
  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      serviceId: map['serviceId'] as int,
      mileage: map['mileage'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}
