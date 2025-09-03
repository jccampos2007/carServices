// dashboard.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/views/prediction_logic.dart';
import 'package:car_service_app/views/services.dart';
import 'package:car_service_app/main.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final PredictionService _predictionService;
  late Future<List<Map<String, dynamic>>> _predictionsFuture;
  late Future<Vehicle?> _currentVehicleFuture;

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService();
    _currentVehicleFuture = _loadCurrentVehicle();
  }

  Future<Vehicle?> _loadCurrentVehicle() async {
    final vehicles = await DatabaseService.getVehicles();
    if (vehicles.isNotEmpty) {
      _predictionsFuture = Future.value(
        _predictionService.predictServices(vehicles.first),
      );
      return vehicles.first;
    }
    return null;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Vehicle?>(
        future: _currentVehicleFuture,
        builder: (context, vehicleSnapshot) {
          if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (vehicleSnapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${vehicleSnapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!vehicleSnapshot.hasData) {
            return Center(
              child: Text(
                'No hay vehículo seleccionado.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final currentVehicle = vehicleSnapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                // Información del usuario y vehículo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alex Cooper",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${currentVehicle.make}-${currentVehicle.model}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Tarjeta de información del vehículo
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Color(0xFF75A6B1),
                      width: 1,
                    ), // #75a6b1
                  ),
                  color: Colors.black.withOpacity(0.3),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 40,
                          color: Colors.white,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kilometraje actual",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${currentVehicle.currentMileage} km",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Sección de batería (similar a la imagen)
                Text(
                  "Service information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFF75A6B1),
                            width: 1,
                          ), // #75a6b1
                        ),
                        color: Colors.black.withOpacity(0.3),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last Services",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "12 Hours",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFF75A6B1),
                            width: 1,
                          ), // #75a6b1
                        ),
                        color: Colors.black.withOpacity(0.3),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Estimated km",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "53.000",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Color(0xFF75A6B1),
                            width: 1,
                          ), // #75a6b1
                        ),
                        color: Colors.black.withOpacity(0.3),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "daily km",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "15.4",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Título de próximos servicios
                Text(
                  "Próximos Servicios",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Lista de próximos servicios
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _predictionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "No hay predicciones de servicio disponibles.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    final predictions = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = predictions[index];
                        final bool isDue = prediction['isDue'];
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Color(0xFF75A6B1).withOpacity(0.5),
                              width: 1,
                            ), // #75a6b1
                          ),
                          color: isDue
                              ? Colors.red.withOpacity(0.2)
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDue
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                getIconData(prediction['icon']),
                                color: isDue
                                    ? Colors.red
                                    : Colors.blue.shade200,
                              ),
                            ),
                            title: Text(
                              prediction['service'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDue
                                    ? Colors.red.shade200
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Faltan ${prediction['kmToNextService']} km",
                                    style: TextStyle(
                                      color: isDue
                                          ? Colors.red.shade200
                                          : Colors.grey[300],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Fecha estimada: ${prediction['nextServiceDate'].day}/${prediction['nextServiceDate'].month}/${prediction['nextServiceDate'].year}",
                                    style: TextStyle(
                                      color: isDue
                                          ? Colors.red.shade200
                                          : Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 24),

                // Botón para estación de carga más cercana
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(builder: (context) => ServicesWiew()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add Services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
