// models/service_rule.dart
class ServiceRule {
  final int? id;
  final String serviceName;
  final int frequencyKm; // Frecuencia en kilómetros
  final int iconId; // Referencia al icono en la base de datos

  ServiceRule({
    this.id,
    required this.serviceName,
    required this.frequencyKm,
    required this.iconId,
  });

  // Convierte un objeto ServiceRule en un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'frequencyKm': frequencyKm,
      'iconId': iconId,
    };
  }

  // Crea un objeto ServiceRule a partir de un mapa de la base de datos.
  factory ServiceRule.fromMap(Map<String, dynamic> map) {
    return ServiceRule(
      id: map['id'] as int?,
      serviceName: map['serviceName'] as String,
      frequencyKm: map['frequencyKm'] as int,
      iconId: map['iconId'] as int,
    );
  }
}
