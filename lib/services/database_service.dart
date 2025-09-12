// database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/models/service_rule.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/models/service_icon.dart';

class DatabaseService {
  static Database? _database;
  static const String _vehiclesTableName = 'vehicles';
  static const String _servicesTableName = 'services';
  static const String _serviceRecordsTableName = 'service_records';
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

    return openDatabase(
      path,
      version: 9, // Incrementamos la versión por los cambios
      onCreate: (db, version) async {
        // Tabla de vehículos
        await db.execute(
          'CREATE TABLE $_vehiclesTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, make TEXT, model TEXT, initialMileage INTEGER, currentMileage INTEGER, lastServiceDate TEXT, lastServiceMileage INTEGER)',
        );

        // Tabla de iconos de servicio
        await db.execute(
          'CREATE TABLE $_serviceIconsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, icon TEXT)',
        );

        // Tabla de servicios
        await db.execute(
          'CREATE TABLE $_servicesTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, serviceName TEXT, iconId INTEGER, FOREIGN KEY (iconId) REFERENCES $_serviceIconsTableName(id))',
        );

        // Tabla de registros de servicio
        await db.execute(
          'CREATE TABLE $_serviceRecordsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, serviceId INTEGER, mileage INTEGER, date TEXT, notes TEXT, FOREIGN KEY (vehicleId) REFERENCES $_vehiclesTableName(id), FOREIGN KEY (serviceId) REFERENCES $_servicesTableName(id))',
        );

        // Poblar datos de prueba
        await _populateMockData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 9) {
          // Eliminar TODAS las tablas antiguas si existen
          await db.execute('DROP TABLE IF EXISTS $_vehiclesTableName');
          await db.execute('DROP TABLE IF EXISTS $_servicesTableName');
          await db.execute('DROP TABLE IF EXISTS $_serviceIconsTableName');
          await db.execute('DROP TABLE IF EXISTS $_serviceRecordsTableName');

          // Crear la tabla de vehículos nuevamente
          await db.execute(
            'CREATE TABLE $_vehiclesTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, make TEXT, model TEXT, initialMileage INTEGER, currentMileage INTEGER, lastServiceDate TEXT, lastServiceMileage INTEGER)',
          );

          // Crear la tabla de iconos nuevamente
          await db.execute(
            'CREATE TABLE $_serviceIconsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, icon TEXT)',
          );

          // Crear la tabla de servicios
          await db.execute(
            'CREATE TABLE $_servicesTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, serviceName TEXT, iconId INTEGER, FOREIGN KEY (iconId) REFERENCES $_serviceIconsTableName(id))',
          );

          // Crear la nueva tabla de registros de servicio
          await db.execute(
            'CREATE TABLE $_serviceRecordsTableName(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, serviceId INTEGER, mileage INTEGER, date TEXT, notes TEXT, FOREIGN KEY (vehicleId) REFERENCES $_vehiclesTableName(id), FOREIGN KEY (serviceId) REFERENCES $_servicesTableName(id))',
          );

          // Poblar datos de prueba
          await _populateMockData(db);
        }
      },
    );
  }

  static Future<void> _populateMockData(Database db) async {
    // Verificar si ya existen datos antes de insertar
    final existingVehicles = await db.query(_vehiclesTableName);
    if (existingVehicles.isNotEmpty) {
      return; // Ya hay datos, no insertar duplicados
    }

    // Insertar iconos de servicio
    final iconData = [
      {'name': 'Cambio de Aceite', 'icon': 'oil_change'},
      {'name': 'Cambio de Filtro de Aire', 'icon': 'air_filter'},
      {'name': 'Cambio de Pastillas de Freno', 'icon': 'brakes'},
      {'name': 'Rotación de Llantas', 'icon': 'tire_rotation'},
      {'name': 'Alineación y Balanceo', 'icon': 'alignment'},
      {'name': 'Cambio de Batería', 'icon': 'battery'},
      {'name': 'Cambio de Correa de Distribución', 'icon': 'timing_belt'},
    ];

    final iconIds = <int>[];
    for (var icon in iconData) {
      final iconId = await db.insert(_serviceIconsTableName, {
        'name': icon['name'],
        'icon': icon['icon'],
      });
      iconIds.add(iconId);
    }

    // Insertar servicios
    final serviceData = [
      {'name': 'Cambio de Aceite', 'iconId': iconIds[0]},
      {'name': 'Cambio de Filtro de Aire', 'iconId': iconIds[1]},
      {'name': 'Cambio de Pastillas de Freno', 'iconId': iconIds[2]},
      {'name': 'Rotación de Llantas', 'iconId': iconIds[3]},
      {'name': 'Alineación y Balanceo', 'iconId': iconIds[4]},
      {'name': 'Cambio de Batería', 'iconId': iconIds[5]},
      {'name': 'Cambio de Correa de Distribución', 'iconId': iconIds[6]},
    ];

    final serviceIds = <int>[];
    for (var service in serviceData) {
      final serviceId = await db.insert(_servicesTableName, {
        'serviceName': service['name'],
        'iconId': service['iconId'],
      });
      serviceIds.add(serviceId);
    }

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

    // Insertar registros de servicio
    await db.insert(_serviceRecordsTableName, {
      'vehicleId': vehicleId,
      'serviceId': serviceIds[0], // Cambio de Aceite
      'mileage': 51000,
      'date': DateTime.now().subtract(Duration(days: 90)).toIso8601String(),
      'notes': 'Aceite sintético 10W-40',
    });

    await db.insert(_serviceRecordsTableName, {
      'vehicleId': vehicleId,
      'serviceId': serviceIds[1], // Cambio de Filtro de Aire
      'mileage': 51500,
      'date': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
      'notes': 'Filtro de aire reemplazado',
    });
  }

  static Future<void> initializeDb() async {
    await database;
  }

  // Métodos para Vehículos
  static Future<int> addVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert(
      _vehiclesTableName,
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_vehiclesTableName);

    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  static Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      _vehiclesTableName,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  static Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      _vehiclesTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Servicios
  static Future<int> addService(Service service) async {
    final db = await database;
    return await db.insert(
      _servicesTableName,
      service.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Service>> getServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_servicesTableName);

    return List.generate(maps.length, (i) {
      return Service.fromMap(maps[i]);
    });
  }

  // Métodos para ServiceIcons
  static Future<int> addServiceIcon(ServiceIcon serviceIcon) async {
    final db = await database;
    return await db.insert(
      _serviceIconsTableName,
      serviceIcon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ServiceIcon>> getServiceIcons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _serviceIconsTableName,
    );

    return List.generate(maps.length, (i) {
      return ServiceIcon.fromMap(maps[i]);
    });
  }

  // Métodos para ServiceRecords
  static Future<int> addServiceRecord(ServiceRecord record) async {
    final db = await database;
    return await db.insert(
      _serviceRecordsTableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ServiceRecord>> getServiceRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _serviceRecordsTableName,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return ServiceRecord.fromMap(maps[i]);
    });
  }

  static Future<List<ServiceRecord>> getServiceRecordsByVehicleId(
    int vehicleId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _serviceRecordsTableName,
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return ServiceRecord.fromMap(maps[i]);
    });
  }

  static Future<int> updateServiceRecord(ServiceRecord record) async {
    final db = await database;
    return await db.update(
      _serviceRecordsTableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteServiceRecord(int id) async {
    final db = await database;
    return await db.delete(
      _serviceRecordsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos utilitarios
  static Future<Service> getServiceById(int serviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _servicesTableName,
      where: 'id = ?',
      whereArgs: [serviceId],
    );

    if (maps.isNotEmpty) {
      return Service.fromMap(maps.first);
    }
    throw Exception('Service not found');
  }

  static Future<ServiceIcon> getServiceIconById(int iconId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _serviceIconsTableName,
      where: 'id = ?',
      whereArgs: [iconId],
    );

    if (maps.isNotEmpty) {
      return ServiceIcon.fromMap(maps.first);
    }
    throw Exception('ServiceIcon not found');
  }

  static Future<Vehicle> getVehicleById(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _vehiclesTableName,
      where: 'id = ?',
      whereArgs: [vehicleId],
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    throw Exception('Vehicle not found');
  }

  // Método para obtener registros de servicio con información relacionada
  static Future<List<Map<String, dynamic>>>
  getServiceRecordsWithDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        sr.id, 
        sr.vehicleId, 
        sr.serviceId, 
        sr.mileage, 
        sr.date, 
        sr.notes, 
        v.make as vehicleMake, 
        v.model as vehicleModel,
        s.serviceName as serviceName,
        si.icon as serviceIcon,
        si.name as serviceIconName
      FROM $_serviceRecordsTableName sr
      LEFT JOIN $_vehiclesTableName v ON sr.vehicleId = v.id
      LEFT JOIN $_servicesTableName s ON sr.serviceId = s.id
      LEFT JOIN $_serviceIconsTableName si ON s.iconId = si.id
      ORDER BY sr.date DESC
    ''');

    return maps;
  }

  // Método para obtener todos los servicios con información de iconos
  static Future<List<Map<String, dynamic>>> getServicesWithIcons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        s.id,
        s.serviceName,
        s.iconId,
        si.name as iconName,
        si.icon as iconData
      FROM $_servicesTableName s
      LEFT JOIN $_serviceIconsTableName si ON s.iconId = si.id
      ORDER BY s.serviceName
    ''');

    return maps;
  }

  static Future<int> addServiceRule(ServiceRule rule) async {
    final db = await database;
    return await db.insert(
      'service_rules', // Necesitarías crear esta tabla
      rule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ServiceRule>> getServiceRules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('service_rules');

    return List.generate(maps.length, (i) {
      return ServiceRule.fromMap(maps[i]);
    });
  }
}
