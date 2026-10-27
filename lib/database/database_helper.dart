import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static const String _databaseName = 'incidencias.db';
  static const int _databaseVersion = 1;

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Inicializa el factory adecuado según la plataforma.
  /// - En Web: sqflite_common_ffi_web
  /// - En Escritorio (Linux, Windows, macOS): sqflite_common_ffi
  /// - En Móvil (Android, iOS): sqflite nativo
  static void initializeDatabaseFactory() {
    if (kIsWeb) {
      debugPrint('[DatabaseHelper] Inicializando sqflite_common_ffi_web para Web.');
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('[DatabaseHelper] Inicializando sqflite_common_ffi para escritorio.');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      debugPrint('[DatabaseHelper] Utilizando sqflite nativo para móvil (Android/iOS).');
    }
  }

  /// Retorna la instancia de la base de datos abierta.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(_databaseName);
    return _database!;
  }

  Future<Database> _initDatabase(String fileName) async {
    initializeDatabaseFactory();

    String path;
    if (kIsWeb) {
      path = fileName;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, fileName);
    }

    debugPrint('[DatabaseHelper] Abriendo base de datos en: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  /// Activa las claves foráneas en cada conexión abierta.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    debugPrint('[DatabaseHelper] PRAGMA foreign_keys = ON activado.');
  }

  /// Crea las 4 tablas del esquema relacional y sus índices.
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('[DatabaseHelper] Ejecutando onCreate: creando tablas relacionales...');

    // 1. Tabla: aula
    await db.execute('''
      CREATE TABLE aula (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        planta INTEGER NOT NULL
      )
    ''');

    // 2. Tabla: equipo
    await db.execute('''
      CREATE TABLE equipo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        aula_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        codigo TEXT NOT NULL UNIQUE,
        FOREIGN KEY (aula_id) REFERENCES aula(id)
          ON UPDATE CASCADE
          ON DELETE RESTRICT
      )
    ''');

    // 3. Tabla: incidencia
    await db.execute('''
      CREATE TABLE incidencia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER NOT NULL,
        descripcion TEXT NOT NULL,
        prioridad TEXT NOT NULL CHECK(prioridad IN ('BAJA', 'MEDIA', 'ALTA', 'URGENTE')),
        estado TEXT NOT NULL CHECK(estado IN ('ABIERTA', 'EN_PROCESO', 'RESUELTA', 'CERRADA')),
        fecha TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (equipo_id) REFERENCES equipo(id)
          ON UPDATE CASCADE
          ON DELETE CASCADE
      )
    ''');

    // 4. Tabla: comentario
    await db.execute('''
      CREATE TABLE comentario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        incidencia_id INTEGER NOT NULL,
        fecha TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
        texto TEXT NOT NULL,
        FOREIGN KEY (incidencia_id) REFERENCES incidencia(id)
          ON UPDATE CASCADE
          ON DELETE CASCADE
      )
    ''');

    // Índices de optimización
    await db.execute('CREATE INDEX idx_equipo_aula_id ON equipo(aula_id)');
    await db.execute('CREATE INDEX idx_incidencia_equipo_id ON incidencia(equipo_id)');
    await db.execute('CREATE INDEX idx_incidencia_estado ON incidencia(estado)');
    await db.execute('CREATE INDEX idx_comentario_incidencia_id ON comentario(incidencia_id)');

    debugPrint('[DatabaseHelper] Tablas e índices creados satisfactoriamente.');
  }

  /// Comprueba el estado de la base de datos y retorna información técnica útil.
  Future<Map<String, dynamic>> checkDatabaseStatus() async {
    final db = await database;
    
    // Verificar si las foreign keys están activadas
    final fkCheck = await db.rawQuery('PRAGMA foreign_keys');
    final bool foreignKeysEnabled = fkCheck.isNotEmpty && fkCheck.first['foreign_keys'] == 1;

    // Obtener nombres de las tablas creadas
    final tablesResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    );
    final List<String> tableNames = tablesResult.map((e) => e['name'] as String).toList();

    return {
      'path': db.path,
      'foreignKeysEnabled': foreignKeysEnabled,
      'tables': tableNames,
    };
  }

  /// Cierra la base de datos (útil en pruebas).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
