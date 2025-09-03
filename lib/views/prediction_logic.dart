// prediction_logic.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart'; // Importa el modelo de datos real

// Este archivo contendrá la lógica para predecir cuándo es necesario un servicio.

// Define un modelo de datos para los servicios que requieren predicción
// Estos datos pueden ser almacenados en la base de datos en una versión futura.
class ServiceRule {
  final String serviceName;
  final int frequencyKm; // Frecuencia en kilómetros
  final String iconName;

  ServiceRule({
    required this.serviceName,
    required this.frequencyKm,
    required this.iconName,
  });
}

// Clase para calcular las predicciones
class PredictionService {
  final List<ServiceRule> _serviceRules = [
    ServiceRule(
      serviceName: 'Cambio de Aceite',
      frequencyKm: 10000,
      iconName: 'oil_change',
    ),
    ServiceRule(
      serviceName: 'Rotación de Llantas',
      frequencyKm: 15000,
      iconName: 'tire_rotation',
    ),
    ServiceRule(
      serviceName: 'Revisión de Frenos',
      frequencyKm: 20000,
      iconName: 'brakes',
    ),
    ServiceRule(
      serviceName: 'Cambio de Correa de Tiempo',
      frequencyKm: 100000,
      iconName: 'timing_belt',
    ),
    ServiceRule(
      serviceName: 'Revisión de Filtro de Aire',
      frequencyKm: 30000,
      iconName: 'air_filter',
    ),
    ServiceRule(
      serviceName: 'Cambio de Bujías',
      frequencyKm: 50000,
      iconName: 'spark_plugs',
    ),
  ];

  // Ahora la función usa el modelo de datos de vehículo real (Vehicle)
  List<Map<String, dynamic>> predictServices(Vehicle vehicle) {
    List<Map<String, dynamic>> predictions = [];

    // Calcula el kilometraje desde el último servicio
    final int mileageSinceLastService =
        vehicle.currentMileage - vehicle.lastServiceMileage;

    for (var rule in _serviceRules) {
      final int kmToNextService =
          rule.frequencyKm - (mileageSinceLastService % rule.frequencyKm);

      // Simula el kilometraje promedio para una predicción más precisa.
      // Aquí usamos una estimación simple de 20,000 km/año, ~55 km/día.
      final double avgKmPerDay = 55.0;
      final int daysToNextService = (kmToNextService / avgKmPerDay).ceil();

      final DateTime nextServiceDate = vehicle.lastServiceDate.add(
        Duration(days: daysToNextService),
      );

      predictions.add({
        'service': rule.serviceName,
        'kmToNextService': kmToNextService,
        'nextServiceDate': nextServiceDate,
        'icon': rule.iconName,
        'isDue':
            kmToNextService <=
            1000, // Marca como pendiente si faltan 1000 km o menos
      });
    }

    return predictions;
  }
}

// Un simple widget para obtener un ícono basado en el nombre del ícono.
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'oil_change':
      return Icons.oil_barrel;
    case 'tire_rotation':
      return Icons.swap_horiz;
    case 'brakes':
      return Icons.car_crash;
    case 'timing_belt':
      return Icons.access_time;
    case 'air_filter':
      return Icons.filter_alt;
    case 'spark_plugs':
      return Icons.electrical_services;
    default:
      return Icons.build;
  }
}
