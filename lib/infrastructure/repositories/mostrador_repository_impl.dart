import 'package:mostrador_au/domain/domain.dart';

class MostradorRepositoryImpl extends MostradorRepository {
  final MostradorDatasource datasource;

  MostradorRepositoryImpl({required this.datasource});

  @override
  Future<PantallaTurnosResponse> getPantallaTurnos(int agenciaId, {int? usCodigo, String? filtro}) {
    return datasource.getPantallaTurnos(agenciaId, usCodigo: usCodigo, filtro: filtro);
  }

  @override
  Future<TurnoAtencionResponse?> llamarSiguienteTurno({required int agenciaId, required int usCodigo, String? filtro}) {
    return datasource.llamarSiguienteTurno(agenciaId: agenciaId, usCodigo: usCodigo, filtro: filtro);
  }

  @override
  Future<TurnoAtencionResponse?> rellamarTurno({required int asgCodigo}) {
    return datasource.rellamarTurno(asgCodigo: asgCodigo);
  }

  @override
  Future<TurnoAtencionResponse?> atenderTurno({required int asgCodigo}) {
    return datasource.atenderTurno(asgCodigo: asgCodigo);
  }

  @override
  Future<TurnoAtencionResponse?> cancelarTurno({required int asgCodigo}) {
    return datasource.cancelarTurno(asgCodigo: asgCodigo);
  }
}
