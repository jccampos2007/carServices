// history.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/utils/icon_helper.dart';
import 'package:car_service_app/services/database_service.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  static const _backgroundColor = Colors.transparent;
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);
  static const _grey400 = Color(0xFFBDBDBD);
  static const _grey600 = Color(0xFF757575);

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
    final serviceName = record['serviceName'] as String? ?? 'Service';
    final vehicleMake = record['vehicleMake'] as String? ?? '';
    final vehicleModel = record['vehicleModel'] as String? ?? '';
    final mileage = record['mileage'] as int? ?? 0;
    final date = DateTime.parse(record['date'] as String);
    final notes = record['notes'] as String?;
    final iconName = record['serviceIcon'] as String? ?? 'oil_change';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _secondaryColor.withOpacity(0.5), width: 1),
      ),
      color: Colors.black.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$vehicleMake $vehicleModel',
              style: const TextStyle(color: _grey300, fontSize: 14),
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
                  const Icon(Icons.speed, size: 16, color: _grey400),
                  const SizedBox(width: 4),
                  Text('$mileage km', style: const TextStyle(color: _grey300)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: _grey400),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(color: _grey300),
                  ),
                ],
              ),
              if (notes != null && notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: _grey600, height: 1),
                      const SizedBox(height: 8),
                      const Text(
                        'Notes:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _grey300,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        notes,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: _grey300,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: _grey400,
          size: 16,
        ),
        onTap: () {
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
        title: const Text(
          'Service Details',
          style: TextStyle(color: _textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Service', record['serviceName'] as String),
              _buildDetailItem(
                'Vehicle',
                '${record['vehicleMake']} ${record['vehicleModel']}',
              ),
              _buildDetailItem('Mileage', '${record['mileage']} km'),
              _buildDetailItem(
                'Date',
                _formatDate(DateTime.parse(record['date'] as String)),
              ),
              if (record['notes'] != null &&
                  (record['notes'] as String).isNotEmpty)
                _buildDetailItem('Notes', record['notes'] as String),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: _primaryColor)),
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _grey300,
              fontSize: 12,
            ),
          ),
          Text(value, style: const TextStyle(color: _textColor, fontSize: 14)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
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
            "Error loading history",
            style: TextStyle(color: _textColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: _grey400, size: 64),
          const SizedBox(height: 16),
          const Text(
            "No service records",
            style: TextStyle(
              color: _grey300,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Services you add will appear here",
            style: TextStyle(color: _grey400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
          "Service History",
          style: TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviceRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
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
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: _primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
