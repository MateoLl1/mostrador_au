import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mostrador_au/infrastructure/http/dio_factory.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Consulta al API la versión vigente del mostrador y, cuando hay una más
/// nueva que la instalada, descarga el MSI y lanza la instalación.
class ActualizadorService {
  ActualizadorService._();

  static final Dio _api = DioFactory.create();

  static Future<({String version, String url})?> buscarActualizacion() async {
    try {
      final response = await _api.get('/Actualizacion/mostrador');
      if (response.statusCode != 200 || response.data == null) return null;

      final data = Map<String, dynamic>.from(response.data);
      final version = data['version']?.toString().trim() ?? '';
      final url = data['url']?.toString().trim() ?? '';
      if (version.isEmpty || url.isEmpty) return null;

      final instalada = (await PackageInfo.fromPlatform()).version;
      if (!_esMasNueva(version, instalada)) return null;

      return (version: version, url: url);
    } catch (_) {
      return null;
    }
  }

  static Future<void> descargarEInstalar(String url, String version) async {
    final destino = '${Directory.systemTemp.path}\\MostradorAU-$version.msi';

    await Dio().download(url, destino);

    await Process.start(
      'msiexec',
      ['/i', destino, '/passive'],
      mode: ProcessStartMode.detached,
    );

    exit(0);
  }

  static bool _esMasNueva(String remota, String instalada) {
    List<int> partes(String v) => v
        .split('+')
        .first
        .split('.')
        .map((x) => int.tryParse(x.trim()) ?? 0)
        .toList();

    final r = partes(remota);
    final l = partes(instalada);

    for (var i = 0; i < 3; i++) {
      final a = i < r.length ? r[i] : 0;
      final b = i < l.length ? l[i] : 0;
      if (a != b) return a > b;
    }

    return false;
  }
}
