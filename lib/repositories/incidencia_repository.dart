import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/estado.dart';
import '../models/incidencia.dart';
import '../models/prioridad.dart';

class IncidenciaRepository {
  final DatabaseHelper _dbHelper;

  IncidenciaRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Inserta una nueva incidencia y retorna el objeto con su ID asignado.
  Future<Incidencia> create(Incidencia incidencia) async {
    final db = await _db;
    final id = await db.insert(
      'incidencia',
      incidencia.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return incidencia.copyWith(id: id);
  }

  /// Obtiene una incidencia por su ID.
  Future<Incidencia?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'incidencia',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Incidencia.fromMap(maps.first);
  }

  /// Obtiene todas las incidencias ordenadas por fecha descendente.
  Future<List<Incidencia>> getAll() async {
    final db = await _db;
    final maps = await db.query('incidencia', orderBy: 'fecha DESC');
    return maps.map((map) => Incidencia.fromMap(map)).toList();
  }

  /// Obtiene las incidencias asociadas a un equipo determinado.
  Future<List<Incidencia>> getByEquipo(int equipoId) async {
    final db = await _db;
    final maps = await db.query(
      'incidencia',
      where: 'equipo_id = ?',
      whereArgs: [equipoId],
      orderBy: 'fecha DESC',
    );
    return maps.map((map) => Incidencia.fromMap(map)).toList();
  }

  /// Filtra incidencias por su estado.
  Future<List<Incidencia>> getByEstado(Estado estado) async {
    final db = await _db;
    final maps = await db.query(
      'incidencia',
      where: 'estado = ?',
      whereArgs: [estado.value],
      orderBy: 'fecha DESC',
    );
    return maps.map((map) => Incidencia.fromMap(map)).toList();
  }

  /// Filtra incidencias por su nivel de prioridad.
  Future<List<Incidencia>> getByPrioridad(Prioridad prioridad) async {
    final db = await _db;
    final maps = await db.query(
      'incidencia',
      where: 'prioridad = ?',
      whereArgs: [prioridad.value],
      orderBy: 'fecha DESC',
    );
    return maps.map((map) => Incidencia.fromMap(map)).toList();
  }

  /// Actualiza una incidencia existente.
  Future<int> update(Incidencia incidencia) async {
    if (incidencia.id == null) {
      throw ArgumentError('El ID de la incidencia no puede ser nulo para actualizar.');
    }
    final db = await _db;
    return await db.update(
      'incidencia',
      incidencia.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [incidencia.id],
    );
  }

  /// Elimina una incidencia por su ID (sus comentarios se eliminan en CASCADA).
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'incidencia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cantidad total de incidencias registradas.
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM incidencia');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
