import 'package:flutter/material.dart';

class Servicesdetails extends StatelessWidget {
  final Map<String, dynamic> serviceDetails;
  final Widget? bottomNavigationBar;

  const Servicesdetails({
    super.key,
    required this.serviceDetails,
    this.bottomNavigationBar,
  });

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

  @override
  Widget build(BuildContext context) {
    // Usamos la predicción
    final double serviceProgress =
        _getDouble('percentageRemaining') / 100; // ahora porcentaje de 0-100
    final int percentage = _getInt('percentageRemaining');

    final double imageHeight = 400;
    final double gradientTop = (1.0 - serviceProgress) * imageHeight;

    return Scaffold(
      backgroundColor: Colors.transparent, // Ajustado a transparente
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2AEFDA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getString('service', defaultValue: 'Service Details'),
          style: const TextStyle(color: Color(0xFF2AEFDA)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2AEFDA), // Línea sólida
                          Color.fromARGB(
                            255,
                            27,
                            116,
                            143,
                          ), // Mantiene la línea 2px
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          0.02, // 2px relativo a la altura total (aprox)
                          0.5,
                        ],
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
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Service information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        label: "next service",
                        value: "${_getInt('kmToNextService')} km",
                      ),
                    ),
                    Expanded(
                      child: _infoCard(
                        label: "Remaining",
                        value:
                            "${_getInt('timeRemaining')} ${_getString('timeUnit')}",
                      ),
                    ),
                    Expanded(
                      child: _infoCard(
                        label: "Status",
                        value: serviceDetails['isDue'] == true
                            ? "Due soon"
                            : "Pending",
                        valueColor: serviceDetails['isDue'] == true
                            ? Colors.red.shade200
                            : Colors.yellow.shade200,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _infoCard({
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFF75A6B1), width: 1),
      ),
      color: Colors.black.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
