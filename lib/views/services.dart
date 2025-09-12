import 'package:flutter/material.dart';
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

      // Crear mapa de iconos por serviceId
      final Map<int, String> iconMap = {};
      for (var serviceData in servicesWithIcons) {
        iconMap[serviceData['id'] as int] = serviceData['iconData'] as String;
      }

      // Inicializar selección de servicios
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
      // En una implementación real, aquí agregarías el servicio a la BD
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
        final service = _availableServices.firstWhere(
          (s) => s.id == serviceId,
          orElse: () =>
              Service(id: serviceId, serviceName: 'Servicio', iconId: 1),
        );

        final newRecord = ServiceRecord(
          vehicleId: _selectedVehicle!.id!,
          serviceId: serviceId,
          mileage: mileage,
          date: DateTime.now(),
          notes: _notasController.text.isEmpty ? null : _notasController.text,
        );

        await DatabaseService.addServiceRecord(newRecord);
      }

      // Actualizar el kilometraje del vehículo
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

      // Limpiar formulario
      _kmController.clear();
      _notasController.clear();
      setState(() {
        _selectedServices = _selectedServices.map(
          (key, value) => MapEntry(key, false),
        );
      });

      // Actualizar datos
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

  Widget _buildServiceCheckbox(Service service, String iconName) {
    return CheckboxListTile(
      title: Row(
        children: [
          // Icono del servicio (puedes usar un widget de imagen)
          Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getIconForService(iconName),
              size: 18,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              service.serviceName,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      value: _selectedServices[service.id] ?? false,
      activeColor: Color(0xFF75A6B1),
      onChanged: (val) {
        setState(() {
          _selectedServices[service.id!] = val ?? false;
        });
      },
    );
  }

  IconData _getIconForService(String iconName) {
    // Mapeo de nombres de iconos a IconData
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
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2AEFDA)),
          onPressed: () => Navigator.pop(context),
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

                    // Selector de vehículo
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
                                  padding: EdgeInsets.all(
                                    12,
                                  ), // Reducir padding interno
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        getVehicleImagePath(
                                          vehicle.make,
                                          vehicle.model,
                                        ),
                                        height: 80, // Reducir tamaño de imagen
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
                                                fontSize:
                                                    16, // Reducir tamaño de fuente
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ), // Reducir espacio entre líneas
                                            Text(
                                              "${vehicle.currentMileage} km",
                                              style: TextStyle(
                                                fontSize:
                                                    12, // Reducir tamaño de fuente
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            Text(
                                              "Último servicio: ${vehicle.lastServiceMileage} km",
                                              style: TextStyle(
                                                fontSize:
                                                    10, // Reducir tamaño de fuente
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

                    // Kilometraje
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

                    // Servicios
                    Text(
                      "Servicios Realizados",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),

                    ..._availableServices.map((service) {
                      final iconName =
                          _serviceIcons[service.id] ?? 'default_icon';
                      return _buildServiceCheckbox(service, iconName);
                    }).toList(),

                    // Agregar servicio personalizado (opcional)
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

                    // Notas
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

                    // Botón Guardar
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
