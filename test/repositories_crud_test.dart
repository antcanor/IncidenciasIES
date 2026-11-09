import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AulaRepository aulas;
  late EquipoRepository equipos;
  late IncidenciaRepository incidencias;
  late ComentarioRepository comentarios;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('repositories_crud_test.db');
    final dbPath = await getDatabasesPath();
    await databaseFactory.deleteDatabase(
      p.join(dbPath, 'repositories_crud_test.db'),
    );
    final db = DatabaseHelper.instance;
    await db.database;
    aulas = AulaRepository(db);
    equipos = EquipoRepository(db);
    incidencias = IncidenciaRepository(db);
    comentarios = ComentarioRepository(db);
  });

  tearDownAll(() => DatabaseHelper.instance.close());

  test('ejecuta el CRUD completo de aulas, equipos, incidencias y comentarios', () async {
    final aula = await aulas.create(const Aula(nombre: 'Aula CRUD', planta: 2));
    expect(await aulas.getById(aula.id!), aula);
    expect((await aulas.getAll()).map((item) => item.id), contains(aula.id));

    final aulaActualizada = aula.copyWith(nombre: 'Aula CRUD actualizada');
    expect(await aulas.update(aulaActualizada), 1);
    expect(await aulas.getById(aula.id!), aulaActualizada);

    final equipo = await equipos.create(
      Equipo(aulaId: aula.id!, tipo: 'Portátil', codigo: 'CRUD-01'),
    );
    expect(await equipos.getById(equipo.id!), equipo);
    expect(await equipos.getByAula(aula.id!), [equipo]);
    expect(await equipos.count(), 1);

    final fecha = DateTime.utc(2026, 11, 9, 10);
    final incidencia = await incidencias.create(
      Incidencia(
        equipoId: equipo.id!,
        descripcion: 'Fallo de prueba',
        prioridad: Prioridad.alta,
        estado: Estado.abierta,
        fecha: fecha,
      ),
    );
    expect(await incidencias.getById(incidencia.id!), incidencia);
    expect(await incidencias.getByEquipo(equipo.id!), [incidencia]);
    expect(await incidencias.getByEstado(Estado.abierta), [incidencia]);
    expect(await incidencias.getByPrioridad(Prioridad.alta), [incidencia]);
    expect(await incidencias.count(), 1);
    expect(
      await incidencias.countActiveByEquipoIds([equipo.id!]),
      {equipo.id!: 1},
    );
    expect(await incidencias.countActiveByEquipoIds([]), isEmpty);
    expect(await incidencias.countByStates([Estado.abierta]), 1);
    expect(await incidencias.countByStates([]), 0);

    final incidenciaActualizada = incidencia.copyWith(
      estado: Estado.cerrada,
      descripcion: 'Fallo resuelto',
    );
    expect(await incidencias.update(incidenciaActualizada), 1);
    expect(await incidencias.getById(incidencia.id!), incidenciaActualizada);

    final comentario = await comentarios.create(
      Comentario(
        incidenciaId: incidencia.id!,
        fecha: fecha,
        texto: 'Revisado',
      ),
    );
    expect(await comentarios.getById(comentario.id!), comentario);
    expect(await comentarios.getAll(), [comentario]);
    expect(await comentarios.getByIncidencia(incidencia.id!), [comentario]);
    expect(await comentarios.count(), 1);
    expect(
      await comentarios.update(comentario.copyWith(texto: 'Actualizado')),
      1,
    );
    expect((await comentarios.getById(comentario.id!))!.texto, 'Actualizado');
    expect(await comentarios.delete(comentario.id!), 1);
    expect(await comentarios.count(), 0);

    expect(await incidencias.delete(incidencia.id!), 1);
    expect(await equipos.delete(equipo.id!), 1);
    expect(await aulas.delete(aula.id!), 1);
    expect(await incidencias.getById(incidencia.id!), isNull);
    expect(await equipos.getById(equipo.id!), isNull);
    expect(await aulas.getById(aula.id!), isNull);
  });

  test('rechaza actualizar entidades sin identificador', () async {
    expect(
      () => aulas.update(const Aula(nombre: 'Sin ID', planta: 1)),
      throwsArgumentError,
    );
    expect(
      () => equipos.update(
        const Equipo(aulaId: 1, tipo: 'PC', codigo: 'SIN-ID'),
      ),
      throwsArgumentError,
    );
    expect(
      () => incidencias.update(
        Incidencia(
          equipoId: 1,
          descripcion: 'Sin ID',
          prioridad: Prioridad.media,
          estado: Estado.abierta,
          fecha: DateTime.utc(2026),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => comentarios.update(
        Comentario(
          incidenciaId: 1,
          fecha: DateTime.utc(2026),
          texto: 'Sin ID',
        ),
      ),
      throwsArgumentError,
    );
  });
}
