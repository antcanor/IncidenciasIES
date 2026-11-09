import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../settings/settings.dart';
import '../theme/theme_controller.dart';

class AppRoutes {
  // Rutas de las 10 pantallas
  static const String panel = '/';
  static const String incidencias = '/incidencias';
  static const String historial = '/historial';
  static const String incidenciaDetalle = '/incidencias/detalle';
  static const String nuevaIncidencia = '/incidencias/nueva';
  static const String aulas = '/aulas';
  static const String aulaDetalle = '/aulas/detalle';
  static const String nuevaAula = '/aulas/nueva';
  static const String equipos = '/equipos';
  static const String equipoDetalle = '/equipos/detalle';
  static const String nuevoEquipo = '/equipos/nuevo';
  static const String ajustes = '/ajustes';
  static const String arView = '/ar';
  static const String gestureCamera = '/camara-gesto';

  static IncidenciasController? defaultIncidenciasController;
  static AulasController? defaultAulasController;
  static EquiposController? defaultEquiposController;
  static bool enableShakeDetection = true;

  static final List<String> allRoutes = [
    panel,
    incidencias,
    incidenciaDetalle,
    nuevaIncidencia,
    aulas,
    aulaDetalle,
    nuevaAula,
    equipos,
    equipoDetalle,
    nuevoEquipo,
  ];

  /// Generador de rutas con gestión de argumentos
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case panel:
        final ctrl =
            (settings.arguments as IncidenciasController?) ??
            defaultIncidenciasController;
        return MaterialPageRoute(
          builder: (_) => PanelScreen(controller: ctrl),
          settings: settings,
        );

      case incidencias:
        final ctrl =
            (settings.arguments as IncidenciasController?) ??
            defaultIncidenciasController;
        return MaterialPageRoute(
          builder: (_) => IncidenciasListScreen(controller: ctrl),
          settings: settings,
        );

      case historial:
        final controller = settings.arguments is IncidenciasController
            ? settings.arguments as IncidenciasController
            : defaultIncidenciasController;
        return MaterialPageRoute(
          builder: (_) => HistorialScreen(controller: controller),
          settings: settings,
        );

      case ajustes:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AjustesScreen(
            themeController:
                args?['themeController'] as ThemeController? ??
                ThemeController(),
            localeController:
                args?['localeController'] as LocaleController? ??
                LocaleController(),
          ),
          settings: settings,
        );

      case arView:
        final args = settings.arguments as Map<String, dynamic>?;
        final equipoId = args?['equipoId'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => ArViewScreen(
            equipoId: equipoId,
            equipoLabel: args?['equipoLabel'] as String?,
          ),
          settings: settings,
        );

      case gestureCamera:
        return MaterialPageRoute(
          builder: (_) => const GestureCameraScreen(),
          settings: settings,
        );

      case incidenciaDetalle:
        final int id = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          builder: (_) => IncidenciaDetalleScreen(
            incidenciaId: id,
            incidenciasController: defaultIncidenciasController,
          ),
          settings: settings,
        );

      case nuevaIncidencia:
        int? eqId;
        IncidenciasController? incCtrl;
        AulasController? aCtrl;
        EquiposController? eqCtrl;

        if (settings.arguments is int) {
          eqId = settings.arguments as int;
        } else if (settings.arguments is IncidenciasController) {
          incCtrl = settings.arguments as IncidenciasController;
        } else if (settings.arguments is Map<String, dynamic>) {
          final map = settings.arguments as Map<String, dynamic>;
          eqId = map['equipoId'] as int?;
          incCtrl = map['incidenciasCtrl'] as IncidenciasController?;
          aCtrl = map['aulasCtrl'] as AulasController?;
          eqCtrl = map['equiposCtrl'] as EquiposController?;
        }

        return MaterialPageRoute(
          builder: (_) => NuevaIncidenciaScreen(
            equipoId: eqId,
            incidenciasCtrl: incCtrl ?? defaultIncidenciasController,
            aulasCtrl: aCtrl ?? defaultAulasController,
            equiposCtrl: eqCtrl ?? defaultEquiposController,
            enableShakeDetection: enableShakeDetection,
          ),
          settings: settings,
        );

      case aulas:
        return MaterialPageRoute(
          builder: (_) => AulasListScreen(controller: defaultAulasController),
          settings: settings,
        );

      case aulaDetalle:
        final args = settings.arguments;
        final aula = args is Map<String, dynamic>
            ? args['aula'] as Aula?
            : null;
        final int id =
            aula?.id ??
            (args is Map<String, dynamic>
                ? args['aulaId'] as int?
                : args as int?) ??
            1;
        final aulasCtrl = args is Map<String, dynamic>
            ? args['aulasCtrl'] as AulasController?
            : defaultAulasController;
        final equiposCtrl = args is Map<String, dynamic>
            ? args['equiposCtrl'] as EquiposController?
            : defaultEquiposController;
        return MaterialPageRoute(
          builder: (_) => AulaDetalleScreen(
            aulaId: id,
            aula: aula,
            aulasController: aulasCtrl,
            equiposController: equiposCtrl,
          ),
          settings: settings,
        );

      case nuevaAula:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => NuevaAulaScreen(
            aula: args is Map<String, dynamic> ? args['aula'] as Aula? : null,
            controller: args is Map<String, dynamic>
                ? args['aulasCtrl'] as AulasController?
                : defaultAulasController,
          ),
          settings: settings,
        );

      case equipos:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => EquiposListScreen(
            controller: args is Map<String, dynamic>
                ? args['equiposCtrl'] as EquiposController?
                : defaultEquiposController,
            aulaId: args is Map<String, dynamic>
                ? args['aulaId'] as int?
                : null,
          ),
          settings: settings,
        );

      case equipoDetalle:
        final args = settings.arguments;
        final equipo = args is Map<String, dynamic>
            ? args['equipo'] as Equipo?
            : null;
        final int id =
            equipo?.id ??
            (args is Map<String, dynamic>
                ? args['equipoId'] as int?
                : args as int?) ??
            1;
        return MaterialPageRoute(
          builder: (_) => EquipoDetalleScreen(
            equipoId: id,
            equipo: equipo,
            equiposController: args is Map<String, dynamic>
                ? args['equiposCtrl'] as EquiposController?
                : defaultEquiposController,
          ),
          settings: settings,
        );

      case nuevoEquipo:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => NuevoEquipoScreen(
            aulaId: args is Map<String, dynamic>
                ? args['aulaId'] as int?
                : args as int?,
            equipo: args is Map<String, dynamic>
                ? args['equipo'] as Equipo?
                : null,
            controller: args is Map<String, dynamic>
                ? args['equiposCtrl'] as EquiposController?
                : defaultEquiposController,
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Ruta no encontrada')),
            body: Center(child: Text('No existe la ruta: ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
