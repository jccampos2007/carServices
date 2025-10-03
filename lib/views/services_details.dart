// services_details.dart (refactorizado y optimizado)
import 'package:flutter/material.dart';

class Servicesdetails extends StatelessWidget {
  final Map<String, dynamic> serviceDetails;
  final Widget? bottomNavigationBar;

  const Servicesdetails({
    super.key,
    required this.serviceDetails,
    this.bottomNavigationBar,
  });

  // Constantes (consistentes con dashboard.dart)
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _textColor = Colors.white;

  // Métodos auxiliares para obtener datos
  String _getString(String key, {String defaultValue = 'N/A'}) {
    return serviceDetails[key]?.toString() ?? defaultValue;
  }

  int _getInt(String key, {int defaultValue = 0}) {
    if (serviceDetails[key] == null) return defaultValue;
    if (serviceDetails[key] is int) return serviceDetails[key];
    if (serviceDetails[key] is String) {
      return int.tryParse(serviceDetails[key]) ?? defaultValue;
    }
    return defaultValue;
  }

  double _getDouble(String key, {double defaultValue = 0.0}) {
    if (serviceDetails[key] == null) return defaultValue;
    if (serviceDetails[key] is double) return serviceDetails[key];
    if (serviceDetails[key] is String) {
      return double.tryParse(serviceDetails[key]) ?? defaultValue;
    }
    if (serviceDetails[key] is int) {
      return (serviceDetails[key] as int).toDouble();
    }
    return defaultValue;
  }

  Widget _buildServiceInfoCard(
    String title,
    String value,
    String subtitle, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 2.5,
            colors: [
              Color.fromARGB(255, 13, 20, 27),
              Color.fromARGB(255, 36, 55, 77),
              Color.fromARGB(255, 111, 136, 160),
              Color.fromARGB(255, 255, 255, 255),
            ],
            stops: [0.1, 0.3, 0.7, 1.0],
          ),
          border: Border.all(
            color: _secondaryColor.withOpacity(0.4),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor ?? _textColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replica de _buildServiceInfoSection adaptada para services_details
  Widget _buildServiceInfoSection() {
    final bool isDue = serviceDetails['isDue'] == true;
    final statusColor = isDue ? Colors.red.shade200 : Colors.yellow.shade200;
    final statusText = isDue ? "Due soon" : "Pending";

    return Row(
      children: [
        _buildServiceInfoCard(
          "Next Service",
          "${_getInt('kmToNextService')}",
          "Km",
        ),
        const SizedBox(width: 8),
        _buildServiceInfoCard(
          "Remaining",
          "${_getInt('timeRemaining')}",
          _getString('timeUnit'),
        ),
        const SizedBox(width: 8),
        _buildServiceInfoCard(
          "Status",
          statusText,
          "",
          valueColor: statusColor,
        ),
      ],
    );
  }

  Widget _buildVehicleImageWithProgress() {
    final int percentage = _getInt('percentageRemaining');
    final double imageHeight = 400;
    final double gradientTop = (1.0 - (percentage / 100)) * imageHeight;

    // Determinar color basado en el porcentaje
    Color getProgressColor() {
      if (percentage >= 80) {
        return Colors.red.shade400; // Rojo para 80-100% (urgente)
      } else if (percentage >= 50) {
        return Colors.orange.shade400; // Naranja para 50-79% (intermedio)
      } else {
        return Colors.green.shade400; // Verde para 0-49% (bajo)
      }
    }

    final progressColor = getProgressColor();

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/chery_arauca.png',
            fit: BoxFit.contain,
            height: imageHeight,
          ),
        ),
        Positioned(
          top: gradientTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  progressColor,
                  progressColor.withOpacity(0.7),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.1, 0.5],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: progressColor, // Mismo color que el gradiente
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getString('service', defaultValue: 'Service Details'),
          style: TextStyle(
            color: Colors.white, // Título en blanco
            fontSize: 24, // Tamaño consistente con otras pantallas
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildVehicleImageWithProgress(),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Service Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildServiceInfoSection(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
