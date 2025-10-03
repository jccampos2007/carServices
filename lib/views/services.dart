// services.dart (with automatic mileage feature)
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/location_service.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  _ServicesViewState createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  // Controllers
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State
  Map<int, bool> _selectedServices = {};
  List<Service> _availableServices = [];
  Map<int, String> _serviceIcons = {};
  Vehicle? _selectedVehicle;
  bool _hasServices = false;
  bool _isLocationEnabled = false;
  double _autoMileage = 0.0;

  // Futures
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<Map<String, dynamic>> _servicesDataFuture;

  // Constants
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);
  static const _grey400 = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkLocationStatus();
  }

  void _initializeData() {
    _vehiclesFuture = DatabaseService.getVehicles();
    _servicesDataFuture = _loadServicesData();
  }

  void _checkLocationStatus() async {
    final locationService = LocationService();

    // Verificar permisos de ubicación
    final hasPermission = await locationService.checkLocationPermission();

    setState(() {
      _isLocationEnabled = hasPermission;

      // Si tenemos permisos y el tracking está activo, obtener distancia automática
      if (_isLocationEnabled && locationService.isTracking) {
        _autoMileage = locationService.todayDistance;
      }
    });
  }

  Future<Map<String, dynamic>> _loadServicesData() async {
    try {
      // Get services using DatabaseService
      final services = await DatabaseService.getServices();

      // Get services with icons using the specific method
      final servicesWithIcons = await DatabaseService.getServicesWithIcons();

      final Map<int, String> iconMap = {};
      for (var serviceData in servicesWithIcons) {
        iconMap[serviceData['id'] as int] = serviceData['iconData'] as String;
      }

      final Map<int, bool> selectionMap = {};
      for (var service in services) {
        selectionMap[service.id!] = false;
      }

      return {
        'services': services,
        'icons': iconMap,
        'selection': selectionMap,
      };
    } catch (e) {
      print('Error loading services data: $e');
      return {'services': [], 'icons': {}, 'selection': {}};
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _useAutoMileage() async {
    if (!_isLocationEnabled) {
      _showSnackBar(
        "Location tracking is not enabled. Please enable location services in settings.",
        isError: true,
      );
      return;
    }

    if (_selectedVehicle == null) {
      _showSnackBar("Please select a vehicle first.", isError: true);
      return;
    }

    final locationService = LocationService();
    final currentAutoMileage = locationService.todayDistance;

    // Calculate estimated current mileage: current vehicle mileage + today's auto mileage
    final estimatedMileage =
        _selectedVehicle!.currentMileage + currentAutoMileage.round();

    setState(() {
      _mileageController.text = estimatedMileage.toString();
      _autoMileage = currentAutoMileage;
    });

    _showSnackBar(
      "Auto mileage set to $estimatedMileage km (Today: ${currentAutoMileage.toStringAsFixed(1)} km)",
    );
  }

  bool _validateInputs() {
    if (_selectedVehicle == null || _mileageController.text.isEmpty) {
      _showSnackBar(
        "Please select a vehicle and enter the mileage.",
        isError: true,
      );
      return false;
    }

    final mileage = int.tryParse(_mileageController.text) ?? 0;
    if (mileage == 0) {
      _showSnackBar("Please enter a valid mileage.", isError: true);
      return false;
    }

    if (mileage < _selectedVehicle!.currentMileage) {
      _showSnackBar(
        "Mileage cannot be less than current vehicle mileage (${_selectedVehicle!.currentMileage} km).",
        isError: true,
      );
      return false;
    }

    // Only validate services if the switch is enabled
    if (_hasServices) {
      final selectedServiceIds = _selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedServiceIds.isEmpty) {
        _showSnackBar("Please select at least one service.", isError: true);
        return false;
      }
    }

    return true;
  }

  Future<void> _saveRecord() async {
    if (!_validateInputs()) return;

    final mileage = int.parse(_mileageController.text);
    List<int> selectedServiceIds = [];

    // Only get selected services if the switch is enabled
    if (_hasServices) {
      selectedServiceIds = _selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
    }

    try {
      // Only save service records if there are selected services
      if (_hasServices && selectedServiceIds.isNotEmpty) {
        await _saveServiceRecords(mileage, selectedServiceIds);
      }

      await _updateVehicleData(mileage);

      _showSnackBar("Service record saved successfully!");
      _resetForm();
    } catch (e) {
      _showSnackBar("Error saving record: $e", isError: true);
    }
  }

  Future<void> _saveServiceRecords(int mileage, List<int> serviceIds) async {
    for (final serviceId in serviceIds) {
      final newRecord = ServiceRecord(
        vehicleId: _selectedVehicle!.id!,
        serviceId: serviceId,
        mileage: mileage,
        date: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      await DatabaseService.addServiceRecord(newRecord);
    }
  }

  Future<void> _updateVehicleData(int mileage) async {
    final updatedVehicle = Vehicle(
      id: _selectedVehicle!.id,
      make: _selectedVehicle!.make,
      model: _selectedVehicle!.model,
      initialMileage: _selectedVehicle!.initialMileage,
      currentMileage: mileage > _selectedVehicle!.currentMileage
          ? mileage
          : _selectedVehicle!.currentMileage,
      lastServiceDate: DateTime.now(),
      lastServiceMileage: mileage,
    );

    await DatabaseService.updateVehicle(updatedVehicle);
    _vehiclesFuture = DatabaseService.getVehicles(); // Refresh data
  }

  void _resetForm() {
    _mileageController.clear();
    _notesController.clear();
    setState(() {
      _hasServices = false;
      _selectedServices = _selectedServices.map(
        (key, value) => MapEntry(key, false),
      );
    });
  }

  IconData _getIconForService(String iconName) {
    const iconMap = {
      'oil_change': Icons.local_car_wash,
      'air_filter': Icons.air,
      'brakes': Icons.fiber_manual_record,
      'tire_rotation': Icons.rotate_right,
      'alignment': Icons.straighten,
      'battery': Icons.battery_charging_full,
      'timing_belt': Icons.settings,
      'car_wash': Icons.local_car_wash,
      'engine': Icons.engineering,
      'suspension': Icons.airline_seat_recline_normal,
    };
    return iconMap[iconName] ?? Icons.build;
  }

  // Build widgets MODIFIED

  Widget _buildServiceCard(Service service) {
    final iconName = _serviceIcons[service.id] ?? 'default_icon';
    final isSelected = _selectedServices[service.id] ?? false;

    return GestureDetector(
      onTap: () => setState(() => _selectedServices[service.id!] = !isSelected),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : _secondaryColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                _getIconForService(iconName),
                size: 32,
                color: isSelected ? Colors.white : _textColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                service.serviceName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : _textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, bool isSelected) {
    // Determine image based on make and model if imageUrl is empty
    String getImagePath() {
      if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty) {
        return vehicle.imageUrl!;
      }
      // Fallback based on make and model
      if (vehicle.make == 'Chery' && vehicle.model == 'Arauca') {
        return 'assets/images/chery_arauca.png';
      } else if (vehicle.make == 'Toyota' && vehicle.model == 'Corolla') {
        return 'assets/images/toyota_corolla.png';
      }
      return 'assets/images/default_car.png'; // Default image
    }

    return Card(
      color: isSelected
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? _primaryColor : _secondaryColor,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(
              getImagePath(),
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_car,
                  size: 70,
                  color: Colors.white70,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${vehicle.make} ${vehicle.model}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${vehicle.currentMileage} km",
                    style: TextStyle(
                      fontSize: 14,
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLocationEnabled)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: _primaryColor,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection(List<Vehicle> vehicles) {
    return SizedBox(
      height: 90,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.0),
        itemCount: vehicles.length,
        onPageChanged: (index) =>
            setState(() => _selectedVehicle = vehicles[index]),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedVehicle = vehicle),
              child: _buildVehicleCard(
                vehicle,
                _selectedVehicle?.id == vehicle.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMileageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Current Mileage *",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (_isLocationEnabled)
              ElevatedButton.icon(
                onPressed: _useAutoMileage,
                icon: const Icon(Icons.location_on, size: 16),
                label: const Text("Auto Mileage"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mileageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: _textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: "Enter current mileage",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixText: "km",
            suffixStyle: const TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: const Icon(Icons.speed, color: _secondaryColor),
          ),
        ),
        if (_isLocationEnabled && _autoMileage > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car, color: _primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Today's auto mileage: ${_autoMileage.toStringAsFixed(1)} km",
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_selectedVehicle != null)
                  Text(
                    "Total: ${_selectedVehicle!.currentMileage + _autoMileage.round()} km",
                    style: const TextStyle(
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (!_isLocationEnabled) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _showSnackBar(
                "Enable location services to use automatic mileage tracking.",
                isError: true,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Location tracking disabled - Auto mileage unavailable",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServicesSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Includes Services?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Switch(
          value: _hasServices,
          onChanged: (bool value) {
            setState(() {
              _hasServices = value;
              // Reset service selections when deactivating
              if (!value) {
                _selectedServices = _selectedServices.map(
                  (key, value) => MapEntry(key, false),
                );
              }
            });
          },
          activeColor: _primaryColor,
          inactiveTrackColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    if (!_hasServices) {
      return const SizedBox.shrink(); // Hide section if no services
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services Performed",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.85,
          ),
          itemCount: _availableServices.length,
          itemBuilder: (context, index) =>
              _buildServiceCard(_availableServices[index]),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notes (optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: _textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Add additional notes...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final bool canSave =
        _mileageController.text.isNotEmpty && _selectedVehicle != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSave ? _saveRecord : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? _primaryColor : _grey400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, size: 20),
            const SizedBox(width: 8),
            Text(
              "Save Record",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_isLocationEnabled && _autoMileage > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "AUTO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _textColor),
          SizedBox(height: 16),
          Text("Loading services...", style: TextStyle(color: _textColor)),
        ],
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
          const Text(
            "Error loading data",
            style: TextStyle(color: _textColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehiclesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined, color: _grey400, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No vehicles registered.',
            style: TextStyle(color: _textColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please add a vehicle first to record services.',
            style: TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<Vehicle> vehicles) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _servicesDataFuture,
      builder: (context, servicesSnapshot) {
        if (servicesSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (servicesSnapshot.hasData) {
          final servicesData = servicesSnapshot.data!;
          _availableServices = servicesData['services'] as List<Service>;
          _serviceIcons = servicesData['icons'] as Map<int, String>;
          if (_selectedServices.isEmpty) {
            _selectedServices = servicesData['selection'] as Map<int, bool>;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleSelection(vehicles),
              const SizedBox(height: 24),
              _buildMileageInput(),
              const SizedBox(height: 24),
              _buildServicesSwitch(),
              const SizedBox(height: 16),
              _buildServicesGrid(),
              const SizedBox(height: 24),
              _buildNotesInput(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _textColor),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          "Services",
          style: TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLocationEnabled)
            IconButton(
              icon: const Icon(Icons.location_on, color: Color(0xFF2AEFDA)),
              onPressed: () {
                _showSnackBar(
                  "Location tracking enabled - Auto mileage available",
                );
              },
              tooltip: "Location tracking active",
            ),
        ],
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, vehiclesSnapshot) {
          if (vehiclesSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (vehiclesSnapshot.hasError) {
            return _buildErrorWidget(vehiclesSnapshot.error.toString());
          } else if (!vehiclesSnapshot.hasData ||
              vehiclesSnapshot.data!.isEmpty) {
            return _buildNoVehiclesWidget();
          }

          final vehicles = vehiclesSnapshot.data!;
          _selectedVehicle ??= vehicles.first;

          return _buildMainContent(vehicles);
        },
      ),
    );
  }
}
