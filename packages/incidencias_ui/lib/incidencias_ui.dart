/// Punto de entrada del paquete de componentes compartidos de incidencias.
///
/// Desde este archivo se exportan [PriorityBadge], [IncidentCard] y sus tipos
/// relacionados. También incluye una etiqueta pequeña para identificar una
/// maqueta de realidad aumentada:
///
/// ```dart
/// const MaquetaArBadge()
/// ```
///
/// La aplicación principal puede importar todo el paquete con:
///
/// ```dart
/// import 'package:incidencias_ui/incidencias_ui.dart';
/// ```
library;

import 'package:flutter/material.dart';

export 'priority_badge.dart';
export 'incident_card.dart';

/// Etiqueta reutilizable para identificar una vista AR simulada.
///
/// Se usa en prototipos para dejar claro que la vista de realidad aumentada
/// todavía es una maqueta y no una lectura real de la cámara.
class MaquetaArBadge extends StatelessWidget {
  /// Crea la etiqueta de maqueta AR.
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
