import 'package:flutter/material.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/services/location_service.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/prediction_logic.dart';
import 'package:car_service_app/utils/index.dart';
import 'package:car_service_app/views/services_details.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToSettings;
  final double todayDistance;
  final bool locationEnabled;

  const DashboardView({
    Key? key,
    required this.onNavigateToServices,
    required this.onNavigateToHistory,
    required this.onNavigateToSettings,
    required this.todayDistance,
    required this.locationEnabled,
  }) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Services
  final LocationService _locationService = LocationService();
  late final PredictionService _predictionService;

  // Futures
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<List<Map<String, dynamic>>> _predictionsFuture;
  late Future<Vehicle?> _currentVehicleFuture;
  late Future<List<ServiceRecord>> _recentServicesFuture;

  // Constants
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService();
    _loadData();
  }

  void _loadData() {
    _vehiclesFuture = DatabaseService.getVehicles();
    _recentServicesFuture = DatabaseService.getRecentServiceRecords(limit: 5);
    _currentVehicleFuture = _loadCurrentVehicle();
  }

  void _refreshData() {
    setState(_loadData);
  }

  Future<Vehicle?> _loadCurrentVehicle() async {
    try {
      final vehicles = await _vehiclesFuture;
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

          return _buildMainContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildMainContent(Vehicle vehicle) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildUserInfo(vehicle),
            const SizedBox(height: 24),
            _buildVehicleImage(vehicle),
            const SizedBox(height: 24),
            _buildServiceInfoSection(),
            const SizedBox(height: 24),
            _buildLocationCard(),
            const SizedBox(height: 24),
            _buildUpcomingServicesSection(),
            const SizedBox(height: 24),
            _buildRecentServicesSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============ HEADER SECTION ============
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
              ),
              const SizedBox(height: 4),
              Text(
                "${vehicle.make} ${vehicle.model}",
                style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    return Image.asset(
      _getVehicleImagePath(vehicle),
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

  String _getVehicleImagePath(Vehicle vehicle) {
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

  Widget _buildServiceInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildServiceInfoCard("Last Service", "12", "days ago"),
            const SizedBox(width: 12),
            _buildServiceInfoCard("Estimated", "53,000", "km"),
            const SizedBox(width: 12),
            _buildServiceInfoCard("Daily", "15.4", "km"),
          ],
        ),
      ],
    );
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

  // ============ LOCATION CARD ============
  Widget _buildLocationCard() {
    return Card(
      color: widget.locationEnabled
          ? Colors.green.withOpacity(0.2)
          : Colors.orange.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              widget.locationEnabled ? Icons.location_on : Icons.location_off,
              color: widget.locationEnabled ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.locationEnabled
                        ? 'Location Tracking Active'
                        : 'Location Tracking Disabled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.locationEnabled
                        ? 'Today\'s distance: ${widget.todayDistance.toStringAsFixed(1)} km'
                        : 'Enable location for auto mileage tracking',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ UPCOMING SERVICES ============
  Widget _buildUpcomingServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Services",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _predictionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            } else if (snapshot.hasError) {
              return _buildErrorCard('Error loading upcoming services');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyCard('No upcoming services');
            }

            return _buildUpcomingServicesList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingServicesList(List<Map<String, dynamic>> services) {
    return Column(children: services.map(_buildServiceItem).toList());
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final int percentage = service['percentageRemaining'] ?? 0;

    // Determine color based on percentage
    Color getPercentageColor() {
      if (percentage >= 80) {
        return Colors.red.shade400; // Red for 80-100% (urgent)
      } else if (percentage >= 50) {
        return Colors.orange.shade400; // Orange for 50-79% (intermediate)
      } else {
        return Colors.green.shade400; // Green for 0-49% (low)
      }
    }

    final percentageColor = getPercentageColor();
    final bool isUrgent = service['isUrgent'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              color: isUrgent ? Colors.red.shade400 : _secondaryColor,
              width: isUrgent ? 2 : 1,
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
                    color: isUrgent ? Colors.red.shade400 : Colors.white,
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
                          color: isUrgent ? Colors.red.shade400 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended at ${service['kmToNextService'] ?? 'N/A'} km',
                        style: TextStyle(
                          fontSize: 14,
                          color: isUrgent ? Colors.red.shade400 : _grey300,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Approx. in ${service['timeRemaining'] ?? 'N/A'} ${service['timeUnit'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isUrgent ? Colors.red.shade400 : _grey300,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: percentageColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: percentageColor, width: 1.5),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: percentageColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ RECENT SERVICES ============
  Widget _buildRecentServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full history
              },
              child: Text('View All', style: TextStyle(color: _primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ServiceRecord>>(
          future: _recentServicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            } else if (snapshot.hasError) {
              return _buildErrorCard('Error loading recent services');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyCard('No recent services');
            }

            return _buildRecentServicesList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildRecentServicesList(List<ServiceRecord> services) {
    return Column(children: services.map(_buildServiceCard).toList());
  }

  Widget _buildServiceCard(ServiceRecord service) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.build, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service at ${service.mileage} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatDate(service.date),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ QUICK ACTIONS ============
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                title: 'Add Service',
                color: _primaryColor,
                onTap: widget.onNavigateToServices,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildActionButton(
                icon: Icons.directions_car,
                title: 'Add Vehicle',
                color: Colors.blue,
                onTap: () => widget.onNavigateToSettings(),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildActionButton(
                icon: Icons.history,
                title: 'View History',
                color: Colors.orange,
                onTap: () => widget.onNavigateToHistory(),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildActionButton(
                icon: Icons.settings,
                title: 'Settings',
                color: Colors.purple,
                onTap: () => widget.onNavigateToSettings(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ UTILITY WIDGETS ============
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: _textColor));
  }

  Widget _buildLoadingCard() {
    return const Card(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      color: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(message, style: const TextStyle(color: Colors.white70)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: _textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text(
            'No vehicle found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Please add a vehicle to get started',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ============ NAVIGATION ============
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF10162A),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) Navigator.pop(context);
      },
      items: const [
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
          label: 'Settings',
        ),
      ],
    );
  }
}
