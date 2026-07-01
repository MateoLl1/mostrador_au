import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/config.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

// Solo relevante para Sistemas (grCodigo 11) — los demás tienen filtro fijo por rol
final filtroSistemasProvider = StateProvider<String>((ref) => 'mostrador');

final pantallaTurnosProvider = StateNotifierProvider.autoDispose<
    PantallaTurnosNotifier, AsyncValue<PantallaTurnosResponse>>((ref) {
  final repository = ref.watch(mostradorRepositoryProvider);
  final session = ref.watch(appSessionProvider);
  final grCodigo = session?.grCodigo;

  final String filtro;
  if (grCodigo == 5) {
    filtro = 'mostrador';
  } else if (grCodigo == 9) {
    filtro = 'servicio';
  } else {
    filtro = ref.watch(filtroSistemasProvider);
  }

  final notifier = PantallaTurnosNotifier(
    repository: repository,
    agenciaId: session?.agenciaId,
    usCodigo: session?.usCodigo,
    filtro: filtro,
  );

  ref.onDispose(notifier.disposeTimer);

  return notifier;
});

class PantallaTurnosNotifier
    extends StateNotifier<AsyncValue<PantallaTurnosResponse>> {
  final MostradorRepository repository;
  final int? agenciaId;
  final int? usCodigo;
  final String filtro;
  Timer? _timer;
  bool _procesando = false;
  int _prevPendientes = -1;

  PantallaTurnosNotifier({
    required this.repository,
    required this.agenciaId,
    required this.usCodigo,
    required this.filtro,
  }) : super(const AsyncLoading()) {
    loadPantalla();
    _startAutoRefresh();
  }

  Future<void> loadPantalla() async {
    if (!mounted) return;
    if (agenciaId == null) {
      if (mounted) state = AsyncError('No hay agencia configurada', StackTrace.current);
      return;
    }
    try {
      final response = await repository.getPantallaTurnos(agenciaId!, usCodigo: usCodigo, filtro: filtro);
      if (!mounted) return;
      if (_prevPendientes >= 0 &&
          response.turnosPendientes.length > _prevPendientes) {
        TaskbarService.instance.flashIfUnfocused();
        TaskbarService.instance.bringToForeground();
      }
      _prevPendientes = response.turnosPendientes.length;
      state = AsyncData(response);
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
    }
  }

  Future<void> llamarSiguiente({required int usCodigo}) async {
    if (!mounted || _procesando || agenciaId == null) return;
    _procesando = true;
    try {
      await repository.llamarSiguienteTurno(agenciaId: agenciaId!, usCodigo: usCodigo, filtro: filtro);
      await loadPantalla();
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> rellamarActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      if (mounted) state = AsyncError('No existe un turno actual para rellamar', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.rellamarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> atenderActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      if (mounted) state = AsyncError('No existe un turno actual para atender', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.atenderTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> cancelarActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      if (mounted) state = AsyncError('No existe un turno actual para cancelar', StackTrace.current);
      return;
    }
    _procesando = true;
    try {
      await repository.cancelarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
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
