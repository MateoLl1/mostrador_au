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
  });
}
