import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/routes/app_routes.dart';
import 'package:incidencias_ies/screens/screens.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IncidenciasController sharedIncidencias;
  late AulasController sharedAulas;
  late EquiposController sharedEquipos;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_navigation_test.db');
    await DatabaseHelper.instance.database;
    await DatabaseSeeder().seedIfEmpty();

    sharedIncidencias = IncidenciasController();
    sharedAulas = AulasController();
    sharedEquipos = EquiposController();

    await Future.wait([
      sharedIncidencias.loadIncidencias(),
      sharedAulas.loadAulas(),
      sharedEquipos.loadEquipos(),
    ]);

    AppRoutes.defaultIncidenciasController = sharedIncidencias;
    AppRoutes.defaultAulasController = sharedAulas;
    AppRoutes.defaultEquiposController = sharedEquipos;
  });

  tearDownAll(() async {
    AppRoutes.defaultIncidenciasController = null;
    AppRoutes.defaultAulasController = null;
    AppRoutes.defaultEquiposController = null;
    sharedIncidencias.dispose();
    sharedAulas.dispose();
    sharedEquipos.dispose();
    await DatabaseHelper.instance.close();
  });

  group('Pruebas de Rutas y Navegación entre 10 Pantallas (AppRoutes)', () {
    test('Deben existir exactamente 10 rutas registradas en AppRoutes.allRoutes', () {
      expect(AppRoutes.allRoutes.length, 10);
      expect(AppRoutes.allRoutes, containsAll([
        AppRoutes.panel,
        AppRoutes.incidencias,
        AppRoutes.incidenciaDetalle,
        AppRoutes.nuevaIncidencia,
        AppRoutes.aulas,
        AppRoutes.aulaDetalle,
        AppRoutes.nuevaAula,
        AppRoutes.equipos,
        AppRoutes.equipoDetalle,
        AppRoutes.nuevoEquipo,
      ]));
    });

    Widget createTestApp({String initialRoute = AppRoutes.panel}) {
      return MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: initialRoute,
      );
    }

    testWidgets('1. Navegar a PanelScreen (/) y verificar componentes', (tester) async {
      await tester.pumpWidget(createTestApp(initialRoute: AppRoutes.panel));
      await tester.pumpAndSettle();

      expect(find.text('Panel de Control'), findsOneWidget);
      expect(find.text('Gestión de Incidencias'), findsOneWidget);
      expect(find.text('Aulas y Espacios'), findsOneWidget);
      expect(find.text('Equipos e Inventario'), findsOneWidget);
    });

    testWidgets('2. Navegar a IncidenciasListScreen (/incidencias) y volver atrás sin errores', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.incidencias),
                child: const Text('Ir a Incidencias'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ir a Incidencias'));
      await tester.pumpAndSettle();

      expect(find.text('Listado de Incidencias'), findsOneWidget);
      expect(find.byType(IncidenciasListScreen), findsOneWidget);

      // Volver atrás
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Ir a Incidencias'), findsOneWidget);
      expect(find.byType(IncidenciasListScreen), findsNothing);
    });

    testWidgets('3. Navegar a IncidenciaDetalleScreen (/incidencias/detalle) con argumento ID y volver', (tester) async {
      const testId = 99;
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.incidenciaDetalle,
                  arguments: testId,
                ),
                child: const Text('Ver Detalle'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Detalle'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle Incidencia #$testId'), findsOneWidget);
      expect(find.text('ID de Incidencia recibido por argumento'), findsOneWidget);
      expect(find.text('$testId'), findsOneWidget);
      expect(find.byType(IncidenciaDetalleScreen), findsOneWidget);

      // Volver atrás usando el botón de la UI
      await tester.tap(find.text('Volver al Listado'));
      await tester.pumpAndSettle();

      expect(find.text('Ver Detalle'), findsOneWidget);
      expect(find.byType(IncidenciaDetalleScreen), findsNothing);
    });

    testWidgets('4. Navegar a NuevaIncidenciaScreen (/incidencias/nueva) con argumento equipoId y volver', (tester) async {
      const testEquipoId = 42;
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.nuevaIncidencia,
                  arguments: testEquipoId,
                ),
                child: const Text('Nueva Incidencia'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nueva Incidencia'));
      await tester.pumpAndSettle();

      expect(find.text('Registrar Nueva Incidencia'), findsOneWidget);
      expect(find.text('Equipo asignado previamente: #$testEquipoId'), findsOneWidget);
      expect(find.byType(NuevaIncidenciaScreen), findsOneWidget);

      // Cancelar y volver atrás
      await tester.ensureVisible(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();

      expect(find.text('Nueva Incidencia'), findsOneWidget);
      expect(find.byType(NuevaIncidenciaScreen), findsNothing);
    });

    testWidgets('5. Navegar a AulasListScreen (/aulas) y volver atrás', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.aulas),
                child: const Text('Ir a Aulas'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ir a Aulas'));
      await tester.pumpAndSettle();

      expect(find.text('Listado de Aulas'), findsOneWidget);
      expect(find.byType(AulasListScreen), findsOneWidget);

      // Volver atrás
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Ir a Aulas'), findsOneWidget);
      expect(find.byType(AulasListScreen), findsNothing);
    });

    testWidgets('6. Navegar a AulaDetalleScreen (/aulas/detalle) con argumento aulaId y volver', (tester) async {
      const testAulaId = 12;
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.aulaDetalle,
                  arguments: testAulaId,
                ),
                child: const Text('Detalle Aula'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detalle Aula'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de Aula #$testAulaId'), findsOneWidget);
      expect(find.text('ID recibido por ruta: $testAulaId'), findsOneWidget);
      expect(find.byType(AulaDetalleScreen), findsOneWidget);

      // Volver con el botón de la UI
      await tester.tap(find.text('Volver a Aulas'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle Aula'), findsOneWidget);
      expect(find.byType(AulaDetalleScreen), findsNothing);
    });

    testWidgets('7. Navegar a NuevaAulaScreen (/aulas/nueva) y volver', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.nuevaAula),
                child: const Text('Añadir Aula'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Añadir Aula'));
      await tester.pumpAndSettle();

      expect(find.text('Crear Nueva Aula'), findsOneWidget);
      expect(find.byType(NuevaAulaScreen), findsOneWidget);

      // Volver con botón cancelar
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();

      expect(find.text('Añadir Aula'), findsOneWidget);
      expect(find.byType(NuevaAulaScreen), findsNothing);
    });

    testWidgets('8. Navegar a EquiposListScreen (/equipos) y volver atrás', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.equipos),
                child: const Text('Ver Equipos'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Equipos'));
      await tester.pumpAndSettle();

      expect(find.text('Listado de Equipos'), findsOneWidget);
      expect(find.byType(EquiposListScreen), findsOneWidget);

      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('Ver Equipos'), findsOneWidget);
      expect(find.byType(EquiposListScreen), findsNothing);
    });

    testWidgets('9. Navegar a EquipoDetalleScreen (/equipos/detalle) con argumento equipoId y volver', (tester) async {
      const testEquipoId = 88;
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.equipoDetalle,
                  arguments: testEquipoId,
                ),
                child: const Text('Detalle Equipo'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detalle Equipo'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de Equipo #$testEquipoId'), findsOneWidget);
      expect(find.text('Argumento recibido: $testEquipoId'), findsOneWidget);
      expect(find.byType(EquipoDetalleScreen), findsOneWidget);

      // Volver con el botón de la UI
      await tester.tap(find.text('Volver a Equipos'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle Equipo'), findsOneWidget);
      expect(find.byType(EquipoDetalleScreen), findsNothing);
    });

    testWidgets('10. Navegar a NuevoEquipoScreen (/equipos/nuevo) con argumento aulaId y volver', (tester) async {
      const testAulaId = 5;
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.nuevoEquipo,
                  arguments: testAulaId,
                ),
                child: const Text('Nuevo Equipo'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nuevo Equipo'));
      await tester.pumpAndSettle();

      expect(find.text('Registrar Nuevo Equipo'), findsOneWidget);
      expect(find.text('Aula asignada por defecto: #$testAulaId'), findsOneWidget);
      expect(find.byType(NuevoEquipoScreen), findsOneWidget);

      // Volver con botón cancelar
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Equipo'), findsOneWidget);
      expect(find.byType(NuevoEquipoScreen), findsNothing);
    });

    testWidgets('11. Navegación cruzada: De IncidenciasListScreen a IncidenciaDetalleScreen y NuevaIncidenciaScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.incidencias,
      ));
      await tester.pumpAndSettle();

      // Pulsar primer item de la lista
      await tester.ensureVisible(find.text('PC-101-01 no enciende tras tormenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PC-101-01 no enciende tras tormenta'));
      await tester.pumpAndSettle();

      // Debe abrir detalle de id #1
      expect(find.text('Detalle Incidencia #1'), findsOneWidget);
      expect(find.byType(IncidenciaDetalleScreen), findsOneWidget);

      // Volver atrás
      await tester.tap(find.text('Volver al Listado'));
      await tester.pumpAndSettle();
      expect(find.byType(IncidenciasListScreen), findsOneWidget);

      // Pulsar FAB de nueva incidencia
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(NuevaIncidenciaScreen), findsOneWidget);

      // Esperar a que los temporizadores de sqflite se completen
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Volver atrás
      await tester.ensureVisible(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(IncidenciasListScreen), findsOneWidget);
    });

    testWidgets('12. Navegación cruzada: De AulasListScreen a AulaDetalleScreen y NuevaAulaScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.aulas,
      ));
      await tester.pumpAndSettle();

      // Pulsar primer aula
      await tester.tap(find.text('Aula 101 - Informática'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de Aula #1'), findsOneWidget);
      expect(find.byType(AulaDetalleScreen), findsOneWidget);

      // Volver atrás
      await tester.tap(find.text('Volver a Aulas'));
      await tester.pumpAndSettle();
      expect(find.byType(AulasListScreen), findsOneWidget);

      // Pulsar FAB nueva aula
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(NuevaAulaScreen), findsOneWidget);

      // Volver atrás
      await tester.ensureVisible(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(AulasListScreen), findsOneWidget);
    });

    testWidgets('13. Navegación cruzada: De EquiposListScreen a EquipoDetalleScreen y NuevoEquipoScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.equipos,
      ));
      await tester.pumpAndSettle();

      // Pulsar primer equipo
      await tester.tap(find.text('PC-101-01'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de Equipo #1'), findsOneWidget);
      expect(find.byType(EquipoDetalleScreen), findsOneWidget);

      // Volver atrás
      await tester.tap(find.text('Volver a Equipos'));
      await tester.pumpAndSettle();
      expect(find.byType(EquiposListScreen), findsOneWidget);

      // Pulsar FAB nuevo equipo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(NuevoEquipoScreen), findsOneWidget);

      // Volver atrás
      await tester.ensureVisible(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar y Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(EquiposListScreen), findsOneWidget);
    });

    testWidgets('14. Drawer en PanelScreen abre y permite navegar a incidencias, aulas y equipos', (tester) async {
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.panel,
      ));
      await tester.pumpAndSettle();

      // Abrir Drawer usando el botón del AppBar
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('IncidenciasIES'), findsOneWidget);
      expect(find.text('10 Pantallas & Rutas MVC'), findsOneWidget);

      // Pulsar Incidencias en Drawer
      await tester.tap(find.widgetWithText(ListTile, 'Incidencias'));
      await tester.pumpAndSettle();

      expect(find.byType(IncidenciasListScreen), findsOneWidget);

      // Esperar a que los temporizadores de sqflite se completen
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Volver a panel
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.byType(PanelScreen), findsOneWidget);
    });
  });
}
