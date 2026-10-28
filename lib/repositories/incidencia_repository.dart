import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/estado.dart';
import '../models/incidencia.dart';
import '../models/incidencia_detalle.dart';
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

  // ==============================================================
  // CONSULTAS AVANZADAS: JOIN DOBLE Y AGREGACIONES PARA EL PANEL
  // ==============================================================

  /// Consulta con JOIN doble (incidencia -> equipo -> aula) filtrando por aula.
  Future<List<IncidenciaDetalle>> getIncidenciasPorAula(int aulaId) async {
    final db = await _db;
    const sql = '''
      SELECT 
        i.id AS id,
        i.equipo_id AS equipo_id,
        i.descripcion AS descripcion,
        i.prioridad AS prioridad,
        i.estado AS estado,
        i.fecha AS fecha,
        e.tipo AS equipo_tipo,
        e.codigo AS equipo_codigo,
        a.id AS aula_id,
        a.nombre AS aula_nombre,
        a.planta AS aula_planta
      FROM incidencia i
      INNER JOIN equipo e ON i.equipo_id = e.id
      INNER JOIN aula a ON e.aula_id = a.id
      WHERE a.id = ?
      ORDER BY i.fecha DESC
    ''';
    final maps = await db.rawQuery(sql, [aulaId]);
    return maps.map((map) => IncidenciaDetalle.fromMap(map)).toList();
  }

  /// Consulta con JOIN doble (incidencia -> equipo -> aula) para todas las incidencias.
  Future<List<IncidenciaDetalle>> getIncidenciasConDetalle() async {
    final db = await _db;
    const sql = '''
      SELECT 
        i.id AS id,
        i.equipo_id AS equipo_id,
        i.descripcion AS descripcion,
        i.prioridad AS prioridad,
        i.estado AS estado,
        i.fecha AS fecha,
        e.tipo AS equipo_tipo,
        e.codigo AS equipo_codigo,
        a.id AS aula_id,
        a.nombre AS aula_nombre,
        a.planta AS aula_planta
      FROM incidencia i
      INNER JOIN equipo e ON i.equipo_id = e.id
      INNER JOIN aula a ON e.aula_id = a.id
      ORDER BY i.fecha DESC
    ''';
    final maps = await db.rawQuery(sql);
    return maps.map((map) => IncidenciaDetalle.fromMap(map)).toList();
  }

  /// Conteo de incidencias agrupadas por Estado (COUNT por estado para el Panel).
  /// Inicializa todos los estados posibles con 0 por defecto si no existen filas.
  Future<Map<Estado, int>> countByEstado() async {
    final db = await _db;
    final Map<Estado, int> counts = {
      for (final estado in Estado.values) estado: 0,
    };

    const sql = '''
      SELECT estado, COUNT(*) AS total
      FROM incidencia
      GROUP BY estado
    ''';
    final results = await db.rawQuery(sql);

    for (final row in results) {
      final estadoStr = row['estado'] as String?;
      final total = (row['total'] as int?) ?? 0;
      if (estadoStr != null) {
        final estado = Estado.fromString(estadoStr);
        counts[estado] = total;
      }
    }

    return counts;
  }

  /// Conteo de incidencias agrupadas por Prioridad (COUNT por prioridad para el Panel).
  /// Inicializa todas las prioridades con 0 por defecto si no existen filas.
  Future<Map<Prioridad, int>> countByPrioridad() async {
    final db = await _db;
    final Map<Prioridad, int> counts = {
      for (final prioridad in Prioridad.values) prioridad: 0,
    };

    const sql = '''
      SELECT prioridad, COUNT(*) AS total
      FROM incidencia
      GROUP BY prioridad
    ''';
    final results = await db.rawQuery(sql);

    for (final row in results) {
      final prioridadStr = row['prioridad'] as String?;
      final total = (row['total'] as int?) ?? 0;
      if (prioridadStr != null) {
        final prioridad = Prioridad.fromString(prioridadStr);
        counts[prioridad] = total;
      }
    }

    return counts;
  }

  /// Conteo de incidencias agrupadas por Aula (útil para métricas del centro).
  Future<List<Map<String, dynamic>>> countPorAula() async {
    final db = await _db;
    const sql = '''
      SELECT 
        a.id AS aula_id,
        a.nombre AS aula_nombre,
        a.planta AS aula_planta,
        COUNT(i.id) AS total_incidencias
      FROM aula a
      LEFT JOIN equipo e ON a.id = e.aula_id
      LEFT JOIN incidencia i ON e.id = i.equipo_id
      GROUP BY a.id, a.nombre, a.planta
      ORDER BY a.planta ASC, a.nombre ASC
    ''';
    return await db.rawQuery(sql);
  }
}
