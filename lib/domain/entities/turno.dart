class Turno {
  final int asgCodigo;
  final String turno;
  final String modulo;
  final String estado;
  final int tiempo;
  final String tipo;
  final bool requiereCambioEstado;
  final bool esTurnoActual;
  final String nombreCliente;
  final DateTime? fechaReferencia;
  final String canal;

  /// Diagnóstico de la cola. La API solo las envía a usuarios de Sistemas;
  /// para el resto llegan nulas.
  final DateTime? fechaCita;
  final DateTime? fechaLlegada;
  final DateTime? fechaOrden;

  Turno({
    required this.asgCodigo,
    required this.turno,
    required this.modulo,
    required this.estado,
    required this.tiempo,
    required this.tipo,
    required this.requiereCambioEstado,
    required this.esTurnoActual,
    required this.nombreCliente,
    required this.fechaReferencia,
    this.canal = 'R',
    this.fechaCita,
    this.fechaLlegada,
    this.fechaOrden,
  });
}
