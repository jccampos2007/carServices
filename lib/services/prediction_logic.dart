// services/prediction_service.dart

import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_rule.dart';
import 'package:car_service_app/models/service_icon.dart';
import 'package:car_service_app/services/database_service.dart';

class PredictionService {
  // Reglas de servicio por defecto (se usarán si no hay datos en la BD)
  final List<ServiceRule> _defaultServiceRules = [
    ServiceRule(
      serviceName: 'Cambio de Aceite',
      frequencyKm: 5000,
      iconId: 1, // ID correspondiente al icono en la BD
    ),
    ServiceRule(
      serviceName: 'Rotación de Llantas',
      frequencyKm: 15000,
      iconId: 4,
    ),
    ServiceRule(
      serviceName: 'Cambio de Pastillas de Freno',
      frequencyKm: 20000,
      iconId: 3,
    ),
    ServiceRule(
      serviceName: 'Cambio de Correa de Distribución',
      frequencyKm: 60000,
      iconId: 7,
    ),
    ServiceRule(
      serviceName: 'Cambio de Filtro de Aire',
      frequencyKm: 30000,
      iconId: 2,
    ),
    ServiceRule(
      serviceName: 'Alineación y Balanceo',
      frequencyKm: 25000,
      iconId: 5,
    ),
    ServiceRule(
      serviceName: 'Cambio de Batería',
      frequencyKm: 80000,
      iconId: 6,
    ),
    ServiceRule(
      serviceName: 'Lavado y Detallado',
      frequencyKm: 5000,
      iconId: 8,
    ),
  ];

  // Obtener las reglas de servicio (de la BD o por defecto)
  Future<List<ServiceRule>> _getServiceRules() async {
    try {
      // Intentar obtener servicios de la base de datos
      final services = await DatabaseService.getServices();

      // Convertir servicios a reglas (si tienen frecuencia configurada)
      // En una implementación real, tendrías una tabla específica para reglas
      return services
          .map(
            (service) => ServiceRule(
              serviceName: service.serviceName,
              frequencyKm: _getDefaultFrequencyForService(service.serviceName),
              iconId: service.iconId,
            ),
          )
          .toList();
    } catch (e) {
      // Si hay error, usar reglas por defecto
      print('Error obteniendo reglas de servicio: $e');
      return _defaultServiceRules;
    }
  }

  // Obtener frecuencia por defecto basada en el nombre del servicio
  int _getDefaultFrequencyForService(String serviceName) {
    final defaultRule = _defaultServiceRules.firstWhere(
      (rule) => rule.serviceName == serviceName,
      orElse: () => ServiceRule(
        serviceName: serviceName,
        frequencyKm: 10000, // Frecuencia por defecto
        iconId: 1, // Icono por defecto
      ),
    );
    return defaultRule.frequencyKm;
  }

  // Predecir servicios necesarios para un vehículo
  Future<List<Map<String, dynamic>>> predictServices(Vehicle vehicle) async {
    final List<Map<String, dynamic>> predictions = [];
    final List<ServiceRule> serviceRules = await _getServiceRules();

    final int mileageSinceLastService =
        vehicle.currentMileage - vehicle.lastServiceMileage;
    final int daysSinceLastService = DateTime.now()
        .difference(vehicle.lastServiceDate)
        .inDays;

    for (var rule in serviceRules) {
      final int kmSinceLastService = mileageSinceLastService;
      final int kmToNextService =
          rule.frequencyKm - (kmSinceLastService % rule.frequencyKm);

      final double percentageRemaining =
          (kmToNextService / rule.frequencyKm) * 100;

      // Calcular tiempo estimado basado en uso promedio
      final double avgKmPerDay = _calculateAverageDailyUsage(
        vehicle,
        daysSinceLastService,
      );
      final int daysToNextService = avgKmPerDay > 0
          ? (kmToNextService / avgKmPerDay).ceil()
          : 365;

      // Convertir días a unidades de tiempo apropiadas
      final timeInfo = _formatTimeRemaining(daysToNextService);

      // Obtener información del icono
      final iconInfo = await _getIconInfo(rule.iconId);

      predictions.add({
        'service': rule.serviceName,
        'kmToNextService': kmToNextService,
        'kmSinceLastService': kmSinceLastService,
        'timeRemaining': timeInfo['value'],
        'timeUnit': timeInfo['unit'],
        'icon': iconInfo['icon'],
        'iconName': iconInfo['name'],
        'isDue':
            kmToNextService <= 500, // Considerar debido si faltan 500km o menos
        'isUrgent': kmToNextService <= 100, // Urgente si faltan 100km o menos
        'percentageRemaining': percentageRemaining.round(),
        'frequencyKm': rule.frequencyKm,
      });
    }

    // Ordenar por proximidad (los más urgentes primero)
    predictions.sort(
      (a, b) => a['kmToNextService'].compareTo(b['kmToNextService']),
    );

    return predictions;
  }

