import 'package:mostrador_au/domain/domain.dart';

class TurnoPantallaMapper {
  static Turno fromJson(Map<String, dynamic> json) {
    return Turno(
      asgCodigo: (json['asgCodigo'] as num?)?.toInt() ?? 0,
      turno: json['turno']?.toString() ?? '',
      modulo: json['modulo']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      tiempo: (json['tiempo'] as num?)?.toInt() ?? 0,
      tipo: json['tipo']?.toString() ?? '',
      requiereCambioEstado: json['requiereCambioEstado'] == true,
      esTurnoActual: json['esTurnoActual'] == true,
      nombreCliente: json['nombreCliente']?.toString() ?? '',
      fechaReferencia: json['fechaReferencia'] != null
          ? DateTime.tryParse(json['fechaReferencia'].toString())
          : null,
    );
  }
}

class PantallaTurnosMapper {
  static PantallaTurnosResponse fromJson(Map<String, dynamic> json) {
    return PantallaTurnosResponse(
      turnos: (json['turnos'] as List<dynamic>? ?? [])
          .map((e) => TurnoPantallaMapper.fromJson(e as Map<String, dynamic>))
          .toList(),
      turnoActual: json['turnoActual'] != null
          ? TurnoPantallaMapper.fromJson(json['turnoActual'] as Map<String, dynamic>)
          : null,
      turnosRecienLlamados: (json['turnosRecienLlamados'] as List<dynamic>? ?? [])
          .map((e) => TurnoPantallaMapper.fromJson(e as Map<String, dynamic>))
          .toList(),
      turnosPendientes: (json['turnosPendientes'] as List<dynamic>? ?? [])
          .map((e) => TurnoPantallaMapper.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
