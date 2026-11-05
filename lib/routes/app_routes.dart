import 'package:flutter/material.dart';
import '../controllers/controllers.dart';
import '../screens/screens.dart';

class AppRoutes {
  // Rutas de las 10 pantallas
  static const String panel = '/';
  static const String incidencias = '/incidencias';
  static const String incidenciaDetalle = '/incidencias/detalle';
  static const String nuevaIncidencia = '/incidencias/nueva';
  static const String aulas = '/aulas';
  static const String aulaDetalle = '/aulas/detalle';
  static const String nuevaAula = '/aulas/nueva';
  static const String equipos = '/equipos';
  static const String equipoDetalle = '/equipos/detalle';
  static const String nuevoEquipo = '/equipos/nuevo';

  static IncidenciasController? defaultIncidenciasController;
  static AulasController? defaultAulasController;
  static EquiposController? defaultEquiposController;

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
        final ctrl = (settings.arguments as IncidenciasController?) ?? defaultIncidenciasController;
        return MaterialPageRoute(
          builder: (_) => PanelScreen(controller: ctrl),
          settings: settings,
        );

      case incidencias:
        final ctrl = (settings.arguments as IncidenciasController?) ?? defaultIncidenciasController;
        return MaterialPageRoute(
          builder: (_) => IncidenciasListScreen(controller: ctrl),
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
          ),
          settings: settings,
        );

      case aulas:
        return MaterialPageRoute(
          builder: (_) => const AulasListScreen(),
          settings: settings,
        );

      case aulaDetalle:
        final int id = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          builder: (_) => AulaDetalleScreen(aulaId: id),
          settings: settings,
        );

      case nuevaAula:
        return MaterialPageRoute(
          builder: (_) => const NuevaAulaScreen(),
          settings: settings,
        );

      case equipos:
        return MaterialPageRoute(
          builder: (_) => const EquiposListScreen(),
          settings: settings,
        );

      case equipoDetalle:
        final int id = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          builder: (_) => EquipoDetalleScreen(equipoId: id),
          settings: settings,
        );

      case nuevoEquipo:
        final int? aulaId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => NuevoEquipoScreen(aulaId: aulaId),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Ruta no encontrada')),
            body: Center(
              child: Text('No existe la ruta: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
