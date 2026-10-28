import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/main.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_mvc_test.db');

    // Limpiar BD para entorno de prueba aislado
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'incidencias_mvc_test.db');
    await databaseFactory.deleteDatabase(path);

    // Cargar datos de ejemplo iniciales (16 filas)
    await DatabaseSeeder().seedIfEmpty();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  group('1. Controladores ChangeNotifier (MVC)', () {
    test('IncidenciasController notifica al crear y al cerrar incidencias', () async {
      final ctrl = IncidenciasController();
      int notificaciones = 0;
      ctrl.addListener(() {
        notificaciones++;
      });

      // 1. Cargar incidencias iniciales
      await ctrl.loadIncidencias();
      expect(ctrl.incidencias.length, equals(4));
      expect(notificaciones, greaterThan(0));

      // 2. Crear una nueva incidencia
      final nueva = Incidencia(
        equipoId: 1,
        descripcion: 'Fallo de alimentación repentino en test MVC',
        prioridad: Prioridad.alta,
        estado: Estado.abierta,
        fecha: DateTime.now(),
      );

      final notificacionesAntesCrear = notificaciones;
      final creada = await ctrl.createIncidencia(nueva);
      expect(creada, isNotNull);
      expect(ctrl.incidencias.length, equals(5));
      expect(notificaciones, greaterThan(notificacionesAntesCrear));

      // 3. Cerrar la incidencia recién creada
      final notificacionesAntesCerrar = notificaciones;
      final exito = await ctrl.cerrarIncidencia(creada!.id!);
      expect(exito, isTrue);
      expect(notificaciones, greaterThan(notificacionesAntesCerrar));

      // Comprobar que en la lista en memoria el estado es CERRADA
      final cerradaEnLista = ctrl.incidencias.firstWhere((i) => i.id == creada.id);
      expect(cerradaEnLista.estado, equals(Estado.cerrada));
      expect(ctrl.conteoEstado[Estado.cerrada], greaterThanOrEqualTo(1));

      ctrl.dispose();
    });

    test('AulasController y EquiposController gestionan estado reactivo', () async {
      final aulasCtrl = AulasController();
      final equiposCtrl = EquiposController();

      await aulasCtrl.loadAulas();
      await equiposCtrl.loadEquipos();

      expect(aulasCtrl.aulas.length, equals(3));
      expect(equiposCtrl.equipos.length, equals(5));

      // Crear aula
      int notifyAulas = 0;
      aulasCtrl.addListener(() => notifyAulas++);
      final nuevaAula = await aulasCtrl.createAula(const Aula(nombre: 'Aula MVC Test', planta: 1));
      expect(nuevaAula, isNotNull);
      expect(aulasCtrl.aulas.length, equals(4));
      expect(notifyAulas, greaterThan(0));

      aulasCtrl.dispose();
      equiposCtrl.dispose();
    });
  });

  group('2. Vistas con ListenableBuilder (Actualización reactiva sin recargar pantalla)', () {
    testWidgets('Crear y cerrar incidencia refresca la lista automáticamente en la vista', (WidgetTester tester) async {
      final incidenciasCtrl = IncidenciasController();
      final aulasCtrl = AulasController();
      final equiposCtrl = EquiposController();

      await tester.runAsync(() async {
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
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Cambiar a la pestaña de Incidencias (JOIN)
      final tabIncidencias = find.text('Incidencias (JOIN)');
      expect(tabIncidencias, findsOneWidget);
      await tester.tap(tabIncidencias);
      await tester.pumpAndSettle();

      // Crear incidencia desde el controlador para verificar que ListenableBuilder refresca la vista
      await tester.runAsync(() async {
        await incidenciasCtrl.createIncidencia(Incidencia(
          equipoId: 1,
          descripcion: 'Incidencia creada con ChangeNotifier MVC',
          prioridad: Prioridad.alta,
          estado: Estado.abierta,
          fecha: DateTime.now(),
        ));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // La nueva incidencia aparece reactivamente en la lista sin recargar pantalla
      expect(find.textContaining('Incidencia creada con ChangeNotifier MVC'), findsOneWidget);

      // Cerrar incidencia llamando a cerrarIncidencia en el controlador (o pulsando Cerrar)
      final idNueva = incidenciasCtrl.incidencias.firstWhere(
        (i) => i.descripcion.contains('ChangeNotifier MVC'),
      ).id;

      await tester.runAsync(() async {
        await incidenciasCtrl.cerrarIncidencia(idNueva);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Comprobar que el chip 'CERRADA' se renderizó inmediatamente sin recargar la pantalla
      expect(find.text('CERRADA'), findsAtLeast(1));

      incidenciasCtrl.dispose();
      aulasCtrl.dispose();
      equiposCtrl.dispose();
    });
  });
}
