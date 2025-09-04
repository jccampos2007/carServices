// history.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  IconData getIconData(String iconName) {
    switch (iconName) {
      case 'oil_change':
        return Icons.oil_barrel;
      case 'tire_rotation':
        return Icons.swap_horiz;
      case 'brakes':
        return Icons.car_crash;
      case 'timing_belt':
        return Icons.access_time;
      case 'air_filter':
        return Icons.filter_alt;
      case 'spark_plugs':
        return Icons.electrical_services;
      case 'oil':
        return Icons.oil_barrel;
      case 'brake':
        return Icons.car_crash;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Historial de Servicios",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ServiceRecord>>(
        future: DatabaseService.getServiceRecords(),
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
                "Error al cargar el historial: ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No hay registros de servicio.",
                style: TextStyle(color: Colors.grey[300]),
              ),
            );
          }

          final records = snapshot.data!;
          final sortedRecords = List<ServiceRecord>.from(records)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              final record = sortedRecords[index];
              return Card(
                elevation: 0,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Color(0xFF75A6B1).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                color: Colors.black.withOpacity(0.3),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getIconData(record.iconName),
                      color: Colors.blue.shade200,
                    ),
                  ),
                  title: Text(
                    record.serviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${record.vehicleMake} ${record.vehicleModel}",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kilometraje: ${record.mileage} km",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Text(
                          "Fecha: ${record.date.day}/${record.date.month}/${record.date.year}",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        if (record.notes != null && record.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Notas: ${record.notes}",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[300],
                              ),
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
    );
  }
}
