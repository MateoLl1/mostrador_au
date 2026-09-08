import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

const int _gnCodigoMostrador = 6;
const Duration _intervaloSincronizacion = Duration(minutes: 1);

class DisponibilidadState {
  final bool isActivo;
  final bool isLoading;

  const DisponibilidadState({
    this.isActivo = false,
    this.isLoading = true,
  });

  DisponibilidadState copyWith({bool? isActivo, bool? isLoading}) =>
      DisponibilidadState(
        isActivo: isActivo ?? this.isActivo,
        isLoading: isLoading ?? this.isLoading,
      );
}

final disponibilidadProvider =
    StateNotifierProvider<DisponibilidadNotifier, DisponibilidadState>((ref) {
  final repository = ref.watch(disponibilidadRepositoryProvider);
  final session = ref.watch(appSessionProvider);
  return DisponibilidadNotifier(repository: repository, session: session);
});

class DisponibilidadNotifier extends StateNotifier<DisponibilidadState> {
  final DisponibilidadRepository repository;
  final AppSession? session;

  Timer? _sincronizacionTimer;

  DisponibilidadNotifier({required this.repository, required this.session})
      : super(const DisponibilidadState()) {
    _activarAutomatico();
  }

  Future<void> _activarAutomatico() async {
    if (session == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    try {
      final response = await repository.activar(
        usCodigo: session!.usCodigo,
        agenciaId: session!.agenciaId,
        gnCodigo: _gnCodigoMostrador,
      );
      if (mounted) state = state.copyWith(isActivo: response.isActivo, isLoading: false);
    } catch (_) {
      if (mounted) state = state.copyWith(isLoading: false);
    }
    _iniciarSincronizacionPeriodica();
  }

  /// Vuelve a leer el estado real del servidor cada minuto. El estado local
  /// solo cambiaba con las acciones del propio usuario (toggle/activar/
  /// desactivar); si algo lo cambiaba por fuera -otro dispositivo, un
  /// proceso del servidor- el botón seguía mostrando un estado que ya no
  /// era real hasta el próximo toque manual.
  void _iniciarSincronizacionPeriodica() {
    _sincronizacionTimer?.cancel();
    _sincronizacionTimer =
        Timer.periodic(_intervaloSincronizacion, (_) => _sincronizarEstado());
  }

  Future<void> _sincronizarEstado() async {
    // Si el usuario esta con una accion propia en curso (toggle/desactivar),
    // no pisarla con una lectura que pudo haber salido antes de esa accion.
    if (session == null || state.isLoading) return;
    try {
      final response = await repository.getEstado(
        usCodigo: session!.usCodigo,
        agenciaId: session!.agenciaId,
        gnCodigo: _gnCodigoMostrador,
      );
      if (mounted && response != null && response.isActivo != state.isActivo) {
        state = state.copyWith(isActivo: response.isActivo);
      }
    } catch (_) {
      // Un fallo de red no debe apagar el boton; se reintenta en el proximo ciclo.
    }
  }

  @override
  void dispose() {
    _sincronizacionTimer?.cancel();
    super.dispose();
  }

  Future<void> toggle() async {
    if (session == null || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final response = await repository.toggle(
        usCodigo: session!.usCodigo,
        agenciaId: session!.agenciaId,
        gnCodigo: _gnCodigoMostrador,
      );
      state = state.copyWith(isActivo: response.isActivo, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> desactivar() async {
    if (session == null || !state.isActivo) return;
    try {
      await repository.desactivar(
        usCodigo: session!.usCodigo,
        agenciaId: session!.agenciaId,
        gnCodigo: _gnCodigoMostrador,
      );
      if (mounted) state = state.copyWith(isActivo: false);
    } catch (_) {}
  }
}
