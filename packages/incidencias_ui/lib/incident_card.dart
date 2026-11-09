import 'package:flutter/material.dart';

import 'priority_badge.dart';

/// Callback que recibe los datos de la incidencia afectada por una acción.
///
/// Por ejemplo, se puede usar para cerrar la incidencia:
///
/// ```dart
/// IncidentCardCallback cerrar = (incident) {
///   print('Cerrando ${incident.id}');
/// };
/// ```
typedef IncidentCardCallback = void Function(IncidentCardData incident);

/// Datos necesarios para pintar una [IncidentCard].
///
/// Los colores se reciben desde fuera para que la aplicación pueda aplicar su
/// propio tema o sus colores corporativos.
class IncidentCardData {
  /// Identificador de la incidencia.
  final int id;

  /// Título breve que aparece en la tarjeta.
  final String title;

  /// Información secundaria, como el aula y el código del equipo.
  final String details;

  /// Prioridad actual de la incidencia.
  final Priority priority;

  /// Estado que se muestra junto a la prioridad.
  final String status;

  /// Color de la etiqueta de prioridad y del icono principal.
  final Color priorityColor;

  /// Color de la etiqueta del estado.
  final Color statusColor;

  /// Crea los datos visuales de una incidencia.
  ///
  /// ```dart
  /// const data = IncidentCardData(
  ///   id: 12,
  ///   title: 'Monitor sin señal',
  ///   details: 'Aula 101 · PC-101-02',
  ///   priority: Priority.medium,
  ///   status: 'ABIERTA',
  ///   priorityColor: Colors.amber,
  ///   statusColor: Colors.red,
  /// );
  /// ```
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

/// Tarjeta reutilizable para mostrar una incidencia y sus acciones principales.
///
/// La tarjeta puede mostrar botones para comentar y cerrar, y opcionalmente
/// permite cambiar la prioridad con [PriorityBadge]. Ejemplo:
///
/// ```dart
/// IncidentCard(
///   incident: data,
///   onClose: (incident) => cerrarIncidencia(incident.id),
///   onComment: (incident) => abrirComentarios(incident.id),
///   showComment: true,
/// )
/// ```
class IncidentCard extends StatelessWidget {
  /// Datos de la incidencia que se va a mostrar.
  final IncidentCardData incident;

  /// Acción que se ejecuta al pulsar «Cerrar».
  final IncidentCardCallback onClose;

  /// Acción que se ejecuta al pulsar el botón de comentario.
  final IncidentCardCallback onComment;

  /// Callback opcional para activar el cambio de prioridad.
  ///
  /// Si es `null`, la prioridad se muestra como una etiqueta fija.
  final ValueChanged<Priority>? onPriorityChanged;

  /// Acción opcional al pulsar el cuerpo de la tarjeta.
  final VoidCallback? onTap;

  /// Widget opcional que sustituye al icono de incidencia de la izquierda.
  final Widget? leading;

  /// Widget opcional que aparece al final de la tarjeta.
  final Widget? trailing;

  /// Indica si se muestra la acción para cerrar.
  final bool showClose;

  /// Indica si se muestra la acción para añadir comentarios.
  final bool showComment;

  /// Crea una tarjeta de incidencia.
  ///
  /// Debe quedar al menos una acción visible: [showClose] o [showComment].
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
