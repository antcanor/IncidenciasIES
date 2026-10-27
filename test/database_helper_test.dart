import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_unit_test.db');
    
    // Limpiar BD para asegurar entorno de pruebas limpio
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'incidencias_unit_test.db');
    await databaseFactory.deleteDatabase(path);
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  test('DatabaseHelper inicializa la base de datos y crea las 4 tablas con FKs activadas', () async {
    final status = await DatabaseHelper.instance.checkDatabaseStatus();

    expect(status['foreignKeysEnabled'], isTrue, reason: 'PRAGMA foreign_keys debe estar activo');
    
    final tables = status['tables'] as List<String>;
    expect(tables, contains('aula'));
    expect(tables, contains('equipo'));
    expect(tables, contains('incidencia'));
    expect(tables, contains('comentario'));
  });

  test('Integridad referencial: Restringe borrado de aula con equipos asignados', () async {
    final db = await DatabaseHelper.instance.database;

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    // Insertar aula
    final aulaId = await db.insert('aula', {
      'nombre': 'Aula $timestamp',
      'planta': 1,
    });

    // Insertar equipo en dicha aula
    await db.insert('equipo', {
      'aula_id': aulaId,
      'tipo': 'PC',
      'codigo': 'PC-$timestamp',
    });

    // Intentar borrar el aula debe fallar por ON DELETE RESTRICT
    expect(
      () async => await db.delete('aula', where: 'id = ?', whereArgs: [aulaId]),
      throwsA(isA<DatabaseException>()),
      reason: 'No se debe permitir eliminar un aula que contiene equipos (ON DELETE RESTRICT)',
    );
  });
}
