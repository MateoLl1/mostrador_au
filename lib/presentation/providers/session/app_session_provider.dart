import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSession {
  final int usCodigo;
  final String usNombre;
  final String usLogin;
  final String usPassword;
  final String puModulo;
  final int agenciaId;
  final String agenciaNombre;

  const AppSession({
    required this.usCodigo,
    required this.usNombre,
    required this.usLogin,
    required this.usPassword,
    required this.puModulo,
    required this.agenciaId,
    required this.agenciaNombre,
  });
}

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSession?>((ref) {
  return AppSessionNotifier();
});

class AppSessionNotifier extends StateNotifier<AppSession?> {
  AppSessionNotifier() : super(null);

  void setSession(AppSession session) => state = session;

  void clearSession() => state = null;

  bool get hasSession => state != null;
}
