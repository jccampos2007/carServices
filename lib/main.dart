import 'package:flutter/material.dart';

// Importa tus vistas
import 'package:car_service_app/views/dashboard.dart';
import 'package:car_service_app/views/services.dart';
import 'package:car_service_app/views/settings.dart';
import 'package:car_service_app/views/history.dart';

// Importa los archivos de modelos y servicio de base de datos
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initializeDb(); // Inicializa la base de datos
  await LocationService.initialize(); // Inicializa el servicio de ubicación
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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Future<List<Vehicle>> _vehiclesFuture;
  double _todayDistance = 0.0;
  bool _locationEnabled = false;
  late LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _vehiclesFuture = DatabaseService.getVehicles();
    _initializeLocation();
  }

  void _initializeLocation() async {
    _locationEnabled = await _locationService.checkLocationPermission();

    if (_locationEnabled) {
      // Iniciar seguimiento de ubicación
      await _locationService.startLocationTracking();

      // Escuchar actualizaciones de distancia
      _locationService.distanceStream.listen((distance) {
        if (mounted) {
          setState(() {
            _todayDistance = distance;
          });
        }
      });
    }
  }

  List<Widget> get _widgetOptions {
    return <Widget>[
      DashboardView(
        onNavigateToServices: () => _onItemTapped(1),
        onNavigateToHistory: () => _onItemTapped(2),
        onNavigateToSettings: () => _onItemTapped(3),
        todayDistance: _todayDistance,
        locationEnabled: _locationEnabled,
      ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Error loading data',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: Colors.white54,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'No vehicles registered',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please add a vehicle to get started',
                style: TextStyle(color: Colors.white70),
              ),
            ],
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
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF10162A),
          selectedItemColor: Color(0xFF2AEFDA),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
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
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
