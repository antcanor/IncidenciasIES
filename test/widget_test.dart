import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/main.dart';
import 'package:incidencias_ies/theme/theme.dart';
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

  testWidgets('IncidenciasApp muestra la pantalla principal con Material 3 y pestañas', (WidgetTester tester) async {
    final incidenciasCtrl = IncidenciasController();
    final aulasCtrl = AulasController();
    final equiposCtrl = EquiposController();
    final themeCtrl = ThemeController();

    await tester.runAsync(() async {
      await DatabaseHelper.instance.database;
      await DatabaseSeeder().seedIfEmpty();

      await Future.wait([
        aulasCtrl.loadAulas(),
        equiposCtrl.loadEquipos(),
        incidenciasCtrl.loadIncidencias(),
      ]);
    });

    await tester.pumpWidget(IncidenciasApp(
      incidenciasCtrl: incidenciasCtrl,
      aulasCtrl: aulasCtrl,
      equiposCtrl: equiposCtrl,
      themeController: themeCtrl,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('IncidenciasIES — Material 3'), findsOneWidget);
    expect(find.text('Panel'), findsOneWidget);
    expect(find.text('Incidencias (JOIN)'), findsOneWidget);
    expect(find.text('Equipos y Aulas'), findsOneWidget);
    expect(find.text('Estado BD'), findsOneWidget);
    expect(find.text('Nueva Incidencia'), findsOneWidget);

    incidenciasCtrl.dispose();
    aulasCtrl.dispose();
    equiposCtrl.dispose();
    themeCtrl.dispose();
  });
}
