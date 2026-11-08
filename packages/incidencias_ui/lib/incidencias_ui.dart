import 'package:flutter/material.dart';

export 'priority_badge.dart';

/// Etiqueta reutilizable para identificar una vista AR simulada.
class MaquetaArBadge extends StatelessWidget {
  const MaquetaArBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'UI compartida · maqueta AR',
          style: TextStyle(color: Colors.cyanAccent),
        ),
      ),
    );
  }
}
