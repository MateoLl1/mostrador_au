import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static String nombreApp = dotenv.env['NOMBRE_APP'] ?? '';

  /// Cuánto espera pantallaTurnosProvider antes de reintentar solo cuando
  /// cae en un error real (no las validaciones de negocio, esas van por
  /// snackbar). Exagerado a propósito por ahora para verlo bien en pruebas.
  static int errorRetrySeconds =
      int.tryParse(dotenv.env['ERROR_RETRY_SECONDS'] ?? '') ?? 3;
}
