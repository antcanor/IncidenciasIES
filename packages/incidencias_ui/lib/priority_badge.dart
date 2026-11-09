import 'package:flutter/material.dart';

/// Prioridades disponibles para una incidencia.
///
/// El texto de cada valor está pensado para mostrarse directamente en la
/// interfaz:
///
/// ```dart
/// Text(Priority.urgent.label); // URGENTE
/// ```
enum Priority {
  /// Incidencia con impacto bajo.
  low('BAJA'),

  /// Incidencia que requiere una atención normal.
  medium('MEDIA'),

  /// Incidencia importante que conviene atender pronto.
  high('ALTA'),

  /// Incidencia crítica o que deja el equipo inutilizado.
  urgent('URGENTE');

  /// Texto corto que se enseña en la etiqueta.
  final String label;

  const Priority(this.label);
}

/// Etiqueta de color que muestra y permite cambiar una [Priority].
///
/// Al pulsar la etiqueta se abre un menú con las cuatro prioridades. Por
/// ejemplo:
///
/// ```dart
/// PriorityBadge(
///   priority: Priority.high,
///   onChanged: (priority) {
///     // Guardar la nueva prioridad de la incidencia.
///   },
/// )
/// ```
class PriorityBadge extends StatelessWidget {
  /// Prioridad que se está mostrando.
  final Priority priority;

  /// Función que recibe la prioridad elegida en el menú.
  final ValueChanged<Priority> onChanged;

  /// Texto accesible para lectores de pantalla.
  ///
  /// Si no se indica, se genera uno a partir de [priority].
  final String? semanticLabel;

  /// Decide si la etiqueta usa el tamaño compacto.
  ///
  /// Por defecto es `true`, que es lo habitual cuando se muestra dentro de
  /// una tarjeta.
  final bool compact;

  /// Indica si el menú se puede abrir.
  ///
  /// Cuando es `false`, la prioridad sigue visible pero no se puede cambiar.
  final bool enabled;

  /// Crea una etiqueta de prioridad.
  const PriorityBadge({
    super.key,
    required this.priority,
    required this.onChanged,
    this.semanticLabel,
    this.compact = true,
    this.enabled = true,
  }) : assert(
         semanticLabel == null || semanticLabel != '',
         'semanticLabel no puede estar vacío',
       );

  Color _color(BuildContext context) {
    switch (priority) {
      case Priority.low:
        return Colors.blueGrey;
      case Priority.medium:
        return Colors.amber.shade800;
      case Priority.high:
        return Colors.deepOrange;
      case Priority.urgent:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final label = semanticLabel ?? 'Prioridad ${priority.label}';
    return Semantics(
      button: enabled,
      label: label,
      child: PopupMenuButton<Priority>(
        enabled: enabled,
        tooltip: 'Cambiar prioridad',
        onSelected: onChanged,
        itemBuilder: (context) => Priority.values
            .map(
              (option) => PopupMenuItem<Priority>(
                value: option,
                child: Text(option.label),
              ),
            )
            .toList(),
        child: Chip(
          label: Text(
            priority.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color,
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
