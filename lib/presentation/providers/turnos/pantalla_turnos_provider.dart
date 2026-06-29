import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/config.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

final pantallaTurnosProvider = StateNotifierProvider.autoDispose<
    PantallaTurnosNotifier, AsyncValue<PantallaTurnosResponse>>((ref) {
  final repository = ref.watch(mostradorRepositoryProvider);
  final session = ref.watch(appSessionProvider);

  final notifier = PantallaTurnosNotifier(
    repository: repository,
    agenciaId: session?.agenciaId,
  );

  ref.onDispose(notifier.disposeTimer);

  return notifier;
});

class PantallaTurnosNotifier
    extends StateNotifier<AsyncValue<PantallaTurnosResponse>> {
  final MostradorRepository repository;
  final int? agenciaId;
  Timer? _timer;
  bool _procesando = false;
  int _prevPendientes = -1;

  PantallaTurnosNotifier({
    required this.repository,
    required this.agenciaId,
  }) : super(const AsyncLoading()) {
    loadPantalla();
    _startAutoRefresh();
  }

  Future<void> loadPantalla() async {
    if (agenciaId == null) {
      state = AsyncError('No hay agencia configurada', StackTrace.current);
      return;
    }
    try {
      final response = await repository.getPantallaTurnos(agenciaId!);
      if (_prevPendientes >= 0 &&
          response.turnosPendientes.length > _prevPendientes) {
        TaskbarService.instance.flashIfUnfocused();
        TaskbarService.instance.bringToForeground();
      }
      _prevPendientes = response.turnosPendientes.length;
      state = AsyncData(response);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> llamarSiguiente({required int usCodigo}) async {
    if (_procesando || agenciaId == null) return;
    _procesando = true;
    try {
      await repository.llamarSiguienteTurno(agenciaId: agenciaId!, usCodigo: usCodigo);
      await loadPantalla();
    } catch (e, s) {
      state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> rellamarActual() async {
    if (_procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      state = AsyncError('No existe un turno actual para rellamar', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.rellamarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> atenderActual() async {
    if (_procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      state = AsyncError('No existe un turno actual para atender', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.atenderTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> cancelarActual() async {
    if (_procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      state = AsyncError('No existe un turno actual para cancelar', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.cancelarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => loadPantalla());
  }

  void disposeTimer() => _timer?.cancel();
}
