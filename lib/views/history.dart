// history.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/utils/icon_helper.dart';
import 'package:car_service_app/services/database_service.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late Future<List<Map<String, dynamic>>> _serviceRecordsFuture;

  @override
  void initState() {
    super.initState();
    _serviceRecordsFuture = DatabaseService.getServiceRecordsWithDetails();
  }

  void _refreshData() {
    setState(() {
      _serviceRecordsFuture = DatabaseService.getServiceRecordsWithDetails();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildServiceRecordCard(Map<String, dynamic> record) {
    final serviceName = record['serviceName'] as String? ?? 'Servicio';
    final vehicleMake = record['vehicleMake'] as String? ?? '';
    final vehicleModel = record['vehicleModel'] as String? ?? '';
    final mileage = record['mileage'] as int? ?? 0;
    final date = DateTime.parse(record['date'] as String);
    final notes = record['notes'] as String?;
    final iconName = record['serviceIcon'] as String? ?? 'Cambio de Aceite';

    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFF75A6B1).withOpacity(0.5), width: 1),
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
            getIconData(iconName),
            color: Colors.blue.shade200,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$vehicleMake $vehicleModel',
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.speed, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 4),
                  Text(
                    '$mileage km',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
              if (notes != null && notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: Colors.grey[600], height: 1),
                      SizedBox(height: 8),
                      Text(
                        'Notas:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        notes,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          // Opcional: Navegar a detalles del servicio
          _showServiceDetails(record);
        },
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Detalles del Servicio',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Servicio', record['serviceName'] as String),
              _buildDetailItem(
                'Vehículo',
                '${record['vehicleMake']} ${record['vehicleModel']}',
              ),
              _buildDetailItem('Kilometraje', '${record['mileage']} km'),
              _buildDetailItem(
                'Fecha',
                _formatDate(DateTime.parse(record['date'] as String)),
              ),
              if (record['notes'] != null &&
                  (record['notes'] as String).isNotEmpty)
                _buildDetailItem('Notas', record['notes'] as String),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: Color(0xFF2AEFDA))),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
              fontSize: 12,
            ),
          ),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 14)),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2AEFDA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial de Servicios",
          style: TextStyle(color: Color(0xFF2AEFDA)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2AEFDA)),
            onPressed: _refreshData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviceRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    "Error al cargar el historial",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(color: Colors.grey[300]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2AEFDA),
                    ),
                    child: Text("Reintentar"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.grey[400], size: 64),
                  SizedBox(height: 16),
                  Text(
                    "No hay registros de servicio",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Los servicios que agregues aparecerán aquí",
                    style: TextStyle(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!;

          // Create a mutable copy and sort by date (most recent first)
          final mutableRecords = List<Map<String, dynamic>>.from(records);
          mutableRecords.sort((a, b) {
            final dateA = DateTime.parse(a['date'] as String);
            final dateB = DateTime.parse(b['date'] as String);
            return dateB.compareTo(dateA);
          });

          final sortedRecords = mutableRecords;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              await Future.delayed(Duration(milliseconds: 500));
            },
            color: Color(0xFF2AEFDA),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                return _buildServiceRecordCard(sortedRecords[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
