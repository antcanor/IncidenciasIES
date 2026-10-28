import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AulaRepository aulaRepo;
  late IncidenciaRepository incidenciaRepo;
  late DatabaseSeeder seeder;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_queries_test.db');

    // Asegurar base de datos limpia para pruebas
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'incidencias_queries_test.db');
    await databaseFactory.deleteDatabase(path);

    aulaRepo = AulaRepository();
    incidenciaRepo = IncidenciaRepository();
    seeder = DatabaseSeeder();

    // Cargar datos de ejemplo iniciales (16 filas)
    await seeder.seedIfEmpty();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  group('1. Consulta con JOIN doble (incidencia -> equipo -> aula)', () {
    test('getIncidenciasPorAula devuelve las incidencias del Aula 101 con datos del equipo y aula', () async {
      final aulas = await aulaRepo.getAll();
      final aula101 = aulas.firstWhere((a) => a.nombre.contains('101'));

      final incidenciasAula101 = await incidenciaRepo.getIncidenciasPorAula(aula101.id!);

      // Con los datos de ejemplo debe haber 2 incidencias en Aula 101
      expect(incidenciasAula101.length, equals(2));

      for (final det in incidenciasAula101) {
        expect(det.aulaId, equals(aula101.id));
        expect(det.aulaNombre, equals(aula101.nombre));
        expect(det.aulaPlanta, equals(aula101.planta));
        expect(det.equipoCodigo, startsWith('PC-101-'));
        expect(det.equipoTipo, equals('PC Sobremesa'));
      }

      // Una de ellas es urgente (PC no enciende) y la otra baja (teclado bloqueado)
      expect(incidenciasAula101.any((i) => i.prioridad == Prioridad.urgente), isTrue);
      expect(incidenciasAula101.any((i) => i.prioridad == Prioridad.baja), isTrue);
    });

    test('getIncidenciasPorAula devuelve las incidencias de Aula 204 y Taller', () async {
      final aulas = await aulaRepo.getAll();
      final aula204 = aulas.firstWhere((a) => a.nombre.contains('204'));
      final taller = aulas.firstWhere((a) => a.nombre.contains('Taller'));

      final inc204 = await incidenciaRepo.getIncidenciasPorAula(aula204.id!);
      expect(inc204.length, equals(1));
      expect(inc204.first.equipoCodigo, equals('PROY-204-01'));
      expect(inc204.first.equipoTipo, equals('Proyector Láser'));
      expect(inc204.first.prioridad, equals(Prioridad.media));
      expect(inc204.first.estado, equals(Estado.abierta));

      final incTaller = await incidenciaRepo.getIncidenciasPorAula(taller.id!);
      expect(incTaller.length, equals(1));
      expect(incTaller.first.equipoCodigo, equals('IMP-3D-TALLER'));
      expect(incTaller.first.equipoTipo, equals('Impresora 3D'));
      expect(incTaller.first.prioridad, equals(Prioridad.alta));
      expect(incTaller.first.estado, equals(Estado.resuelta));
    });

    test('getIncidenciasConDetalle devuelve todas las incidencias (4) con su JOIN resuelto', () async {
      final todas = await incidenciaRepo.getIncidenciasConDetalle();
      expect(todas.length, equals(4));

      for (final det in todas) {
        expect(det.id, isPositive);
        expect(det.descripcion.isNotEmpty, isTrue);
        expect(det.equipoCodigo.isNotEmpty, isTrue);
        expect(det.aulaNombre.isNotEmpty, isTrue);
        expect(det.fecha, isNotNull);
      }
    });
  });

  group('2. Consultas de COUNT por estado y por prioridad para el Panel', () {
    test('countByEstado devuelve el recuento exacto de los datos de ejemplo', () async {
      final conteosEstado = await incidenciaRepo.countByEstado();

      // En el seeder: 2 ABIERTA, 1 EN_PROCESO, 1 RESUELTA, 0 CERRADA
      expect(conteosEstado[Estado.abierta], equals(2));
      expect(conteosEstado[Estado.enProceso], equals(1));
      expect(conteosEstado[Estado.resuelta], equals(1));
      expect(conteosEstado[Estado.cerrada], equals(0));

      final totalPorEstados = conteosEstado.values.reduce((a, b) => a + b);
      expect(totalPorEstados, equals(4));
    });

    test('countByPrioridad devuelve el recuento exacto de los datos de ejemplo', () async {
      final conteosPrioridad = await incidenciaRepo.countByPrioridad();

      // En el seeder: 1 URGENTE, 1 ALTA, 1 MEDIA, 1 BAJA
      expect(conteosPrioridad[Prioridad.urgente], equals(1));
      expect(conteosPrioridad[Prioridad.alta], equals(1));
      expect(conteosPrioridad[Prioridad.media], equals(1));
      expect(conteosPrioridad[Prioridad.baja], equals(1));

      final totalPorPrioridades = conteosPrioridad.values.reduce((a, b) => a + b);
      expect(totalPorPrioridades, equals(4));
    });

    test('countPorAula agrupa correctamente el número de incidencias por aula física', () async {
      final porAula = await incidenciaRepo.countPorAula();
      expect(porAula.length, equals(3));

      // Aula 101: 2 incidencias
      final fila101 = porAula.firstWhere((r) => (r['aula_nombre'] as String).contains('101'));
      expect(fila101['total_incidencias'], equals(2));

      // Aula 204: 1 incidencia
      final fila204 = porAula.firstWhere((r) => (r['aula_nombre'] as String).contains('204'));
      expect(fila204['total_incidencias'], equals(1));

      // Taller: 1 incidencia
      final filaTaller = porAula.firstWhere((r) => (r['aula_nombre'] as String).contains('Taller'));
      expect(filaTaller['total_incidencias'], equals(1));
    });
  });
}
