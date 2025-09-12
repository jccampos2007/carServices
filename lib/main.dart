import 'package:flutter/material.dart';
import 'package:path/path.dart';

// Importa tus vistas
import 'package:car_service_app/views/dashboard.dart';
import 'package:car_service_app/views/services.dart';
import 'package:car_service_app/views/settings.dart';
import 'package:car_service_app/views/history.dart';

// Importa los archivos de modelos y servicio de base de datos
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initializeDb(); // Inicializa la base de datos
  runApp(CarServiceApp());
}

class CarServiceApp extends StatelessWidget {
  const CarServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Service App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0F1F),
        canvasColor: Color(0xFF10162A),
        colorScheme: ColorScheme.dark(primary: Color(0xFF2AEFDA)),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = DatabaseService.getVehicles();
  }

  List<Widget> get _widgetOptions {
    return <Widget>[
      DashboardView(onNavigateToServices: () => _onItemTapped(1)),
      ServicesView(),
      HistoryView(),
      SettingsView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vehicle>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoVehiclesScreen();
        } else {
          return _buildMainScaffold();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: Text('Error: $error', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildNoVehiclesScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: Text(
            'No hay vehículos registrados.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScaffold() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07303D), Color(0xFF040D0F)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: _widgetOptions[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF10162A),
          selectedItemColor: Color(0xFF2AEFDA),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_outlined),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
