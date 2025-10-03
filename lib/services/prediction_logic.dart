// services/prediction_service.dart

import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_rule.dart';
import 'package:car_service_app/models/service_icon.dart';
import 'package:car_service_app/services/database_service.dart';

class PredictionService {
  // Reglas de servicio por defecto con frecuencias más variadas
  final List<ServiceRule> _defaultServiceRules = [
    ServiceRule(serviceName: 'Cambio de Aceite', frequencyKm: 5000, iconId: 1),
    ServiceRule(
      serviceName: 'Rotación de Llantas',
      frequencyKm: 10000,
      iconId: 4,
    ),
    ServiceRule(
      serviceName: 'Cambio de Pastillas de Freno',
      frequencyKm: 15000,
      iconId: 3,
    ),
    ServiceRule(
      serviceName: 'Cambio de Correa de Distribución',
      frequencyKm: 60000,
      iconId: 7,
    ),
    ServiceRule(
      serviceName: 'Cambio de Filtro de Aire',
      frequencyKm: 12000,
      iconId: 2,
    ),
    ServiceRule(
      serviceName: 'Alineación y Balanceo',
      frequencyKm: 8000,
      iconId: 5,
    ),
    ServiceRule(
      serviceName: 'Cambio de Batería',
      frequencyKm: 50000,
      iconId: 6,
    ),
    ServiceRule(
      serviceName: 'Lavado y Detallado',
      frequencyKm: 1000,
      iconId: 8,
    ),
    ServiceRule(
      serviceName: 'Revisión de Frenos',
      frequencyKm: 8000,
      iconId: 3,
    ),
    ServiceRule(serviceName: 'Cambio de Bujías', frequencyKm: 30000, iconId: 9),
    ServiceRule(
      serviceName: 'Revisión de Suspensión',
      frequencyKm: 20000,
      iconId: 10,
    ),
  ];

  // Obtener las reglas de servicio (de la BD o por defecto)
  Future<List<ServiceRule>> _getServiceRules() async {
    try {
      final services = await DatabaseService.getServices();
      if (services.isNotEmpty) {
        return services
            .map(
              (service) => ServiceRule(
                serviceName: service.serviceName,
                frequencyKm: _getDefaultFrequencyForService(
                  service.serviceName,
                ),
                iconId: service.iconId,
              ),
            )
            .toList();
      }
      // Si no hay servicios en BD, usar reglas por defecto
      return _defaultServiceRules;
    } catch (e) {
      print('Error obteniendo reglas de servicio: $e');
      return _defaultServiceRules;
    }
  }

  // Obtener frecuencia por defecto basada en el nombre del servicio
  int _getDefaultFrequencyForService(String serviceName) {
    final defaultRule = _defaultServiceRules.firstWhere(
      (rule) => rule.serviceName == serviceName,
      orElse: () =>
          ServiceRule(serviceName: serviceName, frequencyKm: 10000, iconId: 1),
    );
    return defaultRule.frequencyKm;
  }

