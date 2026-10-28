import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'database_helper.dart';

class DatabaseSeeder {
  final DatabaseHelper _dbHelper;
  late final AulaRepository _aulaRepo;

  DatabaseSeeder([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance {
    _aulaRepo = AulaRepository(_dbHelper);
  }

  /// Carga datos iniciales de ejemplo si la base de datos se encuentra vacía.
  /// Genera más de 10 filas distribuidas en las 4 tablas relacionales.
  Future<bool> seedIfEmpty() async {
    final aulaCount = await _aulaRepo.count();
    if (aulaCount > 0) {
      debugPrint('[DatabaseSeeder] La BD ya contiene datos ($aulaCount aulas). Omitiendo seed.');
      return false;
    }

    debugPrint('[DatabaseSeeder] Base de datos vacía detectada. Insertando datos de ejemplo...');
    await seed();
    return true;
  }

  /// Ejecuta la inserción de datos de ejemplo en las 4 tablas dentro de una transacción.
  Future<void> seed() async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 1. AULAS (3 filas)
      final aula1Id = await txn.insert('aula', const Aula(
        nombre: 'Aula 101 - Informática',
        planta: 1,
      ).toMap(includeId: false));

      final aula2Id = await txn.insert('aula', const Aula(
        nombre: 'Aula 204 - Audiovisuales',
        planta: 2,
      ).toMap(includeId: false));

      final aula3Id = await txn.insert('aula', const Aula(
        nombre: 'Taller de Hardware y Redes',
        planta: 0,
      ).toMap(includeId: false));

      // 2. EQUIPOS (5 filas)
      final eq1Id = await txn.insert('equipo', Equipo(
        aulaId: aula1Id,
        tipo: 'PC Sobremesa',
        codigo: 'PC-101-01',
      ).toMap(includeId: false));

      final eq2Id = await txn.insert('equipo', Equipo(
        aulaId: aula1Id,
        tipo: 'PC Sobremesa',
        codigo: 'PC-101-02',
      ).toMap(includeId: false));

      final eq3Id = await txn.insert('equipo', Equipo(
        aulaId: aula2Id,
        tipo: 'Proyector Láser',
        codigo: 'PROY-204-01',
      ).toMap(includeId: false));

      final eq4Id = await txn.insert('equipo', Equipo(
        aulaId: aula3Id,
        tipo: 'Impresora 3D',
        codigo: 'IMP-3D-TALLER',
      ).toMap(includeId: false));

      await txn.insert('equipo', Equipo(
        aulaId: aula3Id,
        tipo: 'Switch Gestionable 24p',
        codigo: 'SW-RACK-01',
      ).toMap(includeId: false));

      // 3. INCIDENCIAS (4 filas)
      final now = DateTime.now();

      final inc1Id = await txn.insert('incidencia', Incidencia(
        equipoId: eq1Id,
        descripcion: 'El equipo no enciende tras tormenta eléctrica',
        prioridad: Prioridad.urgente,
        estado: Estado.enProceso,
        fecha: now.subtract(const Duration(days: 2)),
      ).toMap(includeId: false));

      await txn.insert('incidencia', Incidencia(
        equipoId: eq2Id,
        descripcion: 'Teclado con teclas bloqueadas por líquido',
        prioridad: Prioridad.baja,
        estado: Estado.abierta,
        fecha: now.subtract(const Duration(days: 1)),
      ).toMap(includeId: false));

      final inc3Id = await txn.insert('incidencia', Incidencia(
        equipoId: eq3Id,
        descripcion: 'Lámpara del proyector parpadea en color amarillo',
        prioridad: Prioridad.media,
        estado: Estado.abierta,
        fecha: now.subtract(const Duration(hours: 5)),
      ).toMap(includeId: false));

      final inc4Id = await txn.insert('incidencia', Incidencia(
        equipoId: eq4Id,
        descripcion: 'Extrusor obstruido con filamento PLA',
        prioridad: Prioridad.alta,
        estado: Estado.resuelta,
        fecha: now.subtract(const Duration(days: 4)),
      ).toMap(includeId: false));

      // 4. COMENTARIOS (4 filas)
      await txn.insert('comentario', Comentario(
        incidenciaId: inc1Id,
        fecha: now.subtract(const Duration(days: 2, hours: -1)),
        texto: 'Revisada la fuente de alimentación; no llega corriente a la placa base.',
      ).toMap(includeId: false));

      await txn.insert('comentario', Comentario(
        incidenciaId: inc1Id,
        fecha: now.subtract(const Duration(days: 1)),
        texto: 'Solicitada fuente de repuesto ATX 500W a secretaría.',
      ).toMap(includeId: false));

      await txn.insert('comentario', Comentario(
        incidenciaId: inc3Id,
        fecha: now.subtract(const Duration(hours: 3)),
        texto: 'Comprobado cable HDMI y filtro de aire limpio. Se requiere cambio de lámpara.',
      ).toMap(includeId: false));

      await txn.insert('comentario', Comentario(
        incidenciaId: inc4Id,
        fecha: now.subtract(const Duration(days: 3)),
        texto: 'Desmontado extrusor y desobstruido a 230°C. Calibración superada con éxito.',
      ).toMap(includeId: false));
    });

    debugPrint('[DatabaseSeeder] Seeder completado: 16 registros insertados.');
  }
}
