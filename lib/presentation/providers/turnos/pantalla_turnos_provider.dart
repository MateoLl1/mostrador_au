import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/config.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

// Solo relevante para Sistemas (grCodigo 11) — los demás tienen filtro fijo por rol
final filtroSistemasProvider = StateProvider<String>((ref) => 'mostrador');

/// Mensajes de validación de negocio (ej. "ya tiene un turno en proceso")
/// para mostrar como snackbar. No se usa AsyncError para esto: son mal uso
/// del usuario, no una falla de la app, y no deben tapar la pantalla.
final turnoSnackbarProvider = StateProvider<String?>((ref) => null);

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
    onMensajeUsuario: (mensaje) =>
        ref.read(turnoSnackbarProvider.notifier).state = mensaje,
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

  /// Reporta un mensaje de validación de negocio hacia turnoSnackbarProvider.
  final void Function(String mensaje) onMensajeUsuario;

  Timer? _timer;
  Timer? _retryTimer;
  bool _procesando = false;
  int _prevPendientes = -1;

  PantallaTurnosNotifier({
    required this.repository,
    required this.agenciaId,
    required this.usCodigo,
    required this.filtro,
    required this.onMensajeUsuario,
  }) : super(const AsyncLoading()) {
    loadPantalla();
    _startAutoRefresh();
  }

  /// Un error real (red, servidor, etc.) sí tapa la pantalla -- pero se
  /// reintenta solo, sin esperar los 10s del refresco periódico normal.
  void _manejarErrorReal(Object e, StackTrace s) {
    if (!mounted) return;
    state = AsyncError(e, s);
    _retryTimer?.cancel();
    _retryTimer = Timer(
      Duration(seconds: AppEnv.errorRetrySeconds),
      loadPantalla,
    );
  }

  Future<void> loadPantalla() async {
    if (!mounted) return;
    if (agenciaId == null) {
      // Sin agencia = la sesión se está cerrando (clearSession ya puso la
      // sesión en null y este provider se reconstruye un instante antes de
      // que la navegación a /login termine). No es un error real que valga
      // la pena alarmar en rojo -- se queda cargando hasta que la pantalla
      // cambie sola.
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
      _manejarErrorReal(e, s);
    }
  }

  Future<void> llamarSiguiente({required int usCodigo}) async {
    if (!mounted || _procesando || agenciaId == null) return;
    _procesando = true;
    try {
      await repository.llamarSiguienteTurno(agenciaId: agenciaId!, usCodigo: usCodigo, filtro: filtro);
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> rellamarActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      onMensajeUsuario('No existe un turno actual para rellamar');
      return;
    }
    _procesando = true;
    try {
      await repository.rellamarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> atenderActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      onMensajeUsuario('No existe un turno actual para atender');
      return;
    }
    _procesando = true;
    try {
      await repository.atenderTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> llamarTurno({required int asgCodigo}) async {
    if (!mounted || _procesando) return;
    _procesando = true;
    try {
      await repository.llamarTurnoEspecifico(
        asgCodigo: asgCodigo,
        usCodigo: usCodigo ?? 0,
      );
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> saltarActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      onMensajeUsuario('No existe un turno actual para saltar');
      return;
    }
    _procesando = true;
    try {
      await repository.saltarTurno(
        asgCodigo: turnoActual.asgCodigo,
        usCodigo: usCodigo ?? 0,
      );
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  Future<void> cancelarActual() async {
    if (!mounted || _procesando) return;
    final turnoActual = state.asData?.value.turnoActual;
    if (turnoActual == null || turnoActual.asgCodigo <= 0) {
      onMensajeUsuario('No existe un turno actual para cancelar');
      return;
    }
    _procesando = true;
    try {
      await repository.cancelarTurno(asgCodigo: turnoActual.asgCodigo);
      await loadPantalla();
    } on TurnoConflictException catch (e) {
      onMensajeUsuario(e.mensaje);
    } catch (e, s) {
      _manejarErrorReal(e, s);
    } finally {
      _procesando = false;
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => loadPantalla());
  }

  void disposeTimer() {
    _timer?.cancel();
    _retryTimer?.cancel();
  }
}
