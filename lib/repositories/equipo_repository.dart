import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/equipo.dart';

class EquipoRepository {
  final DatabaseHelper _dbHelper;

  EquipoRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Inserta un nuevo equipo y retorna el objeto con su ID autoincremental.
  Future<Equipo> create(Equipo equipo) async {
    final db = await _db;
    final id = await db.insert(
      'equipo',
      equipo.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return equipo.copyWith(id: id);
  }

  /// Obtiene un equipo por su ID.
  Future<Equipo?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'equipo',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Equipo.fromMap(maps.first);
  }

  /// Obtiene todos los equipos registrados.
  Future<List<Equipo>> getAll() async {
    final db = await _db;
    final maps = await db.query('equipo', orderBy: 'codigo ASC');
    return maps.map((map) => Equipo.fromMap(map)).toList();
  }

  /// Obtiene todos los equipos asignados a un aula específica.
  Future<List<Equipo>> getByAula(int aulaId) async {
    final db = await _db;
    final maps = await db.query(
      'equipo',
      where: 'aula_id = ?',
      whereArgs: [aulaId],
      orderBy: 'codigo ASC',
    );
    return maps.map((map) => Equipo.fromMap(map)).toList();
  }

  /// Actualiza un equipo existente.
  Future<int> update(Equipo equipo) async {
    if (equipo.id == null) {
      throw ArgumentError('El ID del equipo no puede ser nulo para actualizar.');
    }
    final db = await _db;
    return await db.update(
      'equipo',
      equipo.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [equipo.id],
    );
  }

  /// Elimina un equipo por ID (sus incidencias se eliminan en CASCADA).
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'equipo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cantidad total de equipos registrados.
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM equipo');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
