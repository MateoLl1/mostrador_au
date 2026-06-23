import 'package:mostrador_au/domain/domain.dart';

class MostradorRepositoryImpl extends MostradorRepository {
  final MostradorDatasource datasource;

  MostradorRepositoryImpl({required this.datasource});

  @override
  Future<PantallaTurnosResponse> getPantallaTurnos(int agenciaId) {
    return datasource.getPantallaTurnos(agenciaId);
  }

  @override
  Future<TurnoAtencionResponse?> llamarSiguienteTurno({required int agenciaId}) {
    return datasource.llamarSiguienteTurno(agenciaId: agenciaId);
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
