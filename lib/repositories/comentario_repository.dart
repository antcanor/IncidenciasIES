import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/comentario.dart';

class ComentarioRepository {
  final DatabaseHelper _dbHelper;

  ComentarioRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  /// Inserta un nuevo comentario de seguimiento.
  Future<Comentario> create(Comentario comentario) async {
    final db = await _db;
    final id = await db.insert(
      'comentario',
      comentario.toMap(includeId: false),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return comentario.copyWith(id: id);
  }

  /// Obtiene un comentario por su ID.
  Future<Comentario?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'comentario',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Comentario.fromMap(maps.first);
  }

  /// Obtiene todos los comentarios registrados.
  Future<List<Comentario>> getAll() async {
    final db = await _db;
    final maps = await db.query('comentario', orderBy: 'fecha ASC');
    return maps.map((map) => Comentario.fromMap(map)).toList();
  }

  /// Obtiene el historial cronológico de comentarios de una incidencia.
  Future<List<Comentario>> getByIncidencia(int incidenciaId) async {
    final db = await _db;
    final maps = await db.query(
      'comentario',
      where: 'incidencia_id = ?',
      whereArgs: [incidenciaId],
      orderBy: 'fecha ASC',
    );
    return maps.map((map) => Comentario.fromMap(map)).toList();
  }

  /// Actualiza el texto de un comentario existente.
  Future<int> update(Comentario comentario) async {
    if (comentario.id == null) {
      throw ArgumentError('El ID del comentario no puede ser nulo para actualizar.');
    }
    final db = await _db;
    return await db.update(
      'comentario',
      comentario.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [comentario.id],
    );
  }

  /// Elimina un comentario por su ID.
  Future<int> delete(int id) async {
    final db = await _db;
    return await db.delete(
      'comentario',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cantidad total de comentarios registrados.
  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM comentario');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
