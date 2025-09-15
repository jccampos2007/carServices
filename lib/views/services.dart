// services.dart (ajustes y refactorización)

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
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _nuevoServicioController =
      TextEditingController();

  Map<int, bool> _selectedServices = {}; // Map<serviceId, isSelected>
  List<Service> _availableServices = [];
  Map<int, String> _serviceIcons = {}; // Map<serviceId, iconName>

  late Future<List<Vehicle>> _vehiclesFuture;
  Vehicle? _selectedVehicle;
  late Future<Map<String, dynamic>> _servicesDataFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = DatabaseService.getVehicles();
    _servicesDataFuture = _loadServicesData();
  }

  Future<Map<String, dynamic>> _loadServicesData() async {
    try {
      final services = await DatabaseService.getServices();
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

  void _agregarServicioPersonalizado() {
    if (_nuevoServicioController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Función para agregar servicios personalizados próximamente",
          ),
        ),
      );
      _nuevoServicioController.clear();
    }
  }

  Future<void> _guardarRegistro() async {
    if (_selectedVehicle == null || _kmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor, selecciona un vehículo y el kilometraje."),
        ),
      );
      return;
    }

    final int mileage = int.tryParse(_kmController.text) ?? 0;
    if (mileage == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa un kilometraje válido.")),
      );
      return;
    }

    final selectedServiceIds = _selectedServices.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona al menos un servicio.")),
      );
      return;
    }

    try {
      for (var serviceId in selectedServiceIds) {
        final newRecord = ServiceRecord(
          vehicleId: _selectedVehicle!.id!,
          serviceId: serviceId,
          mileage: mileage,
          date: DateTime.now(),
          notes: _notasController.text.isEmpty ? null : _notasController.text,
        );

        await DatabaseService.addServiceRecord(newRecord);
      }

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registro guardado con éxito.")));

      _kmController.clear();
      _notasController.clear();
      setState(() {
        _selectedServices = _selectedServices.map(
          (key, value) => MapEntry(key, false),
        );
      });

      _vehiclesFuture = DatabaseService.getVehicles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el registro: $e")),
      );
    }
  }

  String getVehicleImagePath(String make, String model) {
    if (make == 'Chery' && model == 'Arauca') {
      return 'assets/images/chery_arauca.png';
    } else if (make == 'Toyota' && model == 'Corolla') {
      return 'assets/images/toyota_corolla.png';
    }
    return 'assets/images/default_car.png';
  }

  IconData _getIconForService(String iconName) {
    final iconMap = {
      'oil_change': Icons.local_car_wash,
      'air_filter': Icons.air,
      'brakes': Icons.fiber_manual_record,
      'tire_rotation': Icons.rotate_right,
      'alignment': Icons.straighten,
      'battery': Icons.battery_charging_full,
      'timing_belt': Icons.settings,
      'car_wash': Icons.local_car_wash,
      'default_icon': Icons.build,
    };
    return iconMap[iconName] ?? Icons.build;
  }

  // Nuevo widget para la tarjeta de servicio
  Widget _buildServiceCard(Service service) {
    final iconName = _serviceIcons[service.id] ?? 'default_icon';
    final isSelected = _selectedServices[service.id] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedServices[service.id!] = !isSelected;
        });
      },
      child: Card(
        color: isSelected ? Color(0xFF75A6B1) : Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Color(0xFF2AEFDA) : Color(0xFF75A6B1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForService(iconName),
              size: 40,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            SizedBox(height: 8),
            Text(
              service.serviceName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2AEFDA)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text("Servicios", style: TextStyle(color: Color(0xFF2AEFDA))),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, vehiclesSnapshot) {
          if (vehiclesSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (vehiclesSnapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${vehiclesSnapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!vehiclesSnapshot.hasData ||
              vehiclesSnapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay vehículos registrados.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final vehicles = vehiclesSnapshot.data!;
          _selectedVehicle ??= vehicles.first;

          return FutureBuilder<Map<String, dynamic>>(
            future: _servicesDataFuture,
            builder: (context, servicesSnapshot) {
              if (servicesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (servicesSnapshot.hasData) {
                final servicesData = servicesSnapshot.data!;
                _availableServices = servicesData['services'] as List<Service>;
                _serviceIcons = servicesData['icons'] as Map<int, String>;
                if (_selectedServices.isEmpty) {
                  _selectedServices =
                      servicesData['selection'] as Map<int, bool>;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kToolbarHeight + 53),
                    SizedBox(
                      height: 110,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 1),
                        itemCount: vehicles.length,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedVehicle = vehicles[index];
                          });
                        },
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 0),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedVehicle = vehicle),
                              child: Card(
                                elevation: 4,
                                color: _selectedVehicle?.id == vehicle.id
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: _selectedVehicle?.id == vehicle.id
                                        ? Color(0xFF2AEFDA)
                                        : Color(0xFF75A6B1),
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        getVehicleImagePath(
                                          vehicle.make,
                                          vehicle.model,
                                        ),
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${vehicle.make} ${vehicle.model}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "${vehicle.currentMileage} km",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            Text(
                                              "Último servicio: ${vehicle.lastServiceMileage} km",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Kilometraje actual",
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                        suffixText: "km",
                        suffixStyle: TextStyle(color: Colors.grey[300]),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Servicios Realizados",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Usar GridView para los servicios
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _availableServices.length,
                      itemBuilder: (context, index) {
                        final service = _availableServices[index];
                        return _buildServiceCard(service);
                      },
                    ),

                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nuevoServicioController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Agregar servicio personalizado",
                              labelStyle: TextStyle(color: Colors.grey[300]),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF75A6B1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Color(0xFF75A6B1)),
                          onPressed: _agregarServicioPersonalizado,
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFF75A6B1)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _notasController,
                      maxLines: 3,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Notas (opcional)",
                        labelStyle: TextStyle(color: Colors.grey[300]),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF75A6B1)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0x8074cfde),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Guardar Registro",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
