import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

class LoginState {
  final bool submitLoading;
  final List<Agencia> agencias;
  final Agencia? selectedAgencia;
  final String? errorMessage;

  const LoginState({
    this.submitLoading = false,
    this.agencias = const [],
    this.selectedAgencia,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? submitLoading,
    List<Agencia>? agencias,
    Agencia? selectedAgencia,
    String? errorMessage,
    bool clearError = false,
    bool clearAgencias = false,
    bool clearAgencia = false,
  }) {
    return LoginState(
      submitLoading:   submitLoading  ?? this.submitLoading,
      agencias:        clearAgencias  ? [] : agencias ?? this.agencias,
      selectedAgencia: clearAgencia   ? null : selectedAgencia ?? this.selectedAgencia,
      errorMessage:    clearError     ? null : errorMessage ?? this.errorMessage,
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

  String _cachedLogin = '';
  String _cachedPassword = '';

  LoginNotifier({required this.authRepository, required this.sessionNotifier})
      : super(const LoginState());

  void selectAgencia(Agencia agencia) =>
      state = state.copyWith(selectedAgencia: agencia);

  Future<void> submit({required String login, required String password}) async {
    if (state.submitLoading) return;

    // Si cambiaron las credenciales, reiniciar selección de agencia
    if (login != _cachedLogin || password != _cachedPassword) {
      state = state.copyWith(
        clearAgencias: true,
        clearAgencia: true,
        clearError: true,
      );
    }

    if (state.agencias.isEmpty) {
      // Paso 1: validar credenciales y obtener agencias del usuario
      state = state.copyWith(submitLoading: true, clearError: true);
      try {
        final agencias = await authRepository.getAgenciasPorUsuario(
          login: login,
          password: password,
        );
        _cachedLogin = login;
        _cachedPassword = password;

        if (agencias.isEmpty) {
          state = state.copyWith(
            submitLoading: false,
            errorMessage: 'El usuario no tiene agencias asignadas.',
          );
        } else if (agencias.length == 1) {
          // Una sola agencia → login automático
          await _doLogin(login: login, password: password, agencia: agencias.first);
        } else {
          // Múltiples agencias → mostrar selector
          state = state.copyWith(
            submitLoading: false,
            agencias: agencias,
            selectedAgencia: agencias.first,
          );
        }
      } catch (e) {
        state = state.copyWith(
          submitLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } else {
      // Paso 2: el usuario ya eligió agencia → hacer login
      final agencia = state.selectedAgencia;
      if (agencia == null) return;
      state = state.copyWith(submitLoading: true, clearError: true);
      await _doLogin(login: login, password: password, agencia: agencia);
    }
  }

  Future<void> _doLogin({
    required String login,
    required String password,
    required Agencia agencia,
  }) async {
    try {
      final user = await authRepository.login(
        login:     login,
        password:  password,
        agenciaId: agencia.agCodigo,
      );
      state = state.copyWith(submitLoading: false);
      await sessionNotifier.setSession(AppSession(
        usCodigo:      user.usCodigo,
        usNombre:      user.usNombre,
        usLogin:       user.usLogin,
        usPassword:    password,
        grCodigo:      user.grCodigo,
        puModulo:      user.puModulo ?? '',
        agenciaId:     agencia.agCodigo,
        agenciaNombre: agencia.agNombre,
      ));
    } catch (e) {
      state = state.copyWith(
        submitLoading: false,
        errorMessage:  e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
