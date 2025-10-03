// settings.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  static const _backgroundColor = Colors.transparent;
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);
  static const _grey400 = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        title: const Text(
          "Settings",
          style: TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: DatabaseService.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading vehicles: ${snapshot.error}",
                style: const TextStyle(color: _textColor),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];
          const int registrationLimit = 3; // Vehicle limit

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle management section
                const Text(
                  "My Vehicles",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Registered vehicles (${vehicles.length}/$registrationLimit):",
                  style: const TextStyle(fontSize: 16, color: _grey300),
                ),

                const SizedBox(height: 16),

                vehicles.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "You don't have any registered vehicles yet.",
                            style: TextStyle(color: _grey300),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: _secondaryColor,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.directions_car,
                                color: _textColor,
                              ),
                              title: Text(
                                "${vehicle.make} ${vehicle.model}",
                                style: const TextStyle(color: _textColor),
                              ),
                              subtitle: Text(
                                "Mileage: ${vehicle.currentMileage} km",
                                style: const TextStyle(color: _grey300),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: _textColor,
                                size: 16,
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "View details of ${vehicle.make} ${vehicle.model}",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 24),
                const Divider(color: _secondaryColor),
                const SizedBox(height: 24),

                // Application settings options
                const Text(
                  "App Settings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: _secondaryColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: _textColor,
                        ),
                        title: const Text(
                          "Notifications",
                          style: TextStyle(color: _textColor),
                        ),
                        trailing: Switch(
                          value: true,
                          activeColor: _secondaryColor,
                          onChanged: (bool value) {},
                        ),
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock, color: _textColor),
                        title: const Text(
                          "Change Password",
                          style: TextStyle(color: _textColor),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: _textColor,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[300]),
                        title: Text(
                          "Sign Out",
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

                const SizedBox(height: 24),
                const Divider(color: _secondaryColor),
                const SizedBox(height: 24),

                // App information
                const Text(
                  "App Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: _secondaryColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          "Version",
                          style: TextStyle(color: _textColor),
                        ),
                        subtitle: const Text(
                          "1.0.0",
                          style: TextStyle(color: _grey300),
                        ),
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        title: const Text(
                          "Developer",
                          style: TextStyle(color: _textColor),
                        ),
                        subtitle: const Text(
                          "Car Service Team",
                          style: TextStyle(color: _grey300),
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
