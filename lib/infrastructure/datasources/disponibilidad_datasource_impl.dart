import 'package:dio/dio.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/infrastructure/http/dio_factory.dart';

class DisponibilidadDatasourceImpl extends DisponibilidadDatasource {
  final Dio _dio = DioFactory.create();

  @override
  Future<DisponibilidadResponse?> getEstado({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) async {
    try {
      final response = await _dio.get(
        '/mostrador/disponibilidad/estado',
        queryParameters: {
          'usCodigo': usCodigo,
          'agenciaId': agenciaId,
          'gnCodigo': gnCodigo,
        },
      );
      return DisponibilidadResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.response?.data?['mensaje'] ?? e.message);
    }
  }

  @override
  Future<DisponibilidadResponse> toggle({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) async {
    try {
      final response = await _dio.post(
        '/mostrador/disponibilidad/toggle',
        data: {
          'usCodigo': usCodigo,
          'agenciaId': agenciaId,
          'gnCodigo': gnCodigo,
        },
      );
      return DisponibilidadResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['mensaje'] ?? e.message);
    }
  }

  @override
  Future<DisponibilidadResponse> activar({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) async {
    try {
      final response = await _dio.post(
        '/mostrador/disponibilidad/activar',
        data: {
          'usCodigo': usCodigo,
          'agenciaId': agenciaId,
          'gnCodigo': gnCodigo,
        },
      );
      return DisponibilidadResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['mensaje'] ?? e.message);
    }
  }

  @override
  Future<void> desactivar({
    required int usCodigo,
    required int agenciaId,
    required int gnCodigo,
  }) async {
    try {
      await _dio.post(
        '/mostrador/disponibilidad/desactivar',
        data: {
          'usCodigo': usCodigo,
          'agenciaId': agenciaId,
          'gnCodigo': gnCodigo,
        },
      );
    } catch (_) {}
  }
}
