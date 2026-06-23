class DisponibilidadResponse {
  final int dvCodigo;
  final String estado;
  final String mensaje;

  bool get isActivo => estado == 'A';

  const DisponibilidadResponse({
    required this.dvCodigo,
    required this.estado,
    required this.mensaje,
  });

  factory DisponibilidadResponse.fromJson(Map<String, dynamic> json) =>
      DisponibilidadResponse(
        dvCodigo: (json['dvCodigo'] as num).toInt(),
        estado: json['estado']?.toString().trim() ?? '',
        mensaje: json['mensaje']?.toString() ?? '',
      );
}
