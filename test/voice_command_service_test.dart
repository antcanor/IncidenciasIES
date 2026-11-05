import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/estado.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:incidencias_ies/services/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late VoiceCommandService service;
  late IncidenciaRepository incidenciaRepository;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('voice_command_service_test.db');
    final dbPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      '$dbPath/voice_command_service_test.db',
    );

    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();
    incidenciaRepository = IncidenciaRepository(dbHelper);
    service = VoiceCommandService(
      incidenciaRepository: incidenciaRepository,
      aulaRepository: AulaRepository(dbHelper),
      equipoRepository: EquipoRepository(dbHelper),
    );
  });

  tearDownAll(() => dbHelper.close());

  test('cierra la incidencia del equipo y aula indicados', () async {
    final before = await incidenciaRepository.countByStates([
      Estado.abierta,
      Estado.enProceso,
    ]);

    final result = await service.execute(
      'Cierra la incidencia del proyector del aula 204',
    );

    expect(result.handled, isTrue);
    expect(result.successful, isTrue);
    expect(result.message, contains('He cerrado'));
    expect(
      await incidenciaRepository.countByStates([
        Estado.abierta,
        Estado.enProceso,
      ]),
      before - 1,
    );
  });

  test('consulta el número de incidencias abiertas', () async {
    final expected = await incidenciaRepository.countByStates([
      Estado.abierta,
      Estado.enProceso,
    ]);

    final result = await service.execute('Cuántas incidencias abiertas hay');

    expect(result.handled, isTrue);
    expect(result.successful, isTrue);
    expect(result.message, 'Hay $expected incidencias abiertas.');
  });
}
