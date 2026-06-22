import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/presentation/providers/session/app_session.dart';
import 'package:mostrador_au/presentation/providers/session/session_storage.dart';

export 'app_session.dart';
export 'session_storage.dart';

final appSessionProvider =
    StateNotifierProvider<AppSessionNotifier, AppSession?>((ref) {
  return AppSessionNotifier();
});

class AppSessionNotifier extends StateNotifier<AppSession?> {
  AppSessionNotifier({AppSession? initialSession}) : super(initialSession);

  Future<void> setSession(AppSession session) async {
    state = session;
    await SessionStorage.save(session);
  }

  Future<void> clearSession() async {
    state = null;
    await SessionStorage.delete();
  }

  bool get hasSession => state != null;
}
