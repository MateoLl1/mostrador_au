import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

enum LoginStep { credentials, agencySelection }

class LoginState {
  final LoginStep step;
  final bool loading;
  final String? errorMessage;
  final LoginResponse? user;
  final String? password;
  final List<Agencia> agencias;
  final Agencia? selectedAgencia;

  const LoginState({
    this.step = LoginStep.credentials,
    this.loading = false,
    this.errorMessage,
    this.user,
    this.password,
    this.agencias = const [],
    this.selectedAgencia,
  });

  LoginState copyWith({
    LoginStep? step,
    bool? loading,
    String? errorMessage,
    LoginResponse? user,
    String? password,
    List<Agencia>? agencias,
    Agencia? selectedAgencia,
    bool clearError = false,
    bool clearAgencia = false,
  }) {
    return LoginState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      password: password ?? this.password,
      agencias: agencias ?? this.agencias,
      selectedAgencia: clearAgencia ? null : selectedAgencia ?? this.selectedAgencia,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    sessionNotifier: ref.read(appSessionProvider.notifier),
  );
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository authRepository;
  final AppSessionNotifier sessionNotifier;

  LoginNotifier({
    required this.authRepository,
    required this.sessionNotifier,
  }) : super(const LoginState());

  Future<void> login({
    required String login,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await authRepository.login(login: login, password: password);
      final agencias = await authRepository.getAgencias();
      state = state.copyWith(
        loading: false,
        step: LoginStep.agencySelection,
        user: user,
        password: password,
        agencias: agencias,
        selectedAgencia: agencias.isNotEmpty ? agencias.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectAgencia(Agencia agencia) {
    state = state.copyWith(selectedAgencia: agencia);
  }

  void confirmAgencia() {
    final user = state.user;
    final agencia = state.selectedAgencia;
    if (user == null || agencia == null) return;

    sessionNotifier.setSession(
      AppSession(
        usCodigo: user.usCodigo,
        usNombre: user.usNombre,
        usLogin: user.usLogin,
        usPassword: state.password ?? '',
        puModulo: user.puModulo,
        agenciaId: agencia.agCodigo,
        agenciaNombre: agencia.agNombre,
      ),
    );
  }

  void goBack() {
    state = state.copyWith(
      step: LoginStep.credentials,
      clearError: true,
      clearAgencia: true,
    );
  }
}