  // Predecir servicios necesarios para un vehículo - SOLO 5 PRÓXIMOS
  Future<List<Map<String, dynamic>>> predictServices(Vehicle vehicle) async {
    final List<Map<String, dynamic>> predictions = [];
    final List<ServiceRule> serviceRules = await _getServiceRules();

    // DEBUG: Verificar los valores del vehículo
    print('DEBUG - Vehicle data:');
    print('  currentMileage: ${vehicle.currentMileage}');
    print('  lastServiceMileage: ${vehicle.lastServiceMileage}');
    print('  lastServiceDate: ${vehicle.lastServiceDate}');

    final int mileageSinceLastService =
        vehicle.currentMileage - vehicle.lastServiceMileage;
    final int daysSinceLastService = DateTime.now()
        .difference(vehicle.lastServiceDate)
        .inDays;

    // DEBUG: Verificar cálculos
    print('DEBUG - Calculations:');
    print('  mileageSinceLastService: $mileageSinceLastService');
    print('  daysSinceLastService: $daysSinceLastService');

    // Calcular uso diario promedio una sola vez
    final double avgKmPerDay = _calculateAverageDailyUsage(
      mileageSinceLastService,
      daysSinceLastService,
    );

    print('  avgKmPerDay: $avgKmPerDay');

    // Patrones para generar los tres rangos de porcentajes
    final List<double> highProgressPatterns = [
      0.85,
      0.92,
      0.88,
      0.95,
      0.81,
    ]; // 81-95%
    final List<double> mediumProgressPatterns = [
      0.65,
      0.72,
      0.58,
      0.78,
      0.63,
      0.55,
      0.69,
      0.75,
      0.60,
      0.70,
    ]; // 55-78%
    final List<double> lowProgressPatterns = [
      0.25,
      0.35,
      0.42,
      0.18,
      0.30,
      0.48,
      0.22,
      0.38,
    ]; // 18-48%

    // Distribuir servicios en los tres rangos
    int highIndex = 0;
    int mediumIndex = 0;
    int lowIndex = 0;

    for (var rule in serviceRules) {
      double progressFactor;

      // Distribuir servicios entre los tres rangos
      if (highIndex < 3) {
        // 3 servicios en rango alto (80-100%)
        progressFactor =
            highProgressPatterns[highIndex % highProgressPatterns.length];
        highIndex++;
      } else if (mediumIndex < 5) {
        // 5 servicios en rango medio (50-79%)
        progressFactor =
            mediumProgressPatterns[mediumIndex % mediumProgressPatterns.length];
        mediumIndex++;
      } else {
        // Resto en rango bajo (0-49%)
        progressFactor =
            lowProgressPatterns[lowIndex % lowProgressPatterns.length];
        lowIndex++;
      }

      final int simulatedKmSinceLastService =
          (rule.frequencyKm * progressFactor).round();

      // Calcular kilómetros hasta el próximo servicio
      final int kmToNextService = _calculateKmToNextService(
        simulatedKmSinceLastService,
        rule.frequencyKm,
      );

      // Calcular porcentaje completado (inverso)
      final double percentageCompleted = _calculatePercentageCompleted(
        simulatedKmSinceLastService,
        rule.frequencyKm,
      );

      // Calcular tiempo estimado
      final timeInfo = _calculateTimeRemaining(kmToNextService, avgKmPerDay);

      // Obtener información del icono
      final iconInfo = await _getIconInfo(rule.iconId);

      // DEBUG: Verificar cada servicio
      print('DEBUG - Service: ${rule.serviceName}');
      print('  frequencyKm: ${rule.frequencyKm}');
      print('  simulatedKmSinceLastService: $simulatedKmSinceLastService');
      print('  kmToNextService: $kmToNextService');
      print('  percentageCompleted: ${percentageCompleted.round()}%');
      print('  timeRemaining: ${timeInfo['value']} ${timeInfo['unit']}');

      predictions.add({
        'service': rule.serviceName,
        'kmToNextService': kmToNextService,
        'kmSinceLastService': simulatedKmSinceLastService,
        'timeRemaining': timeInfo['value'],
        'timeUnit': timeInfo['unit'],
        'icon': iconInfo['icon'],
        'iconName': iconInfo['name'],
        'isDue': kmToNextService <= 500,
        'isUrgent': kmToNextService <= 100,
        'percentageRemaining': percentageCompleted.round(), // % completado
        'frequencyKm': rule.frequencyKm,
      });
    }

    // Ordenar por proximidad (los más urgentes primero)
    predictions.sort(
      (a, b) => a['kmToNextService'].compareTo(b['kmToNextService']),
    );

    // SOLO RETORNAR LOS 5 PRIMEROS (más próximos)
    return predictions.take(5).toList();
  }

  // Calcular kilómetros hasta el próximo servicio
  int _calculateKmToNextService(int kmSinceLastService, int frequencyKm) {
    // Si ya pasó el kilometraje, calcular cuánto falta para el próximo ciclo
    if (kmSinceLastService >= frequencyKm) {
      return frequencyKm - (kmSinceLastService % frequencyKm);
    } else {
      return frequencyKm - kmSinceLastService;
    }
  }

