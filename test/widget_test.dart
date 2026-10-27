import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('IncidenciasApp muestra la pantalla de estado de SQLite', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await DatabaseHelper.instance.database;
    });

    await tester.pumpWidget(const IncidenciasApp());

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });

    await tester.pump();

    expect(find.text('IncidenciasIES — SQLite Status'), findsOneWidget);
    expect(find.text('Base de Datos Conectada'), findsOneWidget);
    expect(find.text('aula'), findsOneWidget);
    expect(find.text('equipo'), findsOneWidget);
    expect(find.text('incidencia'), findsOneWidget);
    expect(find.text('comentario'), findsOneWidget);
  });
}
