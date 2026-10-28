import 'package:flutter/material.dart';
import '../controllers/incidencias_controller.dart';
import '../models/estado.dart';
import '../models/prioridad.dart';
import '../routes/app_routes.dart';
import '../theme/theme.dart';

/// =============================================================================
/// PANTALLA 1: PANEL DE CONTROL (DASHBOARD)
/// Tarjetas con los contadores por estado y por prioridad (consulta COUNT).
/// Acceso rápido a «Nueva incidencia».
/// Hecho cuando: los números coinciden con la BD y se actualizan al cambiar
/// una incidencia reactivamente mediante ListenableBuilder.
/// =============================================================================
class PanelScreen extends StatefulWidget {
  final IncidenciasController? controller;

  const PanelScreen({
    super.key,
    this.controller,
  });

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  late final IncidenciasController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = IncidenciasController();
      _ownsController = true;
    }

    if (_controller.incidencias.isEmpty) {
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    try {
      await _controller.loadIncidencias();
    } catch (_) {
      // En tests sin base de datos real
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _irANuevaIncidencia() async {
    final result = await Navigator.pushNamed(context, AppRoutes.nuevaIncidencia);
    if (result == true || mounted) {
      await _controller.loadIncidencias();
    }
  }

  Future<void> _cerrarIncidenciaRapida(int id) async {
    final ok = await _controller.cerrarIncidencia(id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidencia #$id cerrada. Métricas actualizadas.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incidenciasColors = theme.extension<IncidenciasColors>() ?? IncidenciasColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar métricas COUNT',
            onPressed: _controller.loadIncidencias,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('btn_nueva_incidencia_fab'),
        onPressed: _irANuevaIncidencia,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Nueva Incidencia'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final conteoEstado = _controller.conteoEstado;
          final conteoPrioridad = _controller.conteoPrioridad;
          final incidencias = _controller.incidencias;
          final total = _controller.totalIncidencias;

          return RefreshIndicator(
            onRefresh: _controller.loadIncidencias,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de Bienvenida y Acceso Rápido
                  Card(
                    elevation: 0,
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            child: const Icon(Icons.dashboard_outlined),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumen General IES',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$total incidencias registradas en la base de datos',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            key: const Key('btn_nueva_incidencia_banner'),
                            onPressed: _irANuevaIncidencia,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nueva'),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SECCIÓN 1: Tarjetas con Contadores por Estado (COUNT)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contadores por Estado (COUNT)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Base de Datos',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetricCard(
                        key: const Key('card_estado_abiertas'),
                        title: 'Abiertas',
                        count: conteoEstado[Estado.abierta] ?? 0,
                        accentColor: incidenciasColors.estadoAbierta,
                        icon: Icons.error_outline,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        key: const Key('card_estado_en_proceso'),
                        title: 'En Proceso',
                        count: conteoEstado[Estado.enProceso] ?? 0,
                        accentColor: incidenciasColors.estadoEnProceso,
                        icon: Icons.autorenew,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetricCard(
                        key: const Key('card_estado_resueltas'),
                        title: 'Resueltas',
                        count: conteoEstado[Estado.resuelta] ?? 0,
                        accentColor: incidenciasColors.estadoResuelta,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        key: const Key('card_estado_cerradas'),
                        title: 'Cerradas',
                        count: conteoEstado[Estado.cerrada] ?? 0,
                        accentColor: incidenciasColors.estadoCerrada,
                        icon: Icons.archive_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SECCIÓN 2: Tarjetas con Contadores por Prioridad (COUNT)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contadores por Prioridad (COUNT)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Niveles de Urgencia',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetricCard(
                        key: const Key('card_prioridad_urgente'),
                        title: 'Urgente',
                        count: conteoPrioridad[Prioridad.urgente] ?? 0,
                        accentColor: incidenciasColors.prioridadUrgente,
                        icon: Icons.priority_high,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        key: const Key('card_prioridad_alta'),
                        title: 'Alta',
                        count: conteoPrioridad[Prioridad.alta] ?? 0,
                        accentColor: incidenciasColors.prioridadAlta,
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMetricCard(
                        key: const Key('card_prioridad_media'),
                        title: 'Media',
                        count: conteoPrioridad[Prioridad.media] ?? 0,
                        accentColor: incidenciasColors.prioridadMedia,
                        icon: Icons.remove,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricCard(
                        key: const Key('card_prioridad_baja'),
                        title: 'Baja',
                        count: conteoPrioridad[Prioridad.baja] ?? 0,
                        accentColor: incidenciasColors.prioridadBaja,
                        icon: Icons.trending_down,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SECCIÓN 3: Gestión Rápida e Interactiva de Incidencias Activas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Incidencias Activas (Prueba de Cambio)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.incidencias),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (incidencias.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No hay incidencias registradas.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  else
                    ...incidencias.take(3).map((inc) {
                      final esCerrada = inc.estado == Estado.cerrada;
                      final colorPrioridad = incidenciasColors.colorParaPrioridad(inc.prioridad);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorPrioridad.withValues(alpha: 0.15),
                            child: Icon(Icons.report_problem, color: colorPrioridad, size: 20),
                          ),
                          title: Text(
                            '#${inc.id} ${inc.descripcion}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${inc.aulaNombre} • ${inc.equipoCodigo} (${inc.estado.value})',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: esCerrada
                              ? const Chip(
                                  label: Text('Cerrada', style: TextStyle(fontSize: 11)),
                                  visualDensity: VisualDensity.compact,
                                )
                              : TextButton.icon(
                                  key: Key('btn_cerrar_${inc.id}'),
                                  onPressed: () => _cerrarIncidenciaRapida(inc.id),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Cerrar'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.incidenciaDetalle,
                            arguments: inc.id,
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),

                  // Módulos de Acceso Rápido
                  Text('Módulos del Sistema', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _buildNavigationCard(
                    context: context,
                    title: 'Gestión de Incidencias',
                    subtitle: 'Ver averías activas, cerradas y registrar nuevas',
                    icon: Icons.report_problem,
                    color: colorScheme.primary,
                    route: AppRoutes.incidencias,
                  ),
                  const SizedBox(height: 8),
                  _buildNavigationCard(
                    context: context,
                    title: 'Aulas y Espacios',
                    subtitle: 'Consultar aulas por planta y ver equipos asignados',
                    icon: Icons.meeting_room,
                    color: colorScheme.secondary,
                    route: AppRoutes.aulas,
                  ),
                  const SizedBox(height: 8),
                  _buildNavigationCard(
                    context: context,
                    title: 'Equipos e Inventario',
                    subtitle: 'Equipos informáticos, proyectores y periféricos',
                    icon: Icons.devices,
                    color: colorScheme.tertiary,
                    route: AppRoutes.equipos,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    Key? key,
    required String title,
    required int count,
    required Color accentColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Card(
        key: key,
        color: colorScheme.surface,
        elevation: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.school, color: colorScheme.onPrimary, size: 32),
                const SizedBox(height: 6),
                Text(
                  'IncidenciasIES',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '10 Pantallas & Rutas MVC',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Panel de Control'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Incidencias'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.incidencias);
            },
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room),
            title: const Text('Aulas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.aulas);
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Equipos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.equipos);
            },
          ),
        ],
      ),
    );
  }
}
