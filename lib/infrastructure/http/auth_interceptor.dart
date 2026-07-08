import 'package:dio/dio.dart';
import 'keycloak_service.dart';

class AuthInterceptor extends Interceptor {
  final KeycloakService _keycloak;

  AuthInterceptor(this._keycloak);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _keycloak.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      _keycloak.invalidate();
      final token = await _keycloak.getToken();
      if (token != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
