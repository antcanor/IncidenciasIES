class Comentario {
  final int? id;
  final int incidenciaId;
  final DateTime fecha;
  final String texto;

  const Comentario({
    this.id,
    required this.incidenciaId,
    required this.fecha,
    required this.texto,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'incidencia_id': incidenciaId,
      'fecha': fecha.toIso8601String(),
      'texto': texto,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'] as int?,
      incidenciaId: (map['incidencia_id'] ?? map['incidenciaId']) as int,
      fecha: map['fecha'] is DateTime
          ? map['fecha'] as DateTime
          : DateTime.parse(map['fecha'] as String),
      texto: map['texto'] as String,
    );
  }

  Comentario copyWith({
    int? id,
    int? incidenciaId,
    DateTime? fecha,
    String? texto,
  }) {
    return Comentario(
      id: id ?? this.id,
      incidenciaId: incidenciaId ?? this.incidenciaId,
      fecha: fecha ?? this.fecha,
      texto: texto ?? this.texto,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comentario &&
        other.id == id &&
        other.incidenciaId == incidenciaId &&
        other.fecha.isAtSameMomentAs(fecha) &&
        other.texto == texto;
  }

  @override
  int get hashCode => Object.hash(id, incidenciaId, fecha, texto);

  @override
  String toString() =>
      'Comentario(id: $id, incidenciaId: $incidenciaId, fecha: $fecha, texto: $texto)';
}
