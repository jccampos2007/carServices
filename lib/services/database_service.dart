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

  // Table names
  static const String _vehiclesTable = 'vehicles';
  static const String _servicesTable = 'services';
  static const String _serviceRecordsTable = 'service_records';
  static const String _serviceIconsTable = 'service_icons';
  static const String _serviceRulesTable = 'service_rules';

  // Current database version
  static const int _databaseVersion = 1;

  // Database instance getter
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'car_service_app.db');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Configure database
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
    await _populateInitialData(db);
  }

  // Upgrade database
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < _databaseVersion) {
      await _recreateDatabase(db);
    }
  }

  // Create all tables
  static Future<void> _createAllTables(Database db) async {
    await _createVehiclesTable(db);
    await _createServiceIconsTable(db);
    await _createServicesTable(db);
    await _createServiceRecordsTable(db);
    await _createServiceRulesTable(db);
  }

  // Drop and recreate all tables
  static Future<void> _recreateDatabase(Database db) async {
    await _dropAllTables(db);
    await _createAllTables(db);
    await _populateInitialData(db);
  }

  // Drop all tables
  static Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $_serviceRecordsTable');
    await db.execute('DROP TABLE IF EXISTS $_serviceRulesTable');
    await db.execute('DROP TABLE IF EXISTS $_servicesTable');
    await db.execute('DROP TABLE IF EXISTS $_serviceIconsTable');
    await db.execute('DROP TABLE IF EXISTS $_vehiclesTable');
  }

  // Table creation methods
  static Future<void> _createVehiclesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_vehiclesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        initialMileage INTEGER DEFAULT 0,
        currentMileage INTEGER DEFAULT 0,
        lastServiceDate TEXT,
        lastServiceMileage INTEGER DEFAULT 0,
        imageUrl TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> _createServiceIconsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_serviceIconsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_servicesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serviceName TEXT NOT NULL UNIQUE,
        iconId INTEGER,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (iconId) REFERENCES $_serviceIconsTable(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _createServiceRecordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_serviceRecordsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        serviceId INTEGER NOT NULL,
        mileage INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (vehicleId) REFERENCES $_vehiclesTable(id) ON DELETE CASCADE,
        FOREIGN KEY (serviceId) REFERENCES $_servicesTable(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createServiceRulesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_serviceRulesTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serviceName TEXT NOT NULL UNIQUE,
        frequencyKm INTEGER NOT NULL,
        iconId INTEGER,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (iconId) REFERENCES $_serviceIconsTable(id) ON DELETE SET NULL
      )
    ''');
  }

  // Populate initial data
  static Future<void> _populateInitialData(Database db) async {
    await _populateServiceIcons(db);
    await _populateServices(db);
    await _populateServiceRules(db);
    await _populateVehicles(db);
    await _populateServiceRecords(db);
  }

  static Future<void> _populateServiceIcons(Database db) async {
    final icons = [
      {'name': 'Cambio de Aceite', 'icon': 'oil_change'},
      {'name': 'Cambio de Filtro de Aire', 'icon': 'air_filter'},
      {'name': 'Cambio de Pastillas de Freno', 'icon': 'brakes'},
      {'name': 'Rotación de Llantas', 'icon': 'tire_rotation'},
      {'name': 'Alineación y Balanceo', 'icon': 'alignment'},
      {'name': 'Cambio de Batería', 'icon': 'battery'},
      {'name': 'Cambio de Correa de Distribución', 'icon': 'timing_belt'},
      {'name': 'Lavado y Detallado', 'icon': 'car_wash'},
      {'name': 'Revisión de Frenos', 'icon': 'brakes'},
      {'name': 'Cambio de Bujías', 'icon': 'engine'},
      {'name': 'Revisión de Suspensión', 'icon': 'suspension'},
    ];

    for (final icon in icons) {
      await db.insert(_serviceIconsTable, {
        'name': icon['name'],
        'icon': icon['icon'],
      });
    }
  }

  static Future<void> _populateServices(Database db) async {
    final services = [
      {'name': 'Cambio de Aceite', 'iconId': 1},
      {'name': 'Cambio de Filtro de Aire', 'iconId': 2},
      {'name': 'Cambio de Pastillas de Freno', 'iconId': 3},
      {'name': 'Rotación de Llantas', 'iconId': 4},
      {'name': 'Alineación y Balanceo', 'iconId': 5},
      {'name': 'Cambio de Batería', 'iconId': 6},
      {'name': 'Cambio de Correa de Distribución', 'iconId': 7},
      {'name': 'Lavado y Detallado', 'iconId': 8},
    ];

    for (final service in services) {
      await db.insert(_servicesTable, {
        'serviceName': service['name'],
        'iconId': service['iconId'],
      });
    }
  }

  static Future<void> _populateServiceRules(Database db) async {
    final rules = [
      {'serviceName': 'Cambio de Aceite', 'frequencyKm': 3000, 'iconId': 1},
      {'serviceName': 'Rotación de Llantas', 'frequencyKm': 8000, 'iconId': 4},
      {
        'serviceName': 'Cambio de Pastillas de Freno',
        'frequencyKm': 12000,
        'iconId': 3,
      },
      {
        'serviceName': 'Cambio de Correa de Distribución',
        'frequencyKm': 60000,
        'iconId': 7,
      },
      {
        'serviceName': 'Cambio de Filtro de Aire',
        'frequencyKm': 15000,
        'iconId': 2,
      },
      {
        'serviceName': 'Alineación y Balanceo',
        'frequencyKm': 10000,
        'iconId': 5,
      },
      {'serviceName': 'Cambio de Batería', 'frequencyKm': 50000, 'iconId': 6},
      {'serviceName': 'Lavado y Detallado', 'frequencyKm': 500, 'iconId': 8},
      {'serviceName': 'Revisión de Frenos', 'frequencyKm': 6000, 'iconId': 3},
      {'serviceName': 'Cambio de Bujías', 'frequencyKm': 30000, 'iconId': 9},
      {
        'serviceName': 'Revisión de Suspensión',
        'frequencyKm': 20000,
        'iconId': 10,
      },
    ];

    for (final rule in rules) {
      await db.insert(_serviceRulesTable, {
        'serviceName': rule['serviceName'],
        'frequencyKm': rule['frequencyKm'],
        'iconId': rule['iconId'],
      });
    }
  }

  static Future<void> _populateVehicles(Database db) async {
    final vehicles = [
      {
        'make': 'Chery',
        'model': 'Arauca',
        'initialMileage': 5000,
        'currentMileage': 38500, // Ajustado para generar % entre 50-79%
        'lastServiceDate': DateTime.now()
            .subtract(Duration(days: 120)) // Último servicio hace 120 días
            .toIso8601String(),
        'lastServiceMileage': 35000, // Último servicio a los 35,000 km
        'imageUrl': 'assets/images/chery_arauca.png',
      },
      {
        'make': 'Toyota',
        'model': 'Corolla',
        'initialMileage': 10000,
        'currentMileage': 68500, // Ajustado para generar % entre 50-79%
        'lastServiceDate': DateTime.now()
            .subtract(Duration(days: 90)) // Último servicio hace 90 días
            .toIso8601String(),
        'lastServiceMileage': 65000, // Último servicio a los 65,000 km
        'imageUrl': 'assets/images/toyota_corolla.png',
      },
    ];

    for (final vehicle in vehicles) {
      await db.insert(_vehiclesTable, vehicle);
    }
  }

  static Future<void> _populateServiceRecords(Database db) async {
    final records = [
      {
        'vehicleId': 1,
        'serviceId': 1,
        'mileage': 50000,
        'date': DateTime.now().subtract(Duration(days: 100)).toIso8601String(),
        'notes': 'Aceite sintético 10W-40',
      },
      {
        'vehicleId': 1,
        'serviceId': 2,
        'mileage': 51500,
        'date': DateTime.now().subtract(Duration(days: 60)).toIso8601String(),
        'notes': 'Filtro de aire reemplazado',
      },
      {
        'vehicleId': 2,
        'serviceId': 1,
        'mileage': 68000,
        'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        'notes': 'Cambio de aceite programado',
      },
      {
        'vehicleId': 1,
        'serviceId': 4,
        'mileage': 52000,
        'date': DateTime.now().subtract(Duration(days: 45)).toIso8601String(),
        'notes': 'Rotación de llantas completada',
      },
      {
        'vehicleId': 2,
        'serviceId': 3,
        'mileage': 67000,
        'date': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
        'notes': 'Pastillas de freno revisadas',
      },
    ];

    for (final record in records) {
      await db.insert(_serviceRecordsTable, record);
    }
  }

  // Public initialization method
  static Future<void> initializeDb() async {
    try {
      final db = await database;
      // Verify database integrity
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      print(
        '✅ Database initialized successfully with tables: ${tables.map((t) => t['name']).toList()}',
      );
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  // ============ VEHICLE OPERATIONS ============
  static Future<int> addVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert(_vehiclesTable, vehicle.toMap());
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final maps = await db.query(_vehiclesTable, orderBy: 'id DESC');
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  static Future<Vehicle> getVehicleById(int id) async {
    final db = await database;
    final maps = await db.query(
      _vehiclesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('Vehicle with id $id not found');
    return Vehicle.fromMap(maps.first);
  }

  static Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      _vehiclesTable,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  static Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(_vehiclesTable, where: 'id = ?', whereArgs: [id]);
  }

  // ============ SERVICE OPERATIONS ============
  static Future<int> addService(Service service) async {
    final db = await database;
    return await db.insert(_servicesTable, service.toMap());
  }

  static Future<List<Service>> getServices() async {
    final db = await database;
    final maps = await db.query(_servicesTable, orderBy: 'serviceName');
    return maps.map((map) => Service.fromMap(map)).toList();
  }

  static Future<Service> getServiceById(int id) async {
    final db = await database;
    final maps = await db.query(
      _servicesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('Service with id $id not found');
    return Service.fromMap(maps.first);
  }

  // ============ SERVICE ICON OPERATIONS ============
  static Future<int> addServiceIcon(ServiceIcon serviceIcon) async {
    final db = await database;
    return await db.insert(_serviceIconsTable, serviceIcon.toMap());
  }

  static Future<List<ServiceIcon>> getServiceIcons() async {
    final db = await database;
    final maps = await db.query(_serviceIconsTable, orderBy: 'name');
    return maps.map((map) => ServiceIcon.fromMap(map)).toList();
  }

  static Future<ServiceIcon> getServiceIconById(int id) async {
    final db = await database;
    final maps = await db.query(
      _serviceIconsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('ServiceIcon with id $id not found');
    return ServiceIcon.fromMap(maps.first);
  }

  // ============ SERVICE RECORD OPERATIONS ============
  static Future<int> addServiceRecord(ServiceRecord record) async {
    final db = await database;
    return await db.insert(_serviceRecordsTable, record.toMap());
  }

  static Future<List<ServiceRecord>> getServiceRecords() async {
    final db = await database;
    final maps = await db.query(_serviceRecordsTable, orderBy: 'date DESC');
    return maps.map((map) => ServiceRecord.fromMap(map)).toList();
  }

  static Future<List<ServiceRecord>> getServiceRecordsByVehicleId(
    int vehicleId,
  ) async {
    final db = await database;
    final maps = await db.query(
      _serviceRecordsTable,
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => ServiceRecord.fromMap(map)).toList();
  }

  static Future<int> updateServiceRecord(ServiceRecord record) async {
    final db = await database;
    return await db.update(
      _serviceRecordsTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteServiceRecord(int id) async {
    final db = await database;
    return await db.delete(
      _serviceRecordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ RECENT SERVICE RECORDS ============
  static Future<List<ServiceRecord>> getRecentServiceRecords({
    int limit = 5,
  }) async {
    final db = await database;
    final maps = await db.query(
      _serviceRecordsTable,
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => ServiceRecord.fromMap(map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getRecentServiceRecordsWithDetails({
    int limit = 5,
  }) async {
    final db = await database;
    return await db.rawQuery(
      '''
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
      FROM $_serviceRecordsTable sr
      LEFT JOIN $_vehiclesTable v ON sr.vehicleId = v.id
      LEFT JOIN $_servicesTable s ON sr.serviceId = s.id
      LEFT JOIN $_serviceIconsTable si ON s.iconId = si.id
      ORDER BY sr.date DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  // ============ SERVICE RULE OPERATIONS ============
  static Future<int> addServiceRule(ServiceRule rule) async {
    final db = await database;
    return await db.insert(_serviceRulesTable, rule.toMap());
  }

  static Future<List<ServiceRule>> getServiceRules() async {
    final db = await database;
    final maps = await db.query(_serviceRulesTable, orderBy: 'serviceName');
    return maps.map((map) => ServiceRule.fromMap(map)).toList();
  }

  // ============ ADVANCED QUERIES ============
  static Future<List<Map<String, dynamic>>>
  getServiceRecordsWithDetails() async {
    final db = await database;
    return await db.rawQuery('''
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
      FROM $_serviceRecordsTable sr
      LEFT JOIN $_vehiclesTable v ON sr.vehicleId = v.id
      LEFT JOIN $_servicesTable s ON sr.serviceId = s.id
      LEFT JOIN $_serviceIconsTable si ON s.iconId = si.id
      ORDER BY sr.date DESC
    ''');
  }

  static Future<List<Map<String, dynamic>>> getServicesWithIcons() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id,
        s.serviceName,
        s.iconId,
        si.name as iconName,
        si.icon as iconData
      FROM $_servicesTable s
      LEFT JOIN $_serviceIconsTable si ON s.iconId = si.id
      ORDER BY s.serviceName
    ''');
  }

  // ============ STATISTICS QUERIES ============
  static Future<int> getTotalServiceRecords() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $_serviceRecordsTable
    ''');
    return result.first['count'] as int;
  }

  static Future<Map<String, dynamic>> getVehicleStatistics(
    int vehicleId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as totalServices,
        MAX(mileage) as lastServiceMileage,
        MAX(date) as lastServiceDate
      FROM $_serviceRecordsTable
      WHERE vehicleId = ?
    ''',
      [vehicleId],
    );

    return result.first;
  }

  // Database maintenance
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'car_service_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
