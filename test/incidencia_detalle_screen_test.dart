import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/incidencias_controller.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/models/estado.dart';
import 'package:incidencias_ies/repositories/comentario_repository.dart';
import 'package:incidencias_ies/repositories/incidencia_repository.dart';
import 'package:incidencias_ies/routes/app_routes.dart';
import 'package:incidencias_ies/screens/incidencia_detalle_screen.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper dbHelper;
  late IncidenciaRepository incidenciaRepo;
  late ComentarioRepository comentarioRepo;
  late IncidenciasController incidenciasCtrl;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencia_detalle_screen_test.db');
    dbHelper = DatabaseHelper.instance;
    await dbHelper.database;
    await DatabaseSeeder(dbHelper).seedIfEmpty();

    incidenciaRepo = IncidenciaRepository(dbHelper);
    comentarioRepo = ComentarioRepository(dbHelper);
  });

  setUp(() async {
    // Asegurar que la incidencia 1 está en estado no cerrado para las pruebas
    final inc1 = await incidenciaRepo.getById(1);
    if (inc1 != null) {
      await incidenciaRepo.update(inc1.copyWith(estado: Estado.enProceso));
    }

    incidenciasCtrl = IncidenciasController(repository: incidenciaRepo);
    await incidenciasCtrl.loadIncidencias();
    AppRoutes.defaultIncidenciasController = incidenciasCtrl;
  });

  tearDownAll(() async {
    AppRoutes.defaultIncidenciasController = null;
    incidenciasCtrl.dispose();
    await dbHelper.close();
  });

  Widget buildTestDetalle({required int id}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: IncidenciaDetalleScreen(
        incidenciaId: id,
        incidenciasController: incidenciasCtrl,
        incidenciaRepository: incidenciaRepo,
        comentarioRepository: comentarioRepo,
      ),
    );
  }

  group('Pantalla 3: Detalle de incidencia con comentarios (MVC + SQLite)', () {
    testWidgets('1. Muestra datos de la incidencia, equipo y aula (JOIN doble) y comentarios existentes', (tester) async {
      await tester.pumpWidget(buildTestDetalle(id: 1));
      await tester.runAsync(() async {
        final state = tester.state<IncidenciaDetalleScreenState>(find.byType(IncidenciaDetalleScreen));
        await state.recargar();
      });
      await tester.pumpAndSettle();

      // 1. Cabecera y datos de la incidencia #1
      expect(find.text('Detalle Incidencia #1'), findsOneWidget);
      expect(find.byKey(const Key('card_ficha_tecnica')), findsOneWidget);

      // 2. Datos obtenidos del JOIN doble (Equipo y Aula)
      expect(find.textContaining('PC-101-01'), findsWidgets);
      expect(find.textContaining('Aula 101 - Informática'), findsWidgets);
      expect(find.textContaining('Planta 1'), findsWidgets);

      // 3. Comentarios de seguimiento iniciales (Seeder)
      expect(find.text('Comentarios de Seguimiento'), findsOneWidget);
      expect(
        find.textContaining('Revisada la fuente de alimentación; no llega corriente a la placa base.'),
        findsOneWidget,
      );

      // 4. Botones principales presentes
      expect(find.byKey(const Key('btn_anadir_comentario')), findsOneWidget);
      expect(find.byKey(const Key('btn_cerrar_incidencia')), findsOneWidget);
      expect(find.byKey(const Key('btn_volver_listado')), findsOneWidget);
    });

    testWidgets('2. Se puede añadir un comentario y este persiste en SQLite', (tester) async {
      await tester.pumpWidget(buildTestDetalle(id: 1));
      await tester.runAsync(() async {
        final state = tester.state<IncidenciaDetalleScreenState>(find.byType(IncidenciaDetalleScreen));
        await state.recargar();
      });
      await tester.pumpAndSettle();

      final comentariosAntes = await tester.runAsync(() => comentarioRepo.getByIncidencia(1)) ?? [];
      final conteoInicial = comentariosAntes.length;

      // 1. Abrir diálogo para añadir comentario
      await tester.tap(find.byKey(const Key('btn_anadir_comentario')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byKey(const Key('input_texto_comentario')), findsOneWidget);

      // 2. Escribir texto del comentario
      const nuevoTexto = 'Se ha reemplazado la fuente de alimentación. Equipo funcionando correctamente.';
      await tester.enterText(find.byKey(const Key('input_texto_comentario')), nuevoTexto);
      await tester.pumpAndSettle();

      // 3. Guardar comentario
      await tester.tap(find.byKey(const Key('btn_guardar_comentario_dialog')));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      // 4. Verificar que aparece en la UI
      expect(find.text(nuevoTexto), findsWidgets);

      // 5. Verificar persistencia real en la base de datos SQLite
      await tester.runAsync(() async {
        final enBD = await comentarioRepo.getByIncidencia(1);
        expect(enBD.length, equals(conteoInicial + 1));
        expect(enBD.any((c) => c.texto == nuevoTexto), isTrue);
      });
    });

    testWidgets('3. Se puede cerrar la incidencia y el nuevo estado persiste en SQLite', (tester) async {
      await tester.pumpWidget(buildTestDetalle(id: 1));
      await tester.runAsync(() async {
        final state = tester.state<IncidenciaDetalleScreenState>(find.byType(IncidenciaDetalleScreen));
        await state.recargar();
      });
      await tester.pumpAndSettle();

      // 1. Pulsar botón de cerrar incidencia
      expect(find.byKey(const Key('btn_cerrar_incidencia')), findsOneWidget);
      await tester.tap(find.byKey(const Key('btn_cerrar_incidencia')));
      await tester.pumpAndSettle();

      // 2. Verificar diálogo de confirmación y ejecutar cierre
      expect(find.text('Confirmar Cierre de Incidencia'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final state = tester.state<IncidenciaDetalleScreenState>(find.byType(IncidenciaDetalleScreen));
        await state.cerrarIncidenciaDirecto();
      });
      await tester.pumpAndSettle();

      // 3. Verificar que la UI muestra el estado "CERRADA" y el botón de estado cerrado
      expect(find.textContaining('CERRADA'), findsWidgets);
      expect(find.byKey(const Key('btn_incidencia_ya_cerrada')), findsOneWidget);

      // 4. Verificar persistencia real en SQLite mediante el repositorio
      await tester.runAsync(() async {
        final incidenciaBD = await incidenciaRepo.getById(1);
        expect(incidenciaBD, isNotNull);
        expect(incidenciaBD!.estado, equals(Estado.cerrada));
      });
    });
  });
}
