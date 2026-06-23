import 'package:mostrador_au/domain/response/response.dart';

abstract class DisponibilidadRepository {
  Future<DisponibilidadResponse?> getEstado({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  });

  Future<DisponibilidadResponse> toggle({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  });
}
