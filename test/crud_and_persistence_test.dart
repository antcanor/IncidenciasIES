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
  late EquipoRepository equipoRepo;
  late IncidenciaRepository incidenciaRepo;
  late ComentarioRepository comentarioRepo;
  late DatabaseSeeder seeder;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_crud_test.db');

    // Limpiar BD anterior para garantizar entorno limpio
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'incidencias_crud_test.db');
    await databaseFactory.deleteDatabase(path);

    aulaRepo = AulaRepository();
    equipoRepo = EquipoRepository();
    incidenciaRepo = IncidenciaRepository();
    comentarioRepo = ComentarioRepository();
    seeder = DatabaseSeeder();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  group('1. Operaciones CRUD en las 4 tablas', () {
    test('CRUD en tabla Aula (Crear, Leer, Actualizar, Borrar)', () async {
      // 1. CREATE
      final creada = await aulaRepo.create(const Aula(
        nombre: 'Aula 301 - Test',
        planta: 3,
      ));
      expect(creada.id, isNotNull);
      final int aulaId = creada.id!;

      // 2. READ
      final recuperada = await aulaRepo.getById(aulaId);
      expect(recuperada, isNotNull);
      expect(recuperada!.nombre, equals('Aula 301 - Test'));
      expect(recuperada.planta, equals(3));

      // 3. UPDATE
      final aulaModificada = recuperada.copyWith(nombre: 'Aula 301 - Modificada', planta: 4);
      final filasActualizadas = await aulaRepo.update(aulaModificada);
      expect(filasActualizadas, equals(1));

      final verificada = await aulaRepo.getById(aulaId);
      expect(verificada!.nombre, equals('Aula 301 - Modificada'));
      expect(verificada.planta, equals(4));

      // 4. DELETE
      final filasBorradas = await aulaRepo.delete(aulaId);
      expect(filasBorradas, equals(1));

      final eliminada = await aulaRepo.getById(aulaId);
      expect(eliminada, isNull);
    });

    test('CRUD en tabla Equipo', () async {
      final aula = await aulaRepo.create(const Aula(nombre: 'Aula Temp Equipo', planta: 1));

      // CREATE
      final equipo = await equipoRepo.create(Equipo(
        aulaId: aula.id!,
        tipo: 'Impresora Láser',
        codigo: 'IMP-TEST-99',
      ));
      expect(equipo.id, isNotNull);
      final int eqId = equipo.id!;

      // READ
      final eqRecuperado = await equipoRepo.getById(eqId);
      expect(eqRecuperado, isNotNull);
      expect(eqRecuperado!.codigo, equals('IMP-TEST-99'));

      final equiposAula = await equipoRepo.getByAula(aula.id!);
      expect(equiposAula.any((e) => e.id == eqId), isTrue);

      // UPDATE
      final eqModificado = eqRecuperado.copyWith(tipo: 'Impresora Color Multifunción');
      await equipoRepo.update(eqModificado);
      final eqVerificado = await equipoRepo.getById(eqId);
      expect(eqVerificado!.tipo, equals('Impresora Color Multifunción'));

      // DELETE
      final filasBorradas = await equipoRepo.delete(eqId);
      expect(filasBorradas, equals(1));
      expect(await equipoRepo.getById(eqId), isNull);

      await aulaRepo.delete(aula.id!);
    });

    test('CRUD en tabla Incidencia', () async {
      final aula = await aulaRepo.create(const Aula(nombre: 'Aula Temp Incidencia', planta: 2));
      final equipo = await equipoRepo.create(Equipo(
        aulaId: aula.id!,
        tipo: 'PC Sobremesa',
        codigo: 'PC-INC-TEST',
      ));

      // CREATE
      final now = DateTime.now();
      final inc = await incidenciaRepo.create(Incidencia(
        equipoId: equipo.id!,
        descripcion: 'Disco duro con sectores defectuosos',
        prioridad: Prioridad.media,
        estado: Estado.abierta,
        fecha: now,
      ));
      expect(inc.id, isNotNull);
      final int incId = inc.id!;

      // READ
      final incRecuperada = await incidenciaRepo.getById(incId);
      expect(incRecuperada, isNotNull);
      expect(incRecuperada!.descripcion, equals('Disco duro con sectores defectuosos'));
      expect(incRecuperada.prioridad, equals(Prioridad.media));
      expect(incRecuperada.estado, equals(Estado.abierta));

      // UPDATE (Cambio de estado y prioridad)
      final incModificada = incRecuperada.copyWith(
        estado: Estado.resuelta,
        prioridad: Prioridad.alta,
      );
      await incidenciaRepo.update(incModificada);
      final incVerificada = await incidenciaRepo.getById(incId);
      expect(incVerificada!.estado, equals(Estado.resuelta));
      expect(incVerificada.prioridad, equals(Prioridad.alta));

      // DELETE
      final filasBorradas = await incidenciaRepo.delete(incId);
      expect(filasBorradas, equals(1));
      expect(await incidenciaRepo.getById(incId), isNull);

      await equipoRepo.delete(equipo.id!);
      await aulaRepo.delete(aula.id!);
    });

    test('CRUD en tabla Comentario', () async {
      final aula = await aulaRepo.create(const Aula(nombre: 'Aula Temp Comentario', planta: 0));
      final equipo = await equipoRepo.create(Equipo(
        aulaId: aula.id!,
        tipo: 'Router',
        codigo: 'RT-TEST-01',
      ));
      final inc = await incidenciaRepo.create(Incidencia(
        equipoId: equipo.id!,
        descripcion: 'Sin conexión a red',
        prioridad: Prioridad.urgente,
        estado: Estado.abierta,
        fecha: DateTime.now(),
      ));

      // CREATE
      final com = await comentarioRepo.create(Comentario(
        incidenciaId: inc.id!,
        fecha: DateTime.now(),
        texto: 'Se procedió al reinicio del router; persiste error de DHCP.',
      ));
      expect(com.id, isNotNull);
      final int comId = com.id!;

      // READ
      final comRecuperado = await comentarioRepo.getById(comId);
      expect(comRecuperado, isNotNull);
      expect(comRecuperado!.texto, contains('reinicio del router'));

      final comentariosInc = await comentarioRepo.getByIncidencia(inc.id!);
      expect(comentariosInc.length, equals(1));

      // UPDATE
      final comModificado = comRecuperado.copyWith(texto: 'Se ha reemplazado cable RJ45 dañado.');
      await comentarioRepo.update(comModificado);
      final comVerificado = await comentarioRepo.getById(comId);
      expect(comVerificado!.texto, equals('Se ha reemplazado cable RJ45 dañado.'));

      // DELETE
      final filasBorradas = await comentarioRepo.delete(comId);
      expect(filasBorradas, equals(1));
      expect(await comentarioRepo.getById(comId), isNull);

      await incidenciaRepo.delete(inc.id!);
      await equipoRepo.delete(equipo.id!);
      await aulaRepo.delete(aula.id!);
    });
  });

  group('2. Carga inicial de datos de ejemplo (Seeder >= 10 filas)', () {
    test('Seeder inserta 16 filas distribuidas en las 4 tablas', () async {
      final fueInsertado = await seeder.seedIfEmpty();
      expect(fueInsertado, isTrue, reason: 'Al estar vacía, se deben insertar los datos de ejemplo');

      final totalAulas = await aulaRepo.count();
      final totalEquipos = await equipoRepo.count();
      final totalIncidencias = await incidenciaRepo.count();
      final totalComentarios = await comentarioRepo.count();

      expect(totalAulas, equals(3));
      expect(totalEquipos, equals(5));
      expect(totalIncidencias, equals(4));
      expect(totalComentarios, equals(4));

      final totalFilas = totalAulas + totalEquipos + totalIncidencias + totalComentarios;
      expect(totalFilas, greaterThanOrEqualTo(10));
      expect(totalFilas, equals(16));
    });

    test('Seeder es idempotente (no duplica si ya existen datos)', () async {
      final segundoIntento = await seeder.seedIfEmpty();
      expect(segundoIntento, isFalse, reason: 'No debe reinsertar si ya existen aulas');

      final totalAulas = await aulaRepo.count();
      expect(totalAulas, equals(3));
    });
  });

  group('3. Persistencia de datos al reiniciar la base de datos', () {
    test('Los datos persisten tras cerrar y volver a abrir la conexión SQLite', () async {
      // 1. Verificar datos antes de cerrar
      final aulasPre = await aulaRepo.getAll();
      final equiposPre = await equipoRepo.getAll();
      final incidenciasPre = await incidenciaRepo.getAll();
      final comentariosPre = await comentarioRepo.getAll();

      expect(aulasPre.length, equals(3));
      expect(equiposPre.length, equals(5));
      expect(incidenciasPre.length, equals(4));
      expect(comentariosPre.length, equals(4));

      // 2. SIMULAR REINICIO DE LA APP / CONEXIÓN
      await DatabaseHelper.instance.close();

      // 3. Volver a abrir la conexión y verificar que todos los datos están intactos
      final aulasPost = await aulaRepo.getAll();
      final equiposPost = await equipoRepo.getAll();
      final incidenciasPost = await incidenciaRepo.getAll();
      final comentariosPost = await comentarioRepo.getAll();

      expect(aulasPost.length, equals(3));
      expect(equiposPost.length, equals(5));
      expect(incidenciasPost.length, equals(4));
      expect(comentariosPost.length, equals(4));

      // Validar un registro específico para asegurar integridad de contenido
      expect(aulasPost.first.nombre, equals('Taller de Hardware y Redes'));
      expect(equiposPost.any((e) => e.codigo == 'PC-101-01'), isTrue);
      expect(incidenciasPost.any((i) => i.prioridad == Prioridad.urgente), isTrue);
    });
  });
}
