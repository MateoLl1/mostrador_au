import 'package:dio/dio.dart';

class KeycloakService {
  static KeycloakService? _instance;

  static KeycloakService instance(String baseUrl) {
    _instance ??= KeycloakService._(baseUrl);
    return _instance!;
  }

  final Dio _dio;
  String? _token;
  DateTime? _expiry;

  KeycloakService._(String baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<String?> getToken() async {
    if (_token != null &&
        _expiry != null &&
        DateTime.now().isBefore(_expiry!)) {
      return _token;
    }
    return _refresh();
  }

  void invalidate() {
    _token = null;
    _expiry = null;
  }

  Future<String?> _refresh() async {
    try {
      final response = await _dio.get('/auth/token');
      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken'] as String?;
      final expiresIn = (data['expiresIn'] as num?)?.toInt() ?? 300;

      if (token == null || token.isEmpty) return null;

      _token = token;
      _expiry = DateTime.now().add(Duration(seconds: expiresIn - 30));
      return _token;
    } catch (_) {
      return null;
    }
  }
}
