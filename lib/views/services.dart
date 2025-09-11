import 'package:flutter/material.dart';

// Importa los archivos de modelos y servicio de base de datos
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/database_service.dart';

class ServicesWiew extends StatefulWidget {
  const ServicesWiew({super.key});

  @override
  _ServicesWiewState createState() => _ServicesWiewState();
}

class _ServicesWiewState extends State<ServicesWiew> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _nuevoServicioController =
      TextEditingController();
  final Map<String, bool> _servicios = {
    "Cambio de Aceite": false,
    "Cambio de Correa de Tiempo": false,
    "Revisión de Frenos": false,
  };

  late Future<List<Vehicle>> _vehiclesFuture;
  Vehicle? _selectedVehicle;

  // String _getIconName(String serviceName) {
  //   switch (serviceName) {
  //     case "Cambio de Aceite":
  //       return 'oil_change';
  //     case "Cambio de Correa de Tiempo":
  //       return 'timing_belt';
  //     case "Revisión de Frenos":
  //       return 'brakes';
  //     default:
  //       return 'build';
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = DatabaseService.getVehicles();
  }

  void _agregarServicio() {
    if (_nuevoServicioController.text.isNotEmpty) {
      setState(() {
        _servicios[_nuevoServicioController.text] = true;
        _nuevoServicioController.clear();
      });
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

    final selectedServices = _servicios.keys.where(
      (s) => _servicios[s] == true,
    );

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona al menos un servicio.")),
      );
      return;
    }

    for (var serviceName in selectedServices) {
      // Obtener el iconName desde la base de datos
      final iconName = await DatabaseService.getIconNameForService(serviceName);

      final newRecord = ServiceRecord(
        vehicleId: _selectedVehicle!.id!,
        serviceName: serviceName,
        mileage: mileage,
        date: DateTime.now(),
        iconName: iconName,
        notes: _notasController.text.isEmpty ? null : _notasController.text,
        vehicleMake: _selectedVehicle!.make,
        vehicleModel: _selectedVehicle!.model,
      );
      await DatabaseService.addServiceRecord(newRecord);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Registro guardado con éxito.")));

    _kmController.clear();
    _notasController.clear();
    setState(() {
      _servicios.forEach((key, value) {
        _servicios[key] = false;
      });
    });
  }

  // Nuevo método para obtener la ruta de la imagen del vehículo
  String getVehicleImagePath(String make, String model) {
    if (make == 'Chery' && model == 'Arauca') {
      return 'assets/images/chery_arauca.png';
    }
    // Puedes agregar más casos aquí para otros vehículos
    return 'assets/images/toyota_corolla.png'; // Una imagen por defecto
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Services", style: TextStyle(color: Color(0xFF2AEFDA))),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay vehículos registrados.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final vehicles = snapshot.data!;
          _selectedVehicle ??= vehicles.first;

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
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        elevation: 4,
                        color: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xFF75A6B1), width: 1),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Imagen del vehículo a la izquierda
                              Image.asset(
                                getVehicleImagePath(
                                  vehicle.make,
                                  vehicle.model,
                                ),
                                height: 80, // Ajusta el tamaño de la imagen
                                width: 80,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 16),

                              // Texto de kilometraje a la derecha
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${vehicle.make} ${vehicle.model}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Kilometraje actual: ${vehicle.currentMileage} km",
                                      style: TextStyle(
                                        fontSize: 14,
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
                    labelText: "Kilometraje",
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
                ..._servicios.keys.map((s) {
                  return CheckboxListTile(
                    title: Text(s, style: TextStyle(color: Colors.white)),
                    value: _servicios[s],
                    activeColor: Color(0xFF75A6B1),
                    onChanged: (val) {
                      setState(() {
                        _servicios[s] = val ?? false;
                      });
                    },
                  );
                }),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nuevoServicioController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Agregar otro servicio",
                          labelStyle: TextStyle(color: Colors.grey[300]),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF75A6B1)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF75A6B1)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF75A6B1)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF75A6B1)),
                      onPressed: _agregarServicio,
                    ),
                  ],
                ),

                Divider(color: Color(0xFF75A6B1)),

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
                SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
