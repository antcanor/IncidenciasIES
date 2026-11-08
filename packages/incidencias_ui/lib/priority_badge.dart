import 'package:flutter/material.dart';

enum Priority {
  low('BAJA'),
  medium('MEDIA'),
  high('ALTA'),
  urgent('URGENTE');

  final String label;
  const Priority(this.label);
}

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final ValueChanged<Priority> onChanged;
  final String? semanticLabel;
  final bool compact;
  final bool enabled;

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
