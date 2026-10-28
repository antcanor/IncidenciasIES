import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/controllers/controllers.dart';
import 'package:incidencias_ies/database/database_helper.dart';
import 'package:incidencias_ies/database/database_seeder.dart';
import 'package:incidencias_ies/main.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setDatabaseNameForTesting('incidencias_theme_test.db');

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'incidencias_theme_test.db');
    await databaseFactory.deleteDatabase(path);

    await DatabaseSeeder().seedIfEmpty();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  group('1. ThemeController y AppTheme Material 3', () {
    test('ThemeController alterna entre claro y oscuro notificando a los oyentes', () {
      final controller = ThemeController(initialMode: ThemeMode.light);
      int notificaciones = 0;
      controller.addListener(() => notificaciones++);

      expect(controller.themeMode, equals(ThemeMode.light));
      expect(controller.isDarkMode, isFalse);

      controller.toggleTheme();
      expect(controller.themeMode, equals(ThemeMode.dark));
      expect(controller.isDarkMode, isTrue);
      expect(notificaciones, equals(1));

      controller.toggleTheme();
      expect(controller.themeMode, equals(ThemeMode.light));
      expect(controller.isDarkMode, isFalse);
      expect(notificaciones, equals(2));

      controller.dispose();
    });

    test('AppTheme cumple especificaciones Material 3 con ColorScheme propio y tipografía', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);

      expect(light.colorScheme.brightness, equals(Brightness.light));
      expect(dark.colorScheme.brightness, equals(Brightness.dark));

      // ColorScheme institucional propio
      expect(light.colorScheme.primary, equals(const Color(0xFF1E3A8A)));
      expect(dark.colorScheme.primary, equals(const Color(0xFF93C5FD)));

      // Tipografía coherente (RA1.d)
      expect(light.textTheme.titleLarge?.fontWeight, equals(FontWeight.bold));
      expect(dark.textTheme.titleLarge?.fontWeight, equals(FontWeight.bold));

      // Extensión IncidenciasColors presente en ambos temas
      final lightColors = light.extension<IncidenciasColors>();
      final darkColors = dark.extension<IncidenciasColors>();

      expect(lightColors, isNotNull);
      expect(darkColors, isNotNull);

      // Verificación de contraste semántico sin colores sueltos
      expect(lightColors!.colorParaPrioridad(Prioridad.urgente), isNot(equals(darkColors!.colorParaPrioridad(Prioridad.urgente))));
      expect(lightColors.colorParaEstado(Estado.resuelta), isNot(equals(darkColors.colorParaEstado(Estado.resuelta))));
    });
  });

  group('2. Interfaz reactiva al cambio de tema (Widget Test)', () {
    testWidgets('Pulsar el botón de tema alterna entre claro y oscuro dinámicamente', (WidgetTester tester) async {
      final themeCtrl = ThemeController(initialMode: ThemeMode.light);
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
        themeController: themeCtrl,
        incidenciasCtrl: incidenciasCtrl,
        aulasCtrl: aulasCtrl,
        equiposCtrl: equiposCtrl,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final toggleButton = find.byKey(const Key('theme_toggle_button'));
      expect(toggleButton, findsOneWidget);

      // En modo claro debe mostrar el icono para pasar a oscuro
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(themeCtrl.isDarkMode, isFalse);

      // Pulsar botón para cambiar a modo oscuro
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Debe haber cambiado el estado y ahora mostrar icono de sol (light_mode)
      expect(themeCtrl.isDarkMode, isTrue);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      // Pulsar de nuevo para volver a modo claro
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(themeCtrl.isDarkMode, isFalse);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      themeCtrl.dispose();
      incidenciasCtrl.dispose();
      aulasCtrl.dispose();
      equiposCtrl.dispose();
    });
  });
}
