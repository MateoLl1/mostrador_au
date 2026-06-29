import 'package:mostrador_au/domain/response/response.dart';

abstract class MostradorRepository {
  Future<PantallaTurnosResponse> getPantallaTurnos(int agenciaId);
  Future<TurnoAtencionResponse?> llamarSiguienteTurno({required int agenciaId, required int usCodigo});
  Future<TurnoAtencionResponse?> rellamarTurno({required int asgCodigo});
  Future<TurnoAtencionResponse?> atenderTurno({required int asgCodigo});
  Future<TurnoAtencionResponse?> cancelarTurno({required int asgCodigo});
}
