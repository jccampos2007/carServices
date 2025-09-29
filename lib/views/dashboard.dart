// dashboard.dart (refactorizado)
import 'package:flutter/material.dart';
import 'package:car_service_app/utils/icon_helper.dart';
import 'package:car_service_app/services/prediction_logic.dart';
import 'package:car_service_app/views/services_details.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.onNavigateToServices});

  final VoidCallback onNavigateToServices;

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Servicios y estado
  late final PredictionService _predictionService;
  late Future<List<Map<String, dynamic>>> _predictionsFuture;
  late Future<Vehicle?> _currentVehicleFuture;

  // Constantes
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService();
    _currentVehicleFuture = _loadCurrentVehicle();
  }

  Future<Vehicle?> _loadCurrentVehicle() async {
    try {
      final vehicles = await DatabaseService.getVehicles();
      if (vehicles.isNotEmpty) {
        _predictionsFuture = _predictionService.predictServices(vehicles.first);
        return vehicles.first;
      }
      return null;
    } catch (e) {
      print('Error loading current vehicle: $e');
      return null;
    }
  }

  // Widgets de construcción

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF10162A),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) {
          Navigator.pop(context);
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

  Widget _buildUserInfo(Vehicle vehicle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alex Cooper",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${vehicle.make}-${vehicle.model}",
                style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    String getImagePath() {
      if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty) {
        return vehicle.imageUrl!;
      }
      if (vehicle.make == 'Chery' && vehicle.model == 'Arauca') {
        return 'assets/images/chery_arauca.png';
      } else if (vehicle.make == 'Toyota' && vehicle.model == 'Corolla') {
        return 'assets/images/toyota_corolla.png';
      }
      return 'assets/images/default_car.png';
    }

    return Image.asset(
      getImagePath(),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.directions_car,
          size: 150,
          color: Colors.white70,
        );
      },
    );
  }

  Widget _buildServiceInfoCard(String title, String value) {
    return Expanded(
      child: Card(
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
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfoSection() {
    return Row(
      children: [
        _buildServiceInfoCard("Last Services", "12 Hours"),
        const SizedBox(width: 8),
        _buildServiceInfoCard("Estimated km", "53.000"),
        const SizedBox(width: 8),
        _buildServiceInfoCard("daily km", "15.4"),
      ],
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final bool isDue = service['isDue'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reducido de 12 a 8
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Servicesdetails(
                serviceDetails: service,
                bottomNavigationBar: _buildBottomNavigationBar(context),
              ),
            ),
          );
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isDue ? Colors.red.shade200 : _secondaryColor,
              width: 1,
            ),
          ),
          color: Colors.black.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0x8074cfde),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    getIconData(service['icon'] ?? 'default'),
                    color: isDue ? Colors.red.shade200 : Colors.white,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['service'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDue ? Colors.red.shade200 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4), // Espaciado más compacto
                      Text(
                        'Recomendado a ${service['kmToNextService'] ?? 'N/A'} km',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDue ? Colors.red.shade200 : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 2), // Espaciado más compacto
                      Text(
                        'Aprox. en ${service['timeRemaining'] ?? 'N/A'} ${service['timeUnit'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDue ? Colors.red.shade200 : Colors.grey[300],
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
                    color: isDue ? Colors.red.shade200 : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingServices(List<Map<String, dynamic>> services) {
    return Column(
      children: services.map((service) => _buildServiceItem(service)).toList(),
    );
  }

  Widget _buildAddServiceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onNavigateToServices,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
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
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: _textColor));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text('Error: $error', style: const TextStyle(color: _textColor)),
    );
  }

  Widget _buildNoVehicleWidget() {
    return const Center(
      child: Text(
        'No vehicle data found.',
        style: TextStyle(color: _textColor),
      ),
    );
  }

  Widget _buildNoServicesWidget() {
    return const Center(
      child: Text(
        'No hay servicios próximos.',
        style: TextStyle(color: _textColor),
      ),
    );
  }

  Widget _buildMainContent(Vehicle vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          _buildUserInfo(vehicle),
          const SizedBox(height: 16),
          _buildVehicleImage(vehicle),
          const SizedBox(height: 16),

          // Service Information Section
          const Text(
            "Service information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceInfoSection(),
          const SizedBox(height: 16),

          // Upcoming Services Section
          const Text(
            "Próximos Servicios",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16), // Reducido de 16 a 8

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _predictionsFuture,
            builder: (context, servicesSnapshot) {
              if (servicesSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              } else if (servicesSnapshot.hasError) {
                return _buildErrorWidget(servicesSnapshot.error.toString());
              } else if (!servicesSnapshot.hasData ||
                  servicesSnapshot.data!.isEmpty) {
                return _buildNoServicesWidget();
              }

              final upcomingServices = servicesSnapshot.data!;
              return _buildUpcomingServices(upcomingServices);
            },
          ),
          const SizedBox(height: 16),
          _buildAddServiceButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<Vehicle?>(
        future: _currentVehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoVehicleWidget();
          }

          final currentVehicle = snapshot.data!;
          return _buildMainContent(currentVehicle);
        },
      ),
    );
  }
}
