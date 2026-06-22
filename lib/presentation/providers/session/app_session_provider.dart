import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSession {
  final int? agenciaId;
  final String? agenciaNombre;

  const AppSession({this.agenciaId, this.agenciaNombre});
}

final appSessionProvider = StateNotifierProvider<AppSessionNotifier, AppSession?>((ref) {
  return AppSessionNotifier();
});

class AppSessionNotifier extends StateNotifier<AppSession?> {
  AppSessionNotifier() : super(null);

  void setSession({required int agenciaId, String? agenciaNombre}) {
    state = AppSession(agenciaId: agenciaId, agenciaNombre: agenciaNombre);
  }

  void clearSession() => state = null;

  bool get hasSession => state?.agenciaId != null;
}
