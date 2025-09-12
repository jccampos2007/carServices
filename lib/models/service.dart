class Service {
  final int? id;
  final String serviceName;
  final int iconId;

  Service({this.id, required this.serviceName, required this.iconId});

  // Convierte un objeto Service en un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {'id': id, 'serviceName': serviceName, 'iconId': iconId};
  }

  // Crea un objeto Service a partir de un mapa de la base de datos.
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int?,
      serviceName: map['serviceName'] as String,
      iconId: map['iconId'] as int,
    );
  }
}
