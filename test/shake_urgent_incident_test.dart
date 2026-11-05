import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late IncidenciaRepository repository;
  late EquiposController equiposController;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('shake_urgent_incident_test.db');
    final dbPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      '$dbPath/shake_urgent_incident_test.db',
    );

    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();
    repository = IncidenciaRepository(dbHelper);
    equiposController = EquiposController(
      repository: EquipoRepository(dbHelper),
    );
    await equiposController.loadEquipos();
  });

  tearDownAll(() async {
    equiposController.dispose();
    await dbHelper.close();
  });

  test('guarda en SQLite una incidencia urgente creada por sacudida', () async {
    final equipo = equiposController.equipos.first;
    final controller = IncidenciasController(repository: repository);

    final created = await controller.createIncidencia(
      Incidencia(
        equipoId: equipo.id!,
        descripcion: 'Incidencia urgente detectada por sacudida',
        prioridad: Prioridad.urgente,
        estado: Estado.abierta,
        fecha: DateTime.now(),
      ),
    );

    expect(created, isNotNull);
    expect(created!.prioridad, Prioridad.urgente);
    final persisted = await repository.getById(created.id!);
    expect(persisted?.descripcion, 'Incidencia urgente detectada por sacudida');
    expect(persisted?.prioridad, Prioridad.urgente);
    controller.dispose();
  });
}
