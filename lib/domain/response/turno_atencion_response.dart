class TurnoAtencionResponse {
  final int asgCodigo;
  final String turno;
  final String estado;
  final String modulo;
  final int agenciaId;
  final DateTime? fechaMovimiento;
  final String mensaje;

  TurnoAtencionResponse({
    required this.asgCodigo,
    required this.turno,
    required this.estado,
    required this.modulo,
    required this.agenciaId,
    required this.fechaMovimiento,
    required this.mensaje,
  });

  factory TurnoAtencionResponse.fromJson(Map<String, dynamic> json) {
    return TurnoAtencionResponse(
      asgCodigo: (json['asgCodigo'] as num?)?.toInt() ?? 0,
      turno: json['turno']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      modulo: json['modulo']?.toString() ?? '',
      agenciaId: (json['agenciaId'] as num?)?.toInt() ?? 0,
      fechaMovimiento: json['fechaMovimiento'] == null
          ? null
          : DateTime.tryParse(json['fechaMovimiento'].toString()),
      mensaje: json['mensaje']?.toString() ?? '',
    );
  }
}
