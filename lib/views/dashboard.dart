// dashboard.dart (fragmento corregido)
import 'package:flutter/material.dart';
import 'package:car_service_app/utils/icon_helper.dart';
import 'package:car_service_app/views/prediction_logic.dart';
import 'package:car_service_app/views/services_details.dart';

import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/database_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.onNavigateToServices});

  final VoidCallback onNavigateToServices;

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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF10162A),
      selectedItemColor: const Color(0xFF2AEFDA),
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      currentIndex: 0, // El dashboard es el primer índice (0)
      onTap: (index) {
        // Si se toca una pestaña diferente, navegar a esa pantalla
        if (index != 0) {
          Navigator.pop(context); // Cerrar Servicesdetails primero
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_outlined),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Setting',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Vehicle?>(
        future: _currentVehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No vehicle data found.'));
          }

          final currentVehicle = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48),

                // Información del usuario y vehículo
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Alex Cooper",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${currentVehicle.make}-${currentVehicle.model}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Image.asset(
                  'assets/images/chery_arauca.png',
                  fit: BoxFit.contain,
                ),

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
                SizedBox(height: 8), // Reducido de 16 a 8
                // Lista de próximos servicios
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _predictionsFuture,
                  builder: (context, servicesSnapshot) {
                    if (servicesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (servicesSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${servicesSnapshot.error}'),
                      );
                    }
                    if (!servicesSnapshot.hasData ||
                        servicesSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay servicios próximos.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final upcomingServices = servicesSnapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingServices.length,
                      itemBuilder: (context, index) {
                        final service = upcomingServices[index];
                        final bool isDue = service['isDue'];
                        return GestureDetector(
                          // Navega a la vista de detalles y pasa los datos del servicio
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Servicesdetails(
                                  serviceDetails: service,
                                  bottomNavigationBar:
                                      _buildBottomNavigationBar(
                                        context,
                                      ), // Pasa la botonera
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: isDue
                                    ? Colors.red.shade200
                                    : const Color(0xFF75A6B1),
                                width: 1,
                              ),
                            ),
                            color: Colors.black.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ), // Ajusta el padding según necesites
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0x8074cfde,
                                      ), // Tu color con opacidad
                                      borderRadius: BorderRadius.circular(
                                        100,
                                      ), // Hace el fondo circular
                                    ),
                                    child: Icon(
                                      getIconData(service['icon'] ?? 'default'),
                                      color: isDue
                                          ? Colors.red.shade200
                                          : Colors
                                                .white, // El color del ícono en sí
                                      size:
                                          24.0, // Ajusta el tamaño del ícono si es necesario
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['service'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDue
                                                ? Colors.red.shade200
                                                : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Recomendado a ${service['kmToNextService'] ?? 'N/A'} km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDue
                                                ? Colors.red.shade200
                                                : Colors.grey[300],
                                          ),
                                        ),
                                        Text(
                                          'Aprox. en ${service['timeRemaining'] ?? 'N/A'} ${service['timeUnit'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDue
                                                ? Colors.red.shade200
                                                : Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${service['percentageRemaining'] ?? 'N/A'} %',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                SizedBox(height: 16), // Reducido de 24 a 16

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onNavigateToServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2AEFDA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
