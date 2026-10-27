enum Estado {
  abierta('ABIERTA'),
  enProceso('EN_PROCESO'),
  resuelta('RESUELTA'),
  cerrada('CERRADA');

  final String value;
  const Estado(this.value);

  static Estado fromString(String val) {
    final normalized = val.toUpperCase().replaceAll(' ', '_');
    return Estado.values.firstWhere(
      (e) => e.value == normalized,
      orElse: () => Estado.abierta,
    );
  }
}
