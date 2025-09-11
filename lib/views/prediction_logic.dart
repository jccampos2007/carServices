import 'package:car_service_app/models/vehicle.dart';

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

class PredictionService {
  final List<ServiceRule> _serviceRules = [
    ServiceRule(
      serviceName: 'Cambio de Aceite',
      frequencyKm: 5000,
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
      frequencyKm: 60000,
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

  List<Map<String, dynamic>> predictServices(Vehicle vehicle) {
    List<Map<String, dynamic>> predictions = [];

    final int mileageSinceLastService =
        vehicle.currentMileage - vehicle.lastServiceMileage;

    for (var rule in _serviceRules) {
      final int kmToNextService =
          rule.frequencyKm - (mileageSinceLastService % rule.frequencyKm);

      final double percentageRemaining =
          (kmToNextService / rule.frequencyKm) * 100;

      final double avgKmPerDay = 55.0;
      final int daysToNextService = (kmToNextService / avgKmPerDay).ceil();

      // Convertimos días -> meses o años si corresponde
      String timeUnit = "días";
      int timeValue = daysToNextService;

      if (timeValue >= 365) {
        timeUnit = "años";
        timeValue = (timeValue / 365).round();
      } else if (timeValue >= 30) {
        timeUnit = "meses";
        timeValue = (timeValue / 30).round();
      }

      predictions.add({
        'service': rule.serviceName,
        'kmToNextService': kmToNextService,
        'timeRemaining': timeValue, // Número
        'timeUnit': timeUnit, // Tipo: días, meses o años
        'icon': rule.iconName,
        'isDue': kmToNextService <= 1000,
        'percentageRemaining': percentageRemaining.toStringAsFixed(0),
      });
    }

    return predictions;
  }
}
