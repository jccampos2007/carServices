// database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';

class DatabaseService {
  static Database? _database;
  static const String _vehiclesTableName = 'vehicles';
  static const String _servicesTableName = 'service_records';
  static const String _serviceIconsTableName = 'service_icons';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  static Future<Database> _initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'car_service_app.db');

    // await deleteDatabase(path);

    return openDatabase(
      path,
      version: 6, // Incrementa la versión por los cambios
      onCreate: (db, version) async {
        // Tabla de vehículos
        await db.execute(
          'CREATE TABLE vehicles(id INTEGER PRIMARY KEY AUTOINCREMENT, make TEXT, model TEXT, initialMileage INTEGER, currentMileage INTEGER, lastServiceDate TEXT, lastServiceMileage INTEGER)',
        );

        // Tabla de iconos de servicio
        await db.execute(
          'CREATE TABLE service_icons(id INTEGER PRIMARY KEY AUTOINCREMENT, serviceName TEXT UNIQUE, iconName TEXT)',
        );

        // Tabla de registros de servicio (sin vehicleMake y vehicleModel)
        await db.execute(
          'CREATE TABLE service_records(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, serviceName TEXT, mileage INTEGER, date TEXT, notes TEXT, FOREIGN KEY (vehicleId) REFERENCES vehicles (id), FOREIGN KEY (serviceName) REFERENCES service_icons (serviceName))',
        );

        // Insertar vehículos de prueba
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

        // Insertar iconos de servicio
        await _populateServiceIcons(db);

        // Insertar registros de servicio (sin vehicleMake y vehicleModel)
        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Aceite',
          'mileage': 51000,
          'date': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
          'notes': 'Aceite sintético 10W-40',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Filtro de Aire',
          'mileage': 51500,
          'date': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
          'notes': 'Filtro de aire reemplazado',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId,
          'serviceName': 'Cambio de Pastillas de Freno',
          'mileage': 52000,
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'notes': 'Pastillas delanteras cambiadas',
        });

        await db.insert(_servicesTableName, {
          'vehicleId': vehicleId2,
          'serviceName': 'Cambio de Pastillas de Freno',
          'mileage': 130000,
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'notes': 'Pastillas delanteras cambiadas',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Eliminar tabla antigua
          await db.execute('DROP TABLE IF EXISTS service_records');

          // Crear tabla de iconos
          await db.execute(
            'CREATE TABLE IF NOT EXISTS service_icons(id INTEGER PRIMARY KEY AUTOINCREMENT, serviceName TEXT UNIQUE, iconName TEXT)',
          );

          // Crear nueva tabla de registros
          await db.execute(
            'CREATE TABLE service_records(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, serviceName TEXT, mileage INTEGER, date TEXT, notes TEXT, FOREIGN KEY (vehicleId) REFERENCES vehicles (id), FOREIGN KEY (serviceName) REFERENCES service_icons (serviceName))',
          );

          // Poblar iconos
          await _populateServiceIcons(db);
        }
      },
    );
  }

  // Método para poblar iconos de servicio
  static Future<void> _populateServiceIcons(Database db) async {
    final serviceIcons = {
      'Cambio de Aceite': 'oil_change',
      'Cambio de Filtro de Aire': 'air_filter',
      'Cambio de Pastillas de Freno': 'brakes',
      'Rotación de Llantas': 'tire_rotation',
      'Alineación y Balanceo': 'alignment',
      'Cambio de Batería': 'battery',
      'Cambio de Correa de Distribución': 'timing_belt',
      'Lavado y Detallado': 'car_wash',
    };

    for (var entry in serviceIcons.entries) {
      await db.insert('service_icons', {
        'serviceName': entry.key,
        'iconName': entry.value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> initializeDb() async {
    await database;
  }

  // Métodos de la base de datos
  static Future<void> addVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehicles');

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  static Future<void> addServiceRecord(ServiceRecord record) async {
    final db = await database;

    final Map<String, dynamic> data = {
      'vehicleId': record.vehicleId,
      'serviceName': record.serviceName,
      'mileage': record.mileage,
      'date': record.date.toIso8601String(),
      'notes': record.notes,
    };

    await db.insert(
      'service_records',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ServiceRecord>> getServiceRecords() async {
    final db = await database;

    // Consulta que une service_records con vehicles y service_icons
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        sr.id, 
        sr.vehicleId, 
        sr.serviceName, 
        sr.mileage, 
        sr.date, 
        sr.notes, 
        v.make as vehicleMake, 
        v.model as vehicleModel,
        si.iconName as iconName
      FROM service_records sr
      LEFT JOIN vehicles v ON sr.vehicleId = v.id
      LEFT JOIN service_icons si ON sr.serviceName = si.serviceName
      ORDER BY sr.date DESC
    ''');

    return List.generate(maps.length, (i) {
      return ServiceRecord.fromMap(maps[i]);
    });
  }

  // Método para obtener icono por nombre de servicio
  static Future<String> getIconNameForService(String serviceName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'service_icons',
      where: 'serviceName = ?',
      whereArgs: [serviceName],
    );

    if (maps.isNotEmpty) {
      return maps.first['iconName'] as String;
    }

    return 'default_icon'; // Icono por defecto si no se encuentra
  }

  // Método para obtener todos los servicios disponibles con sus iconos
  static Future<Map<String, String>> getAvailableServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('service_icons');

    final Map<String, String> services = {};
    for (var map in maps) {
      services[map['serviceName'] as String] = map['iconName'] as String;
    }

    return services;
  }
}
