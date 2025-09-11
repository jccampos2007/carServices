// settings.dart
import 'package:flutter/material.dart';

// Importa los archivos de modelos y servicio de base de datos
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/database_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2AEFDA)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Setting", style: TextStyle(color: Color(0xFF2AEFDA))),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: DatabaseService.getVehicles(),
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
                "Error al cargar vehículos: ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];
          final int registrationLimit = 3; // Límite de vehículos

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de gestión de vehículos
                Text(
                  "Mis Vehículos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Vehículos registrados (${vehicles.length}/$registrationLimit):",
                  style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                ),

                SizedBox(height: 16),

                vehicles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Aún no tienes vehículos registrados.",
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            color: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Color(0xFF75A6B1),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.directions_car,
                                color: Colors.white,
                              ),
                              title: Text(
                                "${vehicle.make} ${vehicle.model}",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Kilometraje: ${vehicle.currentMileage} km",
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Ver detalles de ${vehicle.make} ${vehicle.model}",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                SizedBox(height: 24),
                Divider(color: Color(0xFF75A6B1)),
                SizedBox(height: 24),

                // Opciones de configuración
                Text(
                  "Ajustes de la Aplicación",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                Card(
                  color: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF75A6B1), width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.notifications, color: Colors.white),
                        title: Text(
                          "Notificaciones",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Switch(
                          value: true,
                          activeColor: Color(0xFF75A6B1),
                          onChanged: (bool value) {},
                        ),
                      ),
                      Divider(color: Color(0xFF75A6B1), height: 1),
                      ListTile(
                        leading: Icon(Icons.lock, color: Colors.white),
                        title: Text(
                          "Cambiar Contraseña",
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                      Divider(color: Color(0xFF75A6B1), height: 1),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[300]),
                        title: Text(
                          "Cerrar Sesión",
                          style: TextStyle(color: Colors.red[300]),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red[300],
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),
                Divider(color: Color(0xFF75A6B1)),
                SizedBox(height: 24),

                // Información de la aplicación
                Text(
                  "Información de la App",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                Card(
                  color: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF75A6B1), width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Versión",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "1.0.0",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                      Divider(color: Color(0xFF75A6B1), height: 1),
                      ListTile(
                        title: Text(
                          "Desarrollador",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Car Service Team",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
