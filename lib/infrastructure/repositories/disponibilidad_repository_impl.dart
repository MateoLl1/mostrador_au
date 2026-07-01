import 'package:mostrador_au/domain/domain.dart';

class DisponibilidadRepositoryImpl extends DisponibilidadRepository {
  final DisponibilidadDatasource datasource;

  DisponibilidadRepositoryImpl({required this.datasource});

  @override
  Future<DisponibilidadResponse?> getEstado({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) =>
      datasource.getEstado(
          usCodigo: usCodigo, agenciaId: agenciaId, gnCodigo: gnCodigo);

  @override
  Future<DisponibilidadResponse> toggle({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) =>
      datasource.toggle(
          usCodigo: usCodigo, agenciaId: agenciaId, gnCodigo: gnCodigo);

  @override
  Future<DisponibilidadResponse> activar({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) =>
      datasource.activar(
          usCodigo: usCodigo, agenciaId: agenciaId, gnCodigo: gnCodigo);

  @override
  Future<void> desactivar({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) =>
      datasource.desactivar(
          usCodigo: usCodigo, agenciaId: agenciaId, gnCodigo: gnCodigo);
}
