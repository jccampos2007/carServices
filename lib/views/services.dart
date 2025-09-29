// services.dart (mejorado con mejor UI/UX)
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/services/database_service.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  _ServicesViewState createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  // Controladores
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _nuevoServicioController =
      TextEditingController();

  // Estado
  Map<int, bool> _selectedServices = {};
  List<Service> _availableServices = [];
  Map<int, String> _serviceIcons = {};
  Vehicle? _selectedVehicle;

  // Futures
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<Map<String, dynamic>> _servicesDataFuture;

  // Constantes
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _vehiclesFuture = DatabaseService.getVehicles();
    _servicesDataFuture = _loadServicesData();
  }

  Future<Map<String, dynamic>> _loadServicesData() async {
    try {
      // Obtener servicios usando DatabaseService
      final services = await DatabaseService.getServices();

      // Obtener servicios con iconos usando el método específico
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
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _agregarServicioPersonalizado() {
    if (_nuevoServicioController.text.isNotEmpty) {
      _showSnackBar(
        "Función para agregar servicios personalizados próximamente",
      );
      _nuevoServicioController.clear();
    }
  }

  bool _validateInputs() {
    if (_selectedVehicle == null || _kmController.text.isEmpty) {
      _showSnackBar(
        "Por favor, selecciona un vehículo y el kilometraje.",
        isError: true,
      );
      return false;
    }

    final mileage = int.tryParse(_kmController.text) ?? 0;
    if (mileage == 0) {
      _showSnackBar("Por favor, ingresa un kilometraje válido.", isError: true);
      return false;
    }

    final selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedServiceIds.isEmpty) {
      _showSnackBar(
        "Por favor, selecciona al menos un servicio.",
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _guardarRegistro() async {
    if (!_validateInputs()) return;

    final mileage = int.parse(_kmController.text);
    final selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      await _saveServiceRecords(mileage, selectedServiceIds);
      await _updateVehicleData(mileage);

      _showSnackBar("Registro guardado con éxito.");
      _resetForm();
    } catch (e) {
      _showSnackBar("Error al guardar el registro: $e", isError: true);
    }
  }

  Future<void> _saveServiceRecords(int mileage, List<int> serviceIds) async {
    for (final serviceId in serviceIds) {
      final newRecord = ServiceRecord(
        vehicleId: _selectedVehicle!.id!,
        serviceId: serviceId,
        mileage: mileage,
        date: DateTime.now(),
        notes: _notasController.text.isEmpty ? null : _notasController.text,
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
    _kmController.clear();
    _notasController.clear();
    setState(() {
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
    };
    return iconMap[iconName] ?? Icons.build;
  }

  // Widgets de construcción MEJORADOS

  Widget _buildServiceCard(Service service) {
    final iconName = _serviceIcons[service.id] ?? 'default_icon';
    final isSelected = _selectedServices[service.id] ?? false;

    return GestureDetector(
      onTap: () => setState(() => _selectedServices[service.id!] = !isSelected),
      child: Container(
        margin: const EdgeInsets.all(4), // Más espacio entre cards
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12), // Bordes más redondeados
          border: Border.all(
            color: isSelected ? Colors.white : _secondaryColor,
            width: 2, // Borde más grueso para mejor feedback táctil
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12), // Área de toque más grande
              child: Icon(
                _getIconForService(iconName),
                size: 32, // Íconos más grandes
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
    // Determinar la imagen basada en make y model si imageUrl está vacío
    String getImagePath() {
      if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty) {
        return vehicle.imageUrl!;
      }
      // Fallback basado en make y model
      if (vehicle.make == 'Chery' && vehicle.model == 'Arauca') {
        return 'assets/images/chery_arauca.png';
      } else if (vehicle.make == 'Toyota' && vehicle.model == 'Corolla') {
        return 'assets/images/toyota_corolla.png';
      }
      return 'assets/images/default_car.png'; // Imagen por defecto
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
        padding: const EdgeInsets.all(12), // Más padding
        child: Row(
          children: [
            Image.asset(
              getImagePath(),
              width: 70, // Imagen ligeramente más pequeña
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
                      fontSize: 16, // Texto más grande
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${vehicle.currentMileage} km",
                    style: TextStyle(
                      fontSize: 14, // Texto más grande
                      color: _primaryColor, // Usar cyan para el kilometraje
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection(List<Vehicle> vehicles) {
    return SizedBox(
      height: 90, // Altura ligeramente mayor
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
        Text(
          "Kilometraje actual",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Título en blanco con negrita
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _kmController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: _textColor,
            fontSize: 16,
          ), // Texto más grande
          decoration: InputDecoration(
            hintText: "Ingresa el kilometraje",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: _primaryColor,
              ), // Cyan cuando está enfocado
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, // Más padding interno
              vertical: 14,
            ),
            suffixText: "km",
            suffixStyle: const TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Servicios Realizados",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Título en blanco con negrita
          ),
        ),
        const SizedBox(height: 12), // Espaciado reducido
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0, // Más espacio entre columnas
            mainAxisSpacing: 8.0, // Más espacio entre filas
            childAspectRatio: 0.85, // Proporción ligeramente ajustada
          ),
          itemCount: _availableServices.length,
          itemBuilder: (context, index) =>
              _buildServiceCard(_availableServices[index]),
        ),
      ],
    );
  }

  Widget _buildCustomServiceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agregar servicio personalizado",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Título en blanco con negrita
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nuevoServicioController,
                style: const TextStyle(color: _textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Nombre del servicio...",
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                onPressed: _agregarServicioPersonalizado,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notas (opcional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Título en blanco con negrita
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notasController,
          maxLines: 3,
          style: const TextStyle(color: _textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Agregar notas adicionales...",
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
            contentPadding: const EdgeInsets.all(16), // Más padding interno
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardarRegistro,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor, // Usar cyan primario
          padding: const EdgeInsets.symmetric(vertical: 16), // Más alto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
          ),
        ),
        child: const Text(
          "Guardar Registro",
          style: TextStyle(
            fontSize: 16, // Texto más grande
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

  Widget _buildNoVehiclesWidget() {
    return const Center(
      child: Text(
        'No hay vehículos registrados.',
        style: TextStyle(color: _textColor),
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
          padding: const EdgeInsets.all(16.0), // Más padding general
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleSelection(vehicles),
              const SizedBox(height: 24), // Más espacio entre secciones
              _buildMileageInput(),
              const SizedBox(height: 24), // Más espacio entre secciones
              _buildServicesGrid(),
              const SizedBox(height: 24), // Más espacio entre secciones
              _buildCustomServiceInput(),
              const SizedBox(height: 24), // Más espacio entre secciones
              _buildNotesInput(),
              const SizedBox(height: 24), // Más espacio entre secciones
              _buildSaveButton(),
              const SizedBox(height: 24), // Más espacio al final
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
        // ELIMINADO: Botón de volver (redundante con Bottom Navigation)
        title: Text(
          "Servicios",
          style: TextStyle(
            color: Colors.white, // Título en blanco
            fontSize: 20, // Tamaño consistente con otras pantallas
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