  // Calcular porcentaje completado (inverso)
  double _calculatePercentageCompleted(
    int kmSinceLastService,
    int frequencyKm,
  ) {
    // Si no se han recorrido kilómetros, mostrar 0%
    if (kmSinceLastService <= 0) return 0.0;

    // Calcular el porcentaje de progreso basado en los km recorridos
    double rawPercentage = (kmSinceLastService / frequencyKm) * 100;

    // Si ya pasó el servicio, mostrar 100%
    if (kmSinceLastService >= frequencyKm) {
      return 100.0;
    }

    // Asegurar que el porcentaje esté entre 1% y 100%
    if (rawPercentage < 1 && kmSinceLastService > 0) {
      return 1.0;
    }

    return rawPercentage.clamp(1.0, 100.0);
  }

  // Calcular uso diario promedio del vehículo
  double _calculateAverageDailyUsage(
    int mileageSinceLastService,
    int daysSinceLastService,
  ) {
    if (daysSinceLastService <= 0) return 25.0;

    // Si no hay kilómetros recorridos, usar valor por defecto
    if (mileageSinceLastService <= 0) return 25.0;

    return mileageSinceLastService / daysSinceLastService;
  }

  // Calcular tiempo restante de forma más precisa
  Map<String, dynamic> _calculateTimeRemaining(
    int kmToNextService,
    double avgKmPerDay,
  ) {
    // Si no hay uso diario o es muy bajo, usar valor por defecto
    if (avgKmPerDay <= 0.1) {
      return {'value': 30, 'unit': 'días'};
    }

    final double daysRemaining = kmToNextService / avgKmPerDay;

    // Asegurarse de que el tiempo mínimo sea 1 día
    final double actualDaysRemaining = daysRemaining < 1 ? 1 : daysRemaining;

    if (actualDaysRemaining >= 365) {
      final int years = (actualDaysRemaining / 365).round();
      return {'value': years, 'unit': years == 1 ? 'año' : 'años'};
    } else if (actualDaysRemaining >= 30) {
      final int months = (actualDaysRemaining / 30).round();
      return {'value': months, 'unit': months == 1 ? 'mes' : 'meses'};
    } else if (actualDaysRemaining >= 7) {
      final int weeks = (actualDaysRemaining / 7).round();
      return {'value': weeks, 'unit': weeks == 1 ? 'semana' : 'semanas'};
    } else {
      final int days = actualDaysRemaining.round();
      return {'value': days, 'unit': days == 1 ? 'día' : 'días'};
    }
  }

  // Obtener información del icono desde la base de datos
  Future<Map<String, String>> _getIconInfo(int iconId) async {
    try {
      final ServiceIcon icon = await DatabaseService.getServiceIconById(iconId);
      return {'icon': icon.icon, 'name': icon.name};
    } catch (e) {
      print('Error obteniendo información del icono: $e');
      // Iconos por defecto para nuevos servicios
      final defaultIcons = {
        1: 'oil_change',
        2: 'air_filter',
        3: 'brakes',
        4: 'tire_rotation',
        5: 'alignment',
        6: 'battery',
        7: 'timing_belt',
        8: 'car_wash',
        9: 'engine',
        10: 'suspension',
      };
      final iconName = defaultIcons[iconId] ?? 'default_icon';
      return {'icon': iconName, 'name': 'Servicio'};
    }
  }

  // Método para obtener servicios urgentes (próximos 500km) - SOLO 5
  Future<List<Map<String, dynamic>>> getUrgentServices(Vehicle vehicle) async {
    final allPredictions = await predictServices(vehicle);
    return allPredictions
        .where((prediction) => prediction['isDue'] == true)
        .take(5) // También limitar a 5 servicios urgentes
        .toList();
  }

  // Método para obtener el próximo servicio más urgente
  Future<Map<String, dynamic>?> getNextService(Vehicle vehicle) async {
    final predictions = await predictServices(vehicle);
    if (predictions.isEmpty) return null;
    return predictions.first;
  }
}
