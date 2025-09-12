// models/service_icon.dart

class ServiceIcon {
  final int? id;
  final String name;
  final String icon;

  ServiceIcon({this.id, required this.name, required this.icon});

  // Convierte un objeto ServiceIcon en un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon};
  }

  // Crea un objeto ServiceIcon a partir de un mapa de la base de datos.
  factory ServiceIcon.fromMap(Map<String, dynamic> map) {
    return ServiceIcon(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
    );
  }
}
