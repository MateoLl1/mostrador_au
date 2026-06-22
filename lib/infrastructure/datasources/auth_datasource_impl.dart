import 'package:dio/dio.dart';
import 'package:mostrador_au/config/env/app_env.dart';
import 'package:mostrador_au/domain/domain.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  @override
  Future<LoginResponse> login({
    required String login,
    required String password,
    required int agenciaId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'login': login, 'password': password, 'agenciaId': agenciaId},
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final mensaje = (data is Map && data['mensaje'] != null)
          ? data['mensaje'].toString()
          : e.message ?? 'Error al iniciar sesión';
      throw Exception(mensaje);
    }
  }

  @override
  Future<List<Agencia>> getAgencias() async {
    final response = await _dio.get('/agencias');
    final List<dynamic> data = response.data;
    return data
        .map((e) => Agencia(
              agCodigo: (e['agCodigo'] as num).toInt(),
              agNombre: e['agNombre']?.toString() ?? '',
            ))
        .toList();
  }
}
