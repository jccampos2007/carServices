import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importa tus vistas
import 'package:car_service_app/views/dashboard.dart';
import 'package:car_service_app/views/services.dart';
import 'package:car_service_app/views/settings.dart';
import 'package:car_service_app/views/history.dart';

// Modelos de datos
class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int initialMileage;
  final int currentMileage;
  final DateTime lastServiceDate;
  final int lastServiceMileage;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.initialMileage,
    required this.currentMileage,
    required this.lastServiceDate,
    required this.lastServiceMileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'initialMileage': initialMileage,
      'currentMileage': currentMileage,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
    };
  }

  static Vehicle fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      initialMileage: map['initialMileage'],
      currentMileage: map['currentMileage'],
      lastServiceDate: DateTime.parse(map['lastServiceDate']),
      lastServiceMileage: map['lastServiceMileage'],
    );
  }
}

class ServiceRecord {
  final int? id;
  final int vehicleId;
  final String serviceName;
  final int mileage;
  final DateTime date;
  final String iconName;
  final String? notes;
  final String? vehicleMake;
  final String? vehicleModel;

  ServiceRecord({
    this.id,
    required this.vehicleId,
    required this.serviceName,
    required this.mileage,
    required this.date,
    required this.iconName,
    this.notes,
    this.vehicleMake,
    this.vehicleModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'serviceName': serviceName,
      'mileage': mileage,
      'date': date.toIso8601String(),
      'iconName': iconName,
      'notes': notes,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
    };
  }
}

Future<void> resetDatabase() async {
  String path = join(await getDatabasesPath(), 'car_service_app.db');
  await deleteDatabase(path);
}

// Servicio de base de datos
class DatabaseService {
  static Database? _database;
  static const String _vehiclesTableName = 'vehicles';
  static const String _servicesTableName = 'service_records';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    await deleteDatabase(join(await getDatabasesPath(), 'car_service_app.db'));
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'car_service_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_vehiclesTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            make TEXT NOT NULL,
            model TEXT NOT NULL,
            initialMileage INTEGER NOT NULL,
            currentMileage INTEGER NOT NULL,
            lastServiceDate TEXT NOT NULL,
            lastServiceMileage INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_servicesTableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicleId INTEGER,
            serviceName TEXT NOT NULL,
            mileage INTEGER NOT NULL,
            date TEXT NOT NULL,
            iconName TEXT NOT NULL,
            notes TEXT,
            FOREIGN KEY (vehicleId) REFERENCES $_vehiclesTableName(id) ON DELETE CASCADE
          )
        ''');
        // Insert a dummy vehicle for testing
        final vehicleId = await db.insert(_vehiclesTableName, {
          'make': 'Chery',
          'model': 'Arauca',
          'initialMileage': 5000,
          'currentMileage': 52000,
          'lastServiceDate': DateTime.now()
              .subtract(Duration(days: 100))
              .toIso8601String(),
          'lastServiceMileage': 50000,
        });

        final vehicleId2 = await db.insert(_vehiclesTableName, {
          'make': 'Toyota',
          'model': 'Corolla',
          'initialMileage': 10000,
          'currentMileage': 120000,
          'lastServiceDate': DateTime.now()
              .subtract(Duration(days: 100))
              .toIso8601String(),
          'lastServiceMileage': 135000,
        });

        // Usa el vehicleId real
        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Aceite',
          'mileage': 51000,
          'date': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
          'iconName': 'oil',
          'notes': 'Aceite sintético 10W-40',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Filtro de Aire',
          'mileage': 51500,
          'date': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
          'iconName': 'air_filter',
          'notes': 'Filtro de aire reemplazado',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Pastillas de Freno',
          'mileage': 52000,
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'iconName': 'brake',
          'notes': 'Pastillas delanteras cambiadas',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId2,
          'serviceName': 'Cambio de Pastillas de Freno',
          'mileage': 130000,
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'iconName': 'brake',
          'notes': 'Pastillas delanteras cambiadas',
        });
      },
    );
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_vehiclesTableName);
    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  static Future<List<ServiceRecord>> getServiceRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.id, s.vehicleId, s.serviceName, s.mileage, s.date, 
            s.iconName, s.notes,
            v.make as vehicleMake, v.model as vehicleModel
      FROM $_servicesTableName s
      JOIN $_vehiclesTableName v ON s.vehicleId = v.id
      ORDER BY s.date DESC
    ''');
    return List.generate(maps.length, (i) {
      return ServiceRecord(
        id: maps[i]['id'],
        vehicleId: maps[i]['vehicleId'],
        serviceName: maps[i]['serviceName'],
        mileage: maps[i]['mileage'],
        date: DateTime.parse(maps[i]['date']),
        iconName: maps[i]['iconName'],
        notes: maps[i]['notes'],
        vehicleMake: maps[i]['vehicleMake'],
        vehicleModel: maps[i]['vehicleModel'],
      );
    });
  }

  static Future<void> insertServiceRecord(ServiceRecord record) async {
    final db = await database;
    await db.insert(
      _servicesTableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Puedes agregar más funciones CRUD (Crear, Leer, Actualizar, Eliminar)
  // para vehículos y registros de servicio.
}

// Clase principal de la aplicación
void main() {
  runApp(CarServiceApp());
}

class CarServiceApp extends StatelessWidget {
  const CarServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Service App',
      theme: ThemeData(
        // Tema oscuro para la app
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0F1F),
        // Color del fondo de la navegación inferior
        canvasColor: Color(0xFF10162A),
        // Usa una fuente similar a la de la imagen si la tienes
        // fontFamily: 'TuFuente',
        // Define colores de acento
        colorScheme: ColorScheme.dark(
          primary: Color(
            0xFF00FFC0,
          ), // Verde brillante/Cian para elementos seleccionados
        ),
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

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardView(),
    ServicesWiew(),
    HistoryView(),
    SettingsView(),
  ];

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
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07303D), // #07303d
                    Color(0xFF040D0F), // #040d0f
                  ],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07303D), // #07303d
                    Color(0xFF040D0F), // #040d0f
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF07303D), // #07303d
                    Color(0xFF040D0F), // #040d0f
                  ],
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
        } else {
          // Si hay vehículos, muestra la UI principal
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF07303D), // #07303d
                  Color(0xFF040D0F), // #040d0f
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Color(0xFF10162A), // Fondo oscuro de la barra
                selectedItemColor: Color(
                  0xFF00FFC0,
                ), // Color de ítem seleccionado
                unselectedItemColor:
                    Colors.white54, // Color de ítems no seleccionados
                showUnselectedLabels: true,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), // Ícono de contorno
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_outlined), // Ícono de contorno
                    label: 'Services',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined), // Ícono de contorno
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), // Ícono de contorno
                    label: 'Setting',
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
