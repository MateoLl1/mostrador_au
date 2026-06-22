import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

class LoginState {
  final bool initLoading;
  final bool submitLoading;
  final List<Agencia> agencias;
  final Agencia? selectedAgencia;
  final String? errorMessage;

  const LoginState({
    this.initLoading = true,
    this.submitLoading = false,
    this.agencias = const [],
    this.selectedAgencia,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? initLoading,
    bool? submitLoading,
    List<Agencia>? agencias,
    Agencia? selectedAgencia,
    String? errorMessage,
    bool clearError = false,
    bool clearAgencia = false,
  }) {
    return LoginState(
      initLoading:    initLoading    ?? this.initLoading,
      submitLoading:  submitLoading  ?? this.submitLoading,
      agencias:       agencias       ?? this.agencias,
      selectedAgencia: clearAgencia  ? null : selectedAgencia ?? this.selectedAgencia,
      errorMessage:   clearError     ? null : errorMessage    ?? this.errorMessage,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    authRepository:  ref.watch(authRepositoryProvider),
    sessionNotifier: ref.read(appSessionProvider.notifier),
  );
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository authRepository;
  final AppSessionNotifier sessionNotifier;

  LoginNotifier({required this.authRepository, required this.sessionNotifier})
      : super(const LoginState()) {
    _loadAgencias();
  }

  Future<void> _loadAgencias() async {
    try {
      final agencias = await authRepository.getAgencias();
      state = state.copyWith(
        initLoading: false,
        agencias: agencias,
        selectedAgencia: agencias.isNotEmpty ? agencias.first : null,
      );
    } catch (_) {
      state = state.copyWith(initLoading: false);
    }
  }

  void selectAgencia(Agencia agencia) => state = state.copyWith(selectedAgencia: agencia);

  Future<void> login({required String login, required String password}) async {
    final agencia = state.selectedAgencia;
    if (agencia == null) return;

    state = state.copyWith(submitLoading: true, clearError: true);
    try {
      final user = await authRepository.login(
        login:     login,
        password:  password,
        agenciaId: agencia.agCodigo,
      );
      await sessionNotifier.setSession(AppSession(
        usCodigo:      user.usCodigo,
        usNombre:      user.usNombre,
        usLogin:       user.usLogin,
        usPassword:    password, // plain text for startup re-validation
        puModulo:      user.puModulo ?? '',
        agenciaId:     agencia.agCodigo,
        agenciaNombre: agencia.agNombre,
      ));
    } catch (e) {
      state = state.copyWith(
        submitLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
