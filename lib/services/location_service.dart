import 'dart:math';
import 'package:location/location.dart';
import 'dart:async';

class LocationService {
  static const double earthRadiusKm = 6371.0;
  static const double earthRadiusMiles = 3959.0;

  final Location _location = Location();
  bool _isTracking = false;
  double _todayDistance = 0.0;
  LocationData? _lastLocation;
  DateTime? _trackingStartTime;

  // Stream para actualizaciones de distancia
  final StreamController<double> _distanceController =
      StreamController<double>.broadcast();
  Stream<double> get distanceStream => _distanceController.stream;

  /// Inicializar el servicio de ubicación
  static Future<void> initialize() async {
    // Inicialización básica - puedes agregar configuración adicional aquí
    await Future.delayed(Duration.zero);
  }

  /// TRACKING METHODS
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        final newPermission = await _location.requestPermission();
        return newPermission == PermissionStatus.granted;
      }
      return permission == PermissionStatus.granted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  Future<bool> startLocationTracking() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) return false;

      _isTracking = true;
      _todayDistance = 0.0;
      _trackingStartTime = DateTime.now();

      // Get initial location
      _lastLocation = await _location.getLocation();

      // Listen for location updates
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (_lastLocation != null &&
            _lastLocation!.latitude != null &&
            _lastLocation!.longitude != null &&
            currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          final distance = calculateDistance(
            startLat: _lastLocation!.latitude!,
            startLon: _lastLocation!.longitude!,
            endLat: currentLocation.latitude!,
            endLon: currentLocation.longitude!,
          );

          _todayDistance += distance;
          _distanceController.add(_todayDistance);
        }
        _lastLocation = currentLocation;
      });

      return true;
    } catch (e) {
      print('Error starting location tracking: $e');
      _isTracking = false;
      return false;
    }
  }

  void stopTracking() {
    _isTracking = false;
    _trackingStartTime = null;
  }

  void resetDailyDistance() {
    _todayDistance = 0.0;
    _trackingStartTime = DateTime.now();
    _distanceController.add(_todayDistance);
  }

  // Getters for tracking
  bool get isTracking => _isTracking;
  double get todayDistance => _todayDistance;
  DateTime? get trackingStartTime => _trackingStartTime;

  /// DISTANCE CALCULATION METHODS
  double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    DistanceUnit unit = DistanceUnit.kilometers,
  }) {
    _validateCoordinates(startLat, startLon, endLat, endLon);

    final double dLat = _toRadians(endLat - startLat);
    final double dLon = _toRadians(endLon - startLon);

    final double a = _calculateHaversineFormula(
      dLat,
      dLon,
      _toRadians(startLat),
      _toRadians(endLat),
    );

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double radius = unit == DistanceUnit.miles
        ? earthRadiusMiles
        : earthRadiusKm;

    return radius * c;
  }

  /// Calcula distancias en múltiples unidades
  Distance calculateDistanceInAllUnits({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    final double kilometers = calculateDistance(
      startLat: startLat,
      startLon: startLon,
      endLat: endLat,
      endLon: endLon,
      unit: DistanceUnit.kilometers,
    );

    return Distance(
      kilometers: kilometers,
      meters: kilometers * 1000,
      miles: kilometers * 0.621371,
    );
  }

  double _calculateHaversineFormula(
    double dLat,
    double dLon,
    double startLatRad,
    double endLatRad,
  ) {
    return sin(dLat / 2) * sin(dLat / 2) +
        cos(startLatRad) * cos(endLatRad) * sin(dLon / 2) * sin(dLon / 2);
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  void _validateCoordinates(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (!_isValidCoordinate(lat1, lon1) || !_isValidCoordinate(lat2, lon2)) {
      throw ArgumentError(
        'Coordenadas inválidas: lat [-90,90], lon [-180,180]',
      );
    }
  }

  bool _isValidCoordinate(double lat, double lon) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  // Clean up
  void dispose() {
    _distanceController.close();
  }
}

/// Unidades de distancia soportadas
enum DistanceUnit { kilometers, miles }

/// Modelo para representar distancias en múltiples unidades
class Distance {
  final double kilometers;
  final double meters;
  final double miles;

  const Distance({
    required this.kilometers,
    required this.meters,
    required this.miles,
  });

  @override
  String toString() {
    return 'Distance{kilometers: ${kilometers.toStringAsFixed(2)} km, '
        'meters: ${meters.toStringAsFixed(2)} m, '
        'miles: ${miles.toStringAsFixed(2)} mi}';
  }
}
