enum Prioridad {
  baja('BAJA'),
  media('MEDIA'),
  alta('ALTA'),
  urgente('URGENTE');

  final String value;
  const Prioridad(this.value);

  static Prioridad fromString(String val) {
    return Prioridad.values.firstWhere(
      (p) => p.value.toUpperCase() == val.toUpperCase(),
      orElse: () => Prioridad.media,
    );
  }
}
