import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/aulas_controller.dart';
import 'package:incidencias_ies/controllers/equipos_controller.dart';
import 'package:incidencias_ies/controllers/incidencias_controller.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/estado.dart';
import 'package:incidencias_ies/models/prioridad.dart';
import 'package:incidencias_ies/repositories/incidencia_repository.dart';
import 'package:incidencias_ies/routes/app_routes.dart';
import 'package:incidencias_ies/screens/incidencias_list_screen.dart';
import 'package:incidencias_ies/screens/nueva_incidencia_screen.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late IncidenciaRepository repo;
  late IncidenciasController controller;
  late AulasController aulasCtrl;
  late EquiposController equiposCtrl;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_drag_filter_test.db');
    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();

    aulasCtrl = AulasController();
    equiposCtrl = EquiposController();
    await Future.wait([
      aulasCtrl.loadAulas(),
      equiposCtrl.loadEquipos(),
    ]);

    AppRoutes.defaultAulasController = aulasCtrl;
    AppRoutes.defaultEquiposController = equiposCtrl;
  });

  setUp(() async {
    repo = IncidenciaRepository(dbHelper);
    controller = IncidenciasController(repository: repo);
    await controller.loadIncidencias();
    AppRoutes.defaultIncidenciasController = controller;
  });

  tearDownAll(() async {
    AppRoutes.defaultIncidenciasController = null;
    AppRoutes.defaultAulasController = null;
    AppRoutes.defaultEquiposController = null;
    aulasCtrl.dispose();
    equiposCtrl.dispose();
    await dbHelper.close();
  });

  Widget buildTestApp() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: IncidenciasListScreen(controller: controller),
    );
  }

  group('Pantalla 2: Incidencias abiertas (SegmentedButton, Drag & Drop y Atajos - RA1.g)', () {
    testWidgets('1. SegmentedButton filtra correctamente por Estado (Todas, Abiertas, En Proceso, Cerradas)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<Estado?>), findsOneWidget);
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Abiertas'), findsOneWidget);
      expect(find.text('En Proceso'), findsOneWidget);
      expect(find.text('Cerradas'), findsOneWidget);

      final totalInicial = controller.incidencias.length;
      final abiertasInicial = controller.incidencias.where((i) => i.estado == Estado.abierta).length;
      final enProcesoInicial = controller.incidencias.where((i) => i.estado == Estado.enProceso).length;
      final cerradasInicial = controller.incidencias.where((i) => i.estado == Estado.cerrada).length;

      // 1. Inicialmente se muestran todas
      expect(find.text('Mostrando $totalInicial de $totalInicial incidencias'), findsOneWidget);

      // 2. Filtrar por 'Abiertas'
      await tester.tap(find.text('Abiertas'));
      await tester.pumpAndSettle();
      expect(find.text('Mostrando $abiertasInicial de $totalInicial incidencias'), findsOneWidget);

      // 3. Filtrar por 'En Proceso'
      await tester.tap(find.text('En Proceso'));
      await tester.pumpAndSettle();
      expect(find.text('Mostrando $enProcesoInicial de $totalInicial incidencias'), findsOneWidget);

      // 4. Filtrar por 'Cerradas'
      await tester.tap(find.text('Cerradas'));
      await tester.pumpAndSettle();
      expect(find.text('Mostrando $cerradasInicial de $totalInicial incidencias'), findsOneWidget);

      // 5. Volver a 'Todas' usando el botón Quitar filtro
      if (find.text('Quitar filtro').evaluate().isNotEmpty) {
        await tester.tap(find.text('Quitar filtro'));
        await tester.pumpAndSettle();
        expect(find.text('Mostrando $totalInicial de $totalInicial incidencias'), findsOneWidget);
      }
    });

    testWidgets('2. Drag & Drop: arrastrar elemento cambia su prioridad y la guarda en SQLite', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Buscamos la primera incidencia disponible
      final primeraIncidencia = controller.incidencias.first;
      final id = primeraIncidencia.id;
      final prioridadOriginal = primeraIncidencia.prioridad;

      // Seleccionar una prioridad destino distinta a la actual
      final nuevaPrioridad = prioridadOriginal == Prioridad.urgente
          ? Prioridad.media
          : Prioridad.urgente;

      final draggableFinder = find.byKey(Key('draggable_incidencia_$id'));
      final targetFinder = find.byKey(Key('drag_target_${nuevaPrioridad.name}'));

      await tester.ensureVisible(draggableFinder);
      await tester.pumpAndSettle();

      expect(draggableFinder, findsOneWidget);
      expect(targetFinder, findsOneWidget);

      // Realizar el gesto de arrastre desde el Draggable hasta el DragTarget
      final startLocation = tester.getCenter(draggableFinder);
      final targetLocation = tester.getCenter(targetFinder);

      final gesture = await tester.startGesture(startLocation);
      await tester.pump();
      await gesture.moveTo(targetLocation);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Esperar a que la persistencia en SQLite en segundo plano concluya
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Verificar en la BD SQLite que la prioridad cambió
      await tester.runAsync(() async {
        final enBD = await repo.getById(id);
        expect(enBD, isNotNull);
        expect(enBD!.prioridad, equals(nuevaPrioridad));
      });

      // Verificar que el controlador local tiene la nueva prioridad
      final enCtrl = controller.incidencias.firstWhere((i) => i.id == id);
      expect(enCtrl.prioridad, equals(nuevaPrioridad));
    });

    testWidgets('3. Atajos de teclado: Ctrl+1..4 cambian el filtro y Ctrl+N abre nueva incidencia', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final total = controller.incidencias.length;
      final abiertas = controller.incidencias.where((i) => i.estado == Estado.abierta).length;

      // Probar Ctrl+2 (Filtrar abiertas)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.text('Mostrando $abiertas de $total incidencias'), findsOneWidget);

      // Probar Ctrl+1 (Volver a todas)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.text('Mostrando $total de $total incidencias'), findsOneWidget);

      // Probar Ctrl+N (Abrir pantalla de nueva incidencia)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      expect(find.byType(NuevaIncidenciaScreen), findsOneWidget);
      expect(find.text('Registrar Nueva Incidencia'), findsOneWidget);

      // Regresar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(IncidenciasListScreen), findsOneWidget);
    });

    testWidgets('4. Clic derecho / ratón secundario abre menú contextual y permite reclasificar prioridad', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final inc = controller.incidencias.first;
      final id = inc.id;
      final pOriginal = inc.prioridad;
      final nuevaP = pOriginal == Prioridad.baja ? Prioridad.alta : Prioridad.baja;

      final cardFinder = find.byKey(Key('draggable_incidencia_$id'));
      await tester.ensureVisible(cardFinder);
      await tester.pumpAndSettle();

      // Clic secundario con ratón (botón derecho)
      final center = tester.getCenter(cardFinder);
      final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse, buttons: kSecondaryMouseButton);
      await gesture.down(center);
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      // El menú contextual debe estar abierto mostrando las prioridades
      expect(find.text('Cambiar prioridad con ratón (#$id)'), findsOneWidget);

      // Seleccionar la nueva prioridad en el menú contextual
      final itemFinder = find.widgetWithText(PopupMenuItem<Prioridad>, nuevaP.value);
      expect(itemFinder, findsOneWidget);
      await tester.tap(itemFinder);
      await tester.pump();

      // Esperar a que la persistencia en SQLite en segundo plano concluya
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Comprobar persistencia en SQLite
      await tester.runAsync(() async {
        final enBD = await repo.getById(id);
        expect(enBD, isNotNull);
        expect(enBD!.prioridad, equals(nuevaP));
      });
    });
  });
}
