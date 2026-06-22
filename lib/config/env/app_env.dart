import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  static String nombreApp = dotenv.env['NOMBRE_APP'] ?? '';
}
