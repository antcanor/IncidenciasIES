class Aula {
  final int? id;
  final String nombre;
  final int planta;

  const Aula({
    this.id,
    required this.nombre,
    required this.planta,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = <String, dynamic>{
      'nombre': nombre,
      'planta': planta,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Aula.fromMap(Map<String, dynamic> map) {
    return Aula(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      planta: map['planta'] as int,
    );
  }

  Aula copyWith({
    int? id,
    String? nombre,
    int? planta,
  }) {
    return Aula(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      planta: planta ?? this.planta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Aula &&
        other.id == id &&
        other.nombre == nombre &&
        other.planta == planta;
  }

  @override
  int get hashCode => Object.hash(id, nombre, planta);

  @override
  String toString() => 'Aula(id: $id, nombre: $nombre, planta: $planta)';
}
