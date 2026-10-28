import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class PanelScreen extends StatelessWidget {
  const PanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen General IES', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Selecciona un módulo o navega desde el menú lateral para gestionar las incidencias.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildNavigationCard(
              context: context,
              title: 'Gestión de Incidencias',
              subtitle: 'Ver averías activas, cerradas y registrar nuevas',
              icon: Icons.report_problem,
              color: colorScheme.primary,
              route: AppRoutes.incidencias,
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Aulas y Espacios',
              subtitle: 'Consultar aulas por planta y ver equipos asignados',
              icon: Icons.meeting_room,
              color: colorScheme.secondary,
              route: AppRoutes.aulas,
            ),
            const SizedBox(height: 12),
            _buildNavigationCard(
              context: context,
              title: 'Equipos e Inventario',
              subtitle: 'Equipos informáticos, proyectores y periféricos',
              icon: Icons.devices,
              color: colorScheme.tertiary,
              route: AppRoutes.equipos,
            ),
          ],
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 32),
                const SizedBox(height: 6),
                const Text(
                  'IncidenciasIES',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '10 Pantallas & Rutas MVC',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
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
