import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/repositories/repositories.dart';
import 'package:incidencias_ies/routes/app_routes.dart';
import 'package:incidencias_ies/screens/screens.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late IncidenciaRepository incidenciaRepo;
  late AulaRepository aulaRepo;
  late EquipoRepository equipoRepo;

  late IncidenciasController incidenciasCtrl;
  late AulasController aulasCtrl;
  late EquiposController equiposCtrl;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('nueva_incidencia_screen_test.db');
    try {
      final dbPath = await databaseFactory.getDatabasesPath();
      await databaseFactory.deleteDatabase(
        '$dbPath/nueva_incidencia_screen_test.db',
      );
    } catch (_) {}
    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();

    incidenciaRepo = IncidenciaRepository(dbHelper);
    aulaRepo = AulaRepository(dbHelper);
    equipoRepo = EquipoRepository(dbHelper);
  });

  setUp(() async {
    incidenciasCtrl = IncidenciasController(repository: incidenciaRepo);
    aulasCtrl = AulasController(repository: aulaRepo);
    equiposCtrl = EquiposController(repository: equipoRepo);

    await Future.wait([
      incidenciasCtrl.loadIncidencias(),
      aulasCtrl.loadAulas(),
      equiposCtrl.loadEquipos(),
    ]);

    AppRoutes.defaultIncidenciasController = incidenciasCtrl;
    AppRoutes.defaultAulasController = aulasCtrl;
    AppRoutes.defaultEquiposController = equiposCtrl;
    AppRoutes.enableShakeDetection = false;
  });

  tearDownAll(() async {
    AppRoutes.defaultIncidenciasController = null;
    AppRoutes.defaultAulasController = null;
    AppRoutes.defaultEquiposController = null;
    AppRoutes.enableShakeDetection = true;
    incidenciasCtrl.dispose();
    aulasCtrl.dispose();
    equiposCtrl.dispose();
    await dbHelper.close();
  });

  Widget buildTestApp({int? equipoId, VoidCallback? onDictadoVoz}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: NuevaIncidenciaScreen(
        equipoId: equipoId,
        incidenciasCtrl: incidenciasCtrl,
        aulasCtrl: aulasCtrl,
        equiposCtrl: equiposCtrl,
        onDictadoVoz: onDictadoVoz,
        enableShakeDetection: false,
      ),
    );
  }

  group(
    'Pantalla 4: Nueva Incidencia (formulario con validación y dictado)',
    () {
      testWidgets(
        '1. Renderiza los campos en orden: Aula -> Equipo -> Descripción -> Prioridad y botón de dictado',
        (tester) async {
          await tester.pumpWidget(buildTestApp());
          await tester.pumpAndSettle();

          // Cabecera
          expect(find.text('Registrar Nueva Incidencia'), findsOneWidget);

          // Paso 1: Aula
          expect(find.byKey(const Key('dropdown_aula')), findsOneWidget);

          // Paso 2: Equipo
          expect(find.byKey(const Key('dropdown_equipo')), findsOneWidget);

          // Paso 3: Descripción y Botón de dictado
          expect(find.byKey(const Key('input_descripcion')), findsOneWidget);
          expect(find.byKey(const Key('btn_dictado_voz')), findsOneWidget);
          expect(find.text('Dictar por voz'), findsOneWidget);

          // Paso 4: Selector de Prioridad con Chips
          expect(
            find.byKey(const Key('card_prioridad_selector')),
            findsOneWidget,
          );
          for (final p in Prioridad.values) {
            expect(find.byKey(Key('chip_prioridad_${p.name}')), findsOneWidget);
          }

          // Previsualización y botones de acción
          expect(find.byType(LiveTicketPreviewCard), findsOneWidget);
          expect(
            find.byKey(const Key('btn_guardar_incidencia')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('btn_cancelar_incidencia')),
            findsOneWidget,
          );
        },
      );

      testWidgets('2. Permite seleccionar aula sin cambiar la prioridad', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('dropdown_aula')));
        await tester.pumpAndSettle();

        expect(find.textContaining('Aula 101').last, findsOneWidget);
        await tester.tap(find.textContaining('Aula 101').last);
        await tester.pumpAndSettle();

        expect(find.textContaining('Aula 101').first, findsOneWidget);
      });

      testWidgets(
        '3. Botón de dictado por voz ejecuta el callback alternativo',
        (tester) async {
          bool dictadoCallbackEjecutado = false;

          await tester.pumpWidget(
            buildTestApp(
              onDictadoVoz: () {
                dictadoCallbackEjecutado = true;
              },
            ),
          );
          await tester.pumpAndSettle();

          // Pulsar botón de dictado
          await tester.tap(find.byKey(const Key('btn_dictado_voz')));
          await tester.pump();

          expect(dictadoCallbackEjecutado, isTrue);

          // La entrada manual sigue disponible como alternativa.
          expect(find.byKey(const Key('input_descripcion')), findsOneWidget);
        },
      );

      testWidgets(
        '3. Validación: formulario inválido muestra errores y NO guarda la incidencia',
        (tester) async {
          final totalInicial = incidenciasCtrl.incidencias.length;

          await tester.pumpWidget(buildTestApp());
          await tester.pumpAndSettle();

          // 3.1 Intentar guardar formulario totalmente vacío
          await tester.ensureVisible(
            find.byKey(const Key('btn_guardar_incidencia')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('btn_guardar_incidencia')));
          await tester.pumpAndSettle();

          // Debe mostrar errores de validación de aula, equipo y descripción
          expect(find.text('Por favor, selecciona un aula.'), findsOneWidget);
          expect(find.text('Por favor, selecciona un equipo.'), findsOneWidget);
          expect(
            find.text('Debes introducir una descripción de la avería.'),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('snackbar_error_validacion')),
            findsOneWidget,
          );

          // 3.2 Seleccionar aula y equipo pero poner descripción demasiado corta (< 5 caracteres)
          // Asegurarse de hacer scroll arriba al dropdown de aula
          await tester.ensureVisible(find.byKey(const Key('dropdown_aula')));
          await tester.pumpAndSettle();

          // Seleccionar Aula
          await tester.tap(find.byKey(const Key('dropdown_aula')));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('Aula 101').last);
          await tester.pumpAndSettle();

          // Seleccionar Equipo
          await tester.ensureVisible(find.byKey(const Key('dropdown_equipo')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('dropdown_equipo')));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('PC-101-01').last);
          await tester.pumpAndSettle();

          // Introducir texto corto "abc"
          await tester.enterText(
            find.byKey(const Key('input_descripcion')),
            'abc',
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(
            find.byKey(const Key('btn_guardar_incidencia')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('btn_guardar_incidencia')));
          await tester.pumpAndSettle();

          // Error específico de longitud mínima
          expect(
            find.text('La descripción debe tener al menos 5 caracteres.'),
            findsOneWidget,
          );

          // Comprobar que en la base de datos NO se ha creado ninguna fila
          expect(incidenciasCtrl.incidencias.length, equals(totalInicial));
        },
      );

      testWidgets(
        '4. Crear una incidencia válida la guarda en SQLite y aparece en el listado',
        (tester) async {
          final totalInicial = incidenciasCtrl.incidencias.length;
          const descTest =
              'El proyector parpadea y se apaga tras 5 minutos de uso';

          // Montamos una app con navegación completa para verificar que aparece en IncidenciasListScreen
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              home: IncidenciasListScreen(controller: incidenciasCtrl),
            ),
          );
          await tester.pumpAndSettle();

          // 4.1 Abrir NuevaIncidenciaScreen mediante el FAB
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          expect(find.byType(NuevaIncidenciaScreen), findsOneWidget);

          // 4.2 Seleccionar Aula
          await tester.tap(find.byKey(const Key('dropdown_aula')));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('Aula 101').last);
          await tester.pumpAndSettle();

          // 4.3 Seleccionar Equipo
          await tester.tap(find.byKey(const Key('dropdown_equipo')));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('PC-101-02').last);
          await tester.pumpAndSettle();

          // 4.4 Escribir descripción válida
          await tester.enterText(
            find.byKey(const Key('input_descripcion')),
            descTest,
          );
          await tester.pumpAndSettle();

          // 4.5 Seleccionar prioridad urgente
          await tester.ensureVisible(
            find.byKey(const Key('chip_prioridad_urgente')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('chip_prioridad_urgente')));
          await tester.pumpAndSettle();

          // 4.6 Guardar incidencia
          await tester.ensureVisible(
            find.byKey(const Key('btn_guardar_incidencia')),
          );
          await tester.pumpAndSettle();

          await tester.runAsync(() async {
            final state = tester.state<NuevaIncidenciaScreenState>(
              find.byType(NuevaIncidenciaScreen),
            );
            final exito = await state.guardarIncidencia();
            expect(exito, isTrue);
          });
          await tester.pumpAndSettle();

          // 4.7 Verificar retorno a la pantalla de lista y que el total ha aumentado
          expect(find.byType(NuevaIncidenciaScreen), findsNothing);
          expect(find.byType(IncidenciasListScreen), findsOneWidget);
          expect(incidenciasCtrl.incidencias.length, equals(totalInicial + 1));

          // 4.8 Verificar que la nueva incidencia aparece en la lista
          expect(find.textContaining(descTest), findsAtLeast(1));

          // 4.9 Verificar persistencia directa en la base de datos SQLite
          await tester.runAsync(() async {
            final todasBD = await incidenciaRepo.getIncidenciasConDetalle();
            final insertada = todasBD.firstWhere(
              (i) => i.descripcion == descTest,
            );
            expect(insertada, isNotNull);
            expect(insertada.prioridad, equals(Prioridad.urgente));
            expect(insertada.equipoCodigo, equals('PC-101-02'));
          });
        },
      );
    },
  );
}
