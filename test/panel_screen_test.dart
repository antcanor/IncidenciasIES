import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/incidencias_controller.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/estado.dart';
import 'package:incidencias_ies/models/incidencia.dart';
import 'package:incidencias_ies/models/prioridad.dart';
import 'package:incidencias_ies/repositories/incidencia_repository.dart';
import 'package:incidencias_ies/routes/app_routes.dart';
import 'package:incidencias_ies/screens/panel_screen.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late IncidenciaRepository repo;
  late IncidenciasController controller;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_panel_screen_test.db');
    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();
  });

  setUp(() async {
    repo = IncidenciaRepository(dbHelper);
    controller = IncidenciasController(repository: repo);
    await controller.loadIncidencias();
  });

  tearDownAll(() async {
    await dbHelper.close();
  });

  Widget buildTestPanel() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: PanelScreen(controller: controller),
    );
  }

  group('Pantalla 1: Panel de Control (Dashboard)', () {
    testWidgets('1. Los números de las tarjetas coinciden con los COUNT de la base de datos', (tester) async {
      Map<Estado, int> conteoEstadoBD = {};
      Map<Prioridad, int> conteoPrioridadBD = {};

      await tester.runAsync(() async {
        conteoEstadoBD = await repo.countByEstado();
        conteoPrioridadBD = await repo.countByPrioridad();
      });

      await tester.pumpWidget(buildTestPanel());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Panel de Control'), findsOneWidget);
      expect(find.text('Contadores por Estado (COUNT)'), findsOneWidget);
      expect(find.text('Contadores por Prioridad (COUNT)'), findsOneWidget);

      // 4. Verificar números exactos de cada tarjeta de Estado
      final esperadasAbiertas = conteoEstadoBD[Estado.abierta] ?? 0;
      final esperadasEnProceso = conteoEstadoBD[Estado.enProceso] ?? 0;
      final esperadasResueltas = conteoEstadoBD[Estado.resuelta] ?? 0;
      final esperadasCerradas = conteoEstadoBD[Estado.cerrada] ?? 0;

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_abiertas')),
          matching: find.text('$esperadasAbiertas'),
        ),
        findsOneWidget,
        reason: 'El contador de Abiertas debe coincidir con la BD ($esperadasAbiertas)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_en_proceso')),
          matching: find.text('$esperadasEnProceso'),
        ),
        findsOneWidget,
        reason: 'El contador de En Proceso debe coincidir con la BD ($esperadasEnProceso)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_resueltas')),
          matching: find.text('$esperadasResueltas'),
        ),
        findsOneWidget,
        reason: 'El contador de Resueltas debe coincidir con la BD ($esperadasResueltas)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_cerradas')),
          matching: find.text('$esperadasCerradas'),
        ),
        findsOneWidget,
        reason: 'El contador de Cerradas debe coincidir con la BD ($esperadasCerradas)',
      );

      // 5. Verificar números exactos de cada tarjeta de Prioridad
      final esperadasUrgente = conteoPrioridadBD[Prioridad.urgente] ?? 0;
      final esperadasAlta = conteoPrioridadBD[Prioridad.alta] ?? 0;
      final esperadasMedia = conteoPrioridadBD[Prioridad.media] ?? 0;
      final esperadasBaja = conteoPrioridadBD[Prioridad.baja] ?? 0;

      expect(
        find.descendant(
          of: find.byKey(const Key('card_prioridad_urgente')),
          matching: find.text('$esperadasUrgente'),
        ),
        findsOneWidget,
        reason: 'El contador de Urgente debe coincidir con la BD ($esperadasUrgente)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_prioridad_alta')),
          matching: find.text('$esperadasAlta'),
        ),
        findsOneWidget,
        reason: 'El contador de Alta debe coincidir con la BD ($esperadasAlta)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_prioridad_media')),
          matching: find.text('$esperadasMedia'),
        ),
        findsOneWidget,
        reason: 'El contador de Media debe coincidir con la BD ($esperadasMedia)',
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_prioridad_baja')),
          matching: find.text('$esperadasBaja'),
        ),
        findsOneWidget,
        reason: 'El contador de Baja debe coincidir con la BD ($esperadasBaja)',
      );
    });

    testWidgets('2. Acceso rápido a «Nueva incidencia» existe y navega', (tester) async {
      await tester.pumpWidget(buildTestPanel());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final fabFinder = find.byKey(const Key('btn_nueva_incidencia_fab'));
      expect(fabFinder, findsOneWidget);
      expect(find.text('Nueva Incidencia'), findsOneWidget);

      final bannerBtnFinder = find.byKey(const Key('btn_nueva_incidencia_banner'));
      expect(bannerBtnFinder, findsOneWidget);
    });

    testWidgets('3. Los contadores se actualizan reactivamente al cambiar una incidencia (Cerrar incidencia)', (tester) async {
      await tester.pumpWidget(buildTestPanel());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final abiertaInicial = controller.incidencias.firstWhere(
        (i) => i.estado != Estado.cerrada,
        orElse: () => controller.incidencias.first,
      );

      final cerradasAntes = controller.conteoEstado[Estado.cerrada] ?? 0;
      final estadoAntes = controller.conteoEstado[abiertaInicial.estado] ?? 0;

      // Cambiar el estado a CERRADA dentro de runAsync
      await tester.runAsync(() async {
        await controller.cerrarIncidencia(abiertaInicial.id);
      });

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final cerradasDespues = controller.conteoEstado[Estado.cerrada] ?? 0;
      final estadoDespues = controller.conteoEstado[abiertaInicial.estado] ?? 0;

      expect(cerradasDespues, cerradasAntes + 1, reason: 'El contador de Cerradas debe incrementarse en 1');
      expect(estadoDespues, estadoAntes - 1, reason: 'El contador del estado previo debe decrecer en 1');

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_cerradas')),
          matching: find.text('$cerradasDespues'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('4. Los contadores se actualizan reactivamente al crear una nueva incidencia', (tester) async {
      await tester.pumpWidget(buildTestPanel());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final abiertasAntes = controller.conteoEstado[Estado.abierta] ?? 0;
      final urgentesAntes = controller.conteoPrioridad[Prioridad.urgente] ?? 0;
      final totalAntes = controller.totalIncidencias;

      await tester.runAsync(() async {
        await controller.createIncidencia(Incidencia(
          equipoId: 1,
          descripcion: 'Fallo de alimentación repentino en servidor',
          prioridad: Prioridad.urgente,
          estado: Estado.abierta,
          fecha: DateTime.now(),
        ));
      });

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final abiertasDespues = controller.conteoEstado[Estado.abierta] ?? 0;
      final urgentesDespues = controller.conteoPrioridad[Prioridad.urgente] ?? 0;
      final totalDespues = controller.totalIncidencias;

      expect(abiertasDespues, abiertasAntes + 1);
      expect(urgentesDespues, urgentesAntes + 1);
      expect(totalDespues, totalAntes + 1);

      expect(
        find.descendant(
          of: find.byKey(const Key('card_estado_abiertas')),
          matching: find.text('$abiertasDespues'),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('card_prioridad_urgente')),
          matching: find.text('$urgentesDespues'),
        ),
        findsOneWidget,
      );

      expect(
        find.text('$totalDespues incidencias registradas en la base de datos'),
        findsOneWidget,
      );
    });
  });
}
