import 'package:dio/dio.dart';
import 'package:mostrador_au/config/env/app_env.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/infrastructure/mappers/mappers.dart';

class MostradorDatasourceImpl extends MostradorDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

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
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Error llamando siguiente turno',
      );
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
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Error rellamando turno',
      );
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
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Error atendiendo turno',
      );
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
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Error cancelando turno',
      );
    }
  }
}
