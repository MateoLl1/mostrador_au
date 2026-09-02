import 'package:dio/dio.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/infrastructure/http/dio_factory.dart';
import 'package:mostrador_au/infrastructure/mappers/mappers.dart';

class MostradorDatasourceImpl extends MostradorDatasource {
  final Dio _dio = DioFactory.create();

  /// 409 con mensaje = validación esperada del negocio (ej. "ya tiene un
  /// turno en proceso"), no una falla real -- se distingue con un tipo de
  /// excepción propio para que el provider lo muestre como snackbar y no
  /// como la pantalla de error completa.
  Never _lanzarError(DioException e, String mensajePorDefecto) {
    final data = e.response?.data;
    final mensaje = data is Map ? data['mensaje']?.toString() : null;

    if (e.response?.statusCode == 409 && mensaje != null) {
      throw TurnoConflictException(mensaje);
    }

    throw Exception(mensaje ?? e.message ?? mensajePorDefecto);
  }

  @override
  Future<PantallaTurnosResponse> getPantallaTurnos(int agenciaId, {int? usCodigo, String? filtro}) async {
    final params = <String, dynamic>{'agenciaId': agenciaId};
    if (usCodigo != null && usCodigo > 0) params['usCodigo'] = usCodigo;
    if (filtro != null) params['filtro'] = filtro;
    final response = await _dio.get('/PantallaTurnos', queryParameters: params);
    return PantallaTurnosMapper.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TurnoAtencionResponse?> llamarSiguienteTurno({
    required int agenciaId,
    required int usCodigo,
    String? filtro,
  }) async {
    try {
      final params = <String, dynamic>{'agenciaId': agenciaId, 'usCodigo': usCodigo};
      if (filtro != null) params['filtro'] = filtro;
      final response = await _dio.post(
        '/turnos/llamar-siguiente',
        queryParameters: params,
      );
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error llamando siguiente turno');
    }
  }

  @override
  Future<TurnoAtencionResponse?> rellamarTurno({required int asgCodigo}) async {
    try {
      final response = await _dio.post('/turnos/$asgCodigo/rellamar');
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error rellamando turno');
    }
  }

  @override
  Future<TurnoAtencionResponse?> atenderTurno({required int asgCodigo}) async {
    try {
      final response = await _dio.post('/turnos/$asgCodigo/atender');
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error atendiendo turno');
    }
  }

  @override
  Future<TurnoAtencionResponse?> llamarTurnoEspecifico({required int asgCodigo, required int usCodigo}) async {
    try {
      final response = await _dio.post(
        '/turnos/$asgCodigo/llamar',
        queryParameters: {'usCodigo': usCodigo},
      );
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error llamando turno');
    }
  }

  @override
  Future<TurnoAtencionResponse?> saltarTurno({required int asgCodigo, required int usCodigo}) async {
    try {
      final response = await _dio.post(
        '/turnos/$asgCodigo/saltar',
        queryParameters: {'usCodigo': usCodigo},
      );
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error saltando turno');
    }
  }

  @override
  Future<TurnoAtencionResponse?> cancelarTurno({required int asgCodigo}) async {
    try {
      final response = await _dio.post('/turnos/$asgCodigo/cancelar');
      if (response.statusCode != 200 || response.data == null) return null;
      return TurnoAtencionResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _lanzarError(e, 'Error cancelando turno');
    }
  }
}
