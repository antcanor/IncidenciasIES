import 'estado.dart';
import 'prioridad.dart';

class Incidencia {
  final int? id;
  final int equipoId;
  final String descripcion;
  final Prioridad prioridad;
  final Estado estado;
  final DateTime fecha;

  const Incidencia({
    this.id,
    required this.equipoId,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    required this.fecha,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'equipo_id': equipoId,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'estado': estado.value,
      'fecha': fecha.toIso8601String(),
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Incidencia.fromMap(Map<String, dynamic> map) {
    return Incidencia(
      id: map['id'] as int?,
      equipoId: (map['equipo_id'] ?? map['equipoId']) as int,
      descripcion: map['descripcion'] as String,
      prioridad: map['prioridad'] is Prioridad
          ? map['prioridad'] as Prioridad
          : Prioridad.fromString(map['prioridad'] as String),
      estado: map['estado'] is Estado
          ? map['estado'] as Estado
          : Estado.fromString(map['estado'] as String),
      fecha: map['fecha'] is DateTime
          ? map['fecha'] as DateTime
          : DateTime.parse(map['fecha'] as String),
    );
  }

  Incidencia copyWith({
    int? id,
    int? equipoId,
    String? descripcion,
    Prioridad? prioridad,
    Estado? estado,
    DateTime? fecha,
  }) {
    return Incidencia(
      id: id ?? this.id,
      equipoId: equipoId ?? this.equipoId,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Incidencia &&
        other.id == id &&
        other.equipoId == equipoId &&
        other.descripcion == descripcion &&
        other.prioridad == prioridad &&
        other.estado == estado &&
        other.fecha.isAtSameMomentAs(fecha);
  }

  @override
  int get hashCode =>
      Object.hash(id, equipoId, descripcion, prioridad, estado, fecha);

  @override
  String toString() =>
      'Incidencia(id: $id, equipoId: $equipoId, descripcion: $descripcion, prioridad: ${prioridad.value}, estado: ${estado.value}, fecha: $fecha)';
}
