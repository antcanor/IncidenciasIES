import 'package:flutter/material.dart';
import 'package:incidencias_ies/theme/theme.dart';
import 'package:incidencias_ui/incidencias_ui.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const WidgetbookCatalog());
}

class WidgetbookCatalog extends StatelessWidget {
  const WidgetbookCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      lightTheme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Claro', data: AppTheme.lightTheme),
            WidgetbookTheme(name: 'Oscuro', data: AppTheme.darkTheme),
          ],
          initialTheme: WidgetbookTheme(
            name: 'Claro',
            data: AppTheme.lightTheme,
          ),
        ),
      ],
      directories: [
        WidgetbookComponent(
          name: 'PriorityBadge',
          useCases: [
            for (final priority in Priority.values)
              WidgetbookUseCase(
                name: priority.label,
                builder: (context) => Center(
                  child: PriorityBadge(
                    priority: priority,
                    onChanged: (_) {},
                    semanticLabel: 'Prioridad ${priority.label}',
                    compact: false,
                  ),
                ),
              ),
          ],
        ),
        WidgetbookComponent(
          name: 'IncidentCard',
          useCases: [
            for (final priority in Priority.values)
              for (final showComment in [true, false])
                WidgetbookUseCase(
                  name:
                      '${priority.label} · ${showComment ? 'con comentario' : 'sin comentario'}',
                  builder: (context) => Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: IncidentCard(
                        incident: _incidentFor(priority),
                        onClose: (_) {},
                        onComment: (_) {},
                        showComment: showComment,
                        onPriorityChanged: (_) {},
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }
}

IncidentCardData _incidentFor(Priority priority) {
  final color = switch (priority) {
    Priority.low => Colors.blueGrey,
    Priority.medium => Colors.amber.shade800,
    Priority.high => Colors.deepOrange,
    Priority.urgent => Colors.red.shade700,
  };
  return IncidentCardData(
    id: priority.index + 1,
    title: 'Proyector sin imagen',
    details: 'Aula 204 · PROY-204-01',
    priority: priority,
    status: 'ABIERTA',
    priorityColor: color,
    statusColor: Colors.red.shade700,
  );
}