  // Calcular uso diario promedio del vehículo
  double _calculateAverageDailyUsage(
    Vehicle vehicle,
    int daysSinceLastService,
  ) {
    if (daysSinceLastService <= 0) return 55.0; // Valor por defecto

    final int kmSinceLastService =
        vehicle.currentMileage - vehicle.lastServiceMileage;
    return kmSinceLastService / daysSinceLastService;
  }

  // Formatear tiempo restante en unidades apropiadas
  Map<String, dynamic> _formatTimeRemaining(int days) {
    if (days >= 365) {
      return {'value': (days / 365).round(), 'unit': 'años'};
    } else if (days >= 30) {
      return {'value': (days / 30).round(), 'unit': 'meses'};
    } else if (days >= 7) {
      return {'value': (days / 7).round(), 'unit': 'semanas'};
    } else {
      return {'value': days, 'unit': 'días'};
    }
  }

  // Obtener información del icono desde la base de datos
  Future<Map<String, String>> _getIconInfo(int iconId) async {
    try {
      final ServiceIcon icon = await DatabaseService.getServiceIconById(iconId);
      return {'icon': icon.icon, 'name': icon.name};
    } catch (e) {
      print('Error obteniendo información del icono: $e');
      return {'icon': 'default_icon', 'name': 'Servicio'};
    }
  }

  // Método para obtener servicios urgentes (próximos 1000km)
  Future<List<Map<String, dynamic>>> getUrgentServices(Vehicle vehicle) async {
    final allPredictions = await predictServices(vehicle);
    return allPredictions
        .where((prediction) => prediction['isDue'] == true)
        .toList();
  }

  // Método para obtener el próximo servicio más urgente
  Future<Map<String, dynamic>?> getNextService(Vehicle vehicle) async {
    final predictions = await predictServices(vehicle);
    if (predictions.isEmpty) return null;
    return predictions.first;
  }

  // Método para calcular el costo estimado de mantenimiento
  Future<Map<String, dynamic>> calculateMaintenanceCost(Vehicle vehicle) async {
    final predictions = await predictServices(vehicle);
    double totalCost = 0.0;
    int servicesDue = 0;

    // Precios estimados por tipo de servicio (en una app real, esto vendría de la BD)
    final Map<String, double> servicePrices = {
      'Cambio de Aceite': 80.0,
      'Rotación de Llantas': 40.0,
      'Cambio de Pastillas de Freno': 120.0,
      'Cambio de Correa de Distribución': 300.0,
      'Cambio de Filtro de Aire': 60.0,
      'Alineación y Balanceo': 90.0,
      'Cambio de Batería': 150.0,
      'Lavado y Detallado': 25.0,
    };

    for (var prediction in predictions) {
      if (prediction['isDue']) {
        final serviceName = prediction['service'];
        final price = servicePrices[serviceName] ?? 50.0; // Precio por defecto
        totalCost += price;
        servicesDue++;
      }
    }

    return {
      'totalCost': totalCost,
      'servicesDue': servicesDue,
      'estimatedCostPerService': servicesDue > 0 ? totalCost / servicesDue : 0,
    };
  }
}
