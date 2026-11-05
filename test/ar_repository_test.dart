import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseHelper dbHelper;
  late IncidenciaRepository repository;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('ar_repository_test.db');
    final dbPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase('$dbPath/ar_repository_test.db');
    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();
    repository = IncidenciaRepository(dbHelper);
  });

  tearDownAll(() => dbHelper.close());

  test('consulta el historial completo del equipo desde SQLite', () async {
    final equipos = await EquipoRepository(dbHelper).getAll();
    final historial = await repository.getIncidenciasPorEquipo(
      equipos.first.id!,
    );

    expect(historial, isNotEmpty);
    expect(
      historial.every((item) => item.equipoId == equipos.first.id),
      isTrue,
    );
    expect(historial.first.equipoCodigo, equipos.first.codigo);
  });
}
