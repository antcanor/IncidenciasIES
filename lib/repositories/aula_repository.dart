import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/aula.dart';

class AulaRepository {
  final DatabaseHelper _dbHelper;

  AulaRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Inserta una nueva aula y retorna el objeto con su ID asignado.
  Future<Aula> create(Aula aula) async {
    final db = await _db;
    final id = await db.insert(
      'aula',
      aula.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return aula.copyWith(id: id);
  }

  /// Obtiene un aula por su ID.
  Future<Aula?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'aula',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Aula.fromMap(maps.first);
  }

  /// Obtiene todas las aulas ordenadas por planta y nombre.
  Future<List<Aula>> getAll() async {
    final db = await _db;
    final maps = await db.query('aula', orderBy: 'planta ASC, nombre ASC');
    return maps.map((map) => Aula.fromMap(map)).toList();
  }

  /// Actualiza un aula existente por su ID.
  Future<int> update(Aula aula) async {
    if (aula.id == null) {
      throw ArgumentError('El ID del aula no puede ser nulo para actualizar.');
    }
    final db = await _db;
    return await db.update(
      'aula',
      aula.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [aula.id],
    );
  }

  /// Elimina un aula por su ID (bloqueado si tiene equipos por ON DELETE RESTRICT).
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'aula',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cantidad total de aulas registradas.
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM aula');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
