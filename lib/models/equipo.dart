class Equipo {
  final int? id;
  final int aulaId;
  final String tipo;
  final String codigo;

  const Equipo({
    this.id,
    required this.aulaId,
    required this.tipo,
    required this.codigo,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'aula_id': aulaId,
      'tipo': tipo,
      'codigo': codigo,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] as int?,
      aulaId: (map['aula_id'] ?? map['aulaId']) as int,
      tipo: map['tipo'] as String,
      codigo: map['codigo'] as String,
    );
  }

  Equipo copyWith({
    int? id,
    int? aulaId,
    String? tipo,
    String? codigo,
  }) {
    return Equipo(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      tipo: tipo ?? this.tipo,
      codigo: codigo ?? this.codigo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipo &&
        other.id == id &&
        other.aulaId == aulaId &&
        other.tipo == tipo &&
        other.codigo == codigo;
  }

  @override
  int get hashCode => Object.hash(id, aulaId, tipo, codigo);

  @override
  String toString() =>
      'Equipo(id: $id, aulaId: $aulaId, tipo: $tipo, codigo: $codigo)';
}
