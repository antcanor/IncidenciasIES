import 'estado.dart';
import 'prioridad.dart';

/// DTO / Modelo que representa una Incidencia enriquecida con datos
/// del Equipo y del Aula obtenidos mediante JOIN doble:
/// incidencia (i) -> equipo (e) -> aula (a).
class IncidenciaDetalle {
  final int id;
  final int equipoId;
  final String descripcion;
  final Prioridad prioridad;
  final Estado estado;
  final DateTime fecha;

  // Datos del Equipo
  final String equipoTipo;
  final String equipoCodigo;

  // Datos del Aula
  final int aulaId;
  final String aulaNombre;
  final int aulaPlanta;

  const IncidenciaDetalle({
    required this.id,
    required this.equipoId,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    required this.fecha,
    required this.equipoTipo,
    required this.equipoCodigo,
    required this.aulaId,
    required this.aulaNombre,
    required this.aulaPlanta,
  });

  factory IncidenciaDetalle.fromMap(Map<String, dynamic> map) {
    return IncidenciaDetalle(
      id: map['id'] as int,
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
      equipoTipo: (map['equipo_tipo'] ?? map['equipoTipo']) as String,
      equipoCodigo: (map['equipo_codigo'] ?? map['equipoCodigo']) as String,
      aulaId: (map['aula_id'] ?? map['aulaId']) as int,
      aulaNombre: (map['aula_nombre'] ?? map['aulaNombre']) as String,
      aulaPlanta: (map['aula_planta'] ?? map['aulaPlanta']) as int,
    );
  }

  IncidenciaDetalle copyWith({
    int? id,
    int? equipoId,
    String? descripcion,
    Prioridad? prioridad,
    Estado? estado,
    DateTime? fecha,
    String? equipoTipo,
    String? equipoCodigo,
    int? aulaId,
    String? aulaNombre,
    int? aulaPlanta,
  }) {
    return IncidenciaDetalle(
      id: id ?? this.id,
      equipoId: equipoId ?? this.equipoId,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      equipoTipo: equipoTipo ?? this.equipoTipo,
      equipoCodigo: equipoCodigo ?? this.equipoCodigo,
      aulaId: aulaId ?? this.aulaId,
      aulaNombre: aulaNombre ?? this.aulaNombre,
      aulaPlanta: aulaPlanta ?? this.aulaPlanta,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipo_id': equipoId,
      'descripcion': descripcion,
      'prioridad': prioridad.value,
      'estado': estado.value,
      'fecha': fecha.toIso8601String(),
      'equipo_tipo': equipoTipo,
      'equipo_codigo': equipoCodigo,
      'aula_id': aulaId,
      'aula_nombre': aulaNombre,
      'aula_planta': aulaPlanta,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncidenciaDetalle &&
        other.id == id &&
        other.equipoId == equipoId &&
        other.descripcion == descripcion &&
        other.prioridad == prioridad &&
        other.estado == estado &&
        other.equipoCodigo == equipoCodigo &&
        other.aulaId == aulaId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        equipoId,
        descripcion,
        prioridad,
        estado,
        equipoCodigo,
        aulaId,
      );

  @override
  String toString() =>
      'IncidenciaDetalle(id: $id, aula: $aulaNombre (P$aulaPlanta), equipo: $equipoCodigo ($equipoTipo), prioridad: ${prioridad.value}, estado: ${estado.value})';
}
