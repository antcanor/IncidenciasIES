import 'package:flutter/material.dart';
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
        return MaterialPageRoute(
          builder: (_) => const PanelScreen(),
          settings: settings,
        );

      case incidencias:
        return MaterialPageRoute(
          builder: (_) => const IncidenciasListScreen(),
          settings: settings,
        );

      case incidenciaDetalle:
        final int id = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute(
          builder: (_) => IncidenciaDetalleScreen(incidenciaId: id),
          settings: settings,
        );

      case nuevaIncidencia:
        final int? eqId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => NuevaIncidenciaScreen(equipoId: eqId),
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
