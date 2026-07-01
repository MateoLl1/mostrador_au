import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

const int _gnCodigoMostrador = 6;

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
