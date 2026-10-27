import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_widget_test.db');
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('IncidenciasApp muestra la pantalla principal con pestañas y CRUD', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await DatabaseHelper.instance.database;
      await DatabaseSeeder().seedIfEmpty();
    });

    await tester.pumpWidget(const IncidenciasApp());

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });

    await tester.pump();

    expect(find.text('IncidenciasIES — CRUD & SQLite'), findsOneWidget);
    expect(find.text('Incidencias'), findsOneWidget);
    expect(find.text('Equipos y Aulas'), findsOneWidget);
    expect(find.text('Estado BD'), findsOneWidget);
    expect(find.text('Nueva Incidencia'), findsOneWidget);
  });
}
