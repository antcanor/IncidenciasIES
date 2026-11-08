import 'package:flutter/material.dart';

import 'priority_badge.dart';

typedef IncidentCardCallback = void Function(IncidentCardData incident);

class IncidentCardData {
  final int id;
  final String title;
  final String details;
  final Priority priority;
  final String status;
  final Color priorityColor;
  final Color statusColor;

  const IncidentCardData({
    required this.id,
    required this.title,
    required this.details,
    required this.priority,
    required this.status,
    required this.priorityColor,
    required this.statusColor,
  });
}

class IncidentCard extends StatelessWidget {
  final IncidentCardData incident;
  final IncidentCardCallback onClose;
  final IncidentCardCallback onComment;
  final ValueChanged<Priority>? onPriorityChanged;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool showClose;
  final bool showComment;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onClose,
    required this.onComment,
    this.onPriorityChanged,
    this.onTap,
    this.leading,
    this.trailing,
    this.showClose = true,
    this.showComment = true,
  }) : assert(
         showClose || showComment,
         'IncidentCard debe ofrecer al menos una acción',
       );

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (showComment)
        IconButton(
          key: Key('btn_comentar_${incident.id}'),
          tooltip: 'Añadir comentario',
          onPressed: () => onComment(incident),
          icon: const Icon(Icons.comment_outlined),
        ),
      if (showClose)
        TextButton.icon(
          key: Key('btn_cerrar_${incident.id}'),
          onPressed: () => onClose(incident),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Cerrar'),
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading:
            leading ??
            CircleAvatar(
              backgroundColor: incident.priorityColor.withValues(alpha: 0.15),
              child: Icon(Icons.report_problem, color: incident.priorityColor),
            ),
        title: Text(
          key: Key('incident_card_title_${incident.id}'),
          incident.title,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident.details),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                onPriorityChanged == null
                    ? Chip(
                        label: Text(
                          incident.priority.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: incident.priorityColor,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      )
                    : PriorityBadge(
                        priority: incident.priority,
                        onChanged: onPriorityChanged!,
                        semanticLabel:
                            'Cambiar prioridad de incidencia ${incident.id}',
                      ),
                Chip(
                  label: Text(
                    incident.status,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: incident.statusColor,
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (actions.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(children: actions),
              ),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
