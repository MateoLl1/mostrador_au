import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/services/actualizador_service.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';
import 'package:mostrador_au/presentation/widgets/widgets.dart';
import 'package:mostrador_au/presentation/screens/painters/home3_painter.dart';

class MostradorScreen extends ConsumerStatefulWidget {
  const MostradorScreen({super.key});

  @override
  ConsumerState<MostradorScreen> createState() => _MostradorScreenState();
}

class _MostradorScreenState extends ConsumerState<MostradorScreen>
    with WidgetsBindingObserver {
  Timer? _actualizacionTimer;
  bool _dialogoActualizacionAbierto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarActualizacion());
    _actualizacionTimer = Timer.periodic(
      const Duration(hours: 4),
      (_) => _verificarActualizacion(),
    );
  }

  @override
  void dispose() {
    _actualizacionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _verificarActualizacion() async {
    if (_dialogoActualizacionAbierto) return;

    final actualizacion = await ActualizadorService.buscarActualizacion();
    if (actualizacion == null || !mounted) return;

    _dialogoActualizacionAbierto = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var descargando = false;
        String? error;

        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setStateDialog) => AlertDialog(
              title: const Text('Actualización disponible'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hay una nueva versión del mostrador (${actualizacion.version}). '
                    'Debes actualizar para continuar.',
                  ),
                  if (descargando) ...[
                    const SizedBox(height: 18),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Descargando actualización...'),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
              actions: [
                if (!descargando)
                  FilledButton.icon(
                    icon: const Icon(Icons.system_update_alt),
                    label: const Text('Actualizar ahora'),
                    onPressed: () async {
                      setStateDialog(() {
                        descargando = true;
                        error = null;
                      });

                      try {
                        await ActualizadorService.descargarEInstalar(
                          actualizacion.url,
                          actualizacion.version,
                        );
                      } catch (_) {
                        setStateDialog(() {
                          descargando = false;
                          error = 'No se pudo descargar la actualización. '
                              'Verifica tu conexión e inténtalo de nuevo.';
                        });
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    _dialogoActualizacionAbierto = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.detached) {
      ref.read(disponibilidadProvider.notifier).desactivar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pantallaState = ref.watch(pantallaTurnosProvider);
    final isActivo = ref.watch(disponibilidadProvider).isActivo;
    final session = ref.watch(appSessionProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomPaint(
        size: Size.infinite,
        painter: Home3Painter(primaryColor: colors.primary),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 44,
                  vertical: isCompact ? 16 : 28,
                ),
                child: pantallaState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      error.toString(),
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (data) {
                    final header = MostradorHeader(
                        totalEnEspera: data.turnosPendientes.length);
                    final filtro = session?.grCodigo == 11
                        ? _FiltroSistemasToggle()
                        : null;
                    final flotas = data.turnosPendientes
                        .where((t) => t.tipo == 'flota')
                        .toList();
                    final resto = data.turnosPendientes
                        .where((t) => t.tipo != 'flota')
                        .toList();
                    final siguienteAsg = resto.isNotEmpty
                        ? resto.first.asgCodigo
                        : null;
                    final flotaCard = QueueCard(
                      pendientes: flotas,
                      titulo: 'Flotas',
                      textoVacio: 'Sin turnos de flota',
                      onTapTurno: (t) => ref
                          .read(pantallaTurnosProvider.notifier)
                          .llamarTurno(asgCodigo: t.asgCodigo),
                    );
                    final queueCard = QueueCard(
                      pendientes: resto,
                      siguienteAsgCodigo: siguienteAsg,
                    );
                    final currentCard = CurrentTurnCard(
                      turnoActual: data.turnoActual,
                      isActivo: isActivo,
                      onLlamarSiguiente: () => ref
                          .read(pantallaTurnosProvider.notifier)
                          .llamarSiguiente(usCodigo: session?.usCodigo ?? 0),
                      onRellamar: () => ref
                          .read(pantallaTurnosProvider.notifier)
                          .rellamarActual(),
                      onAtender: () => ref
                          .read(pantallaTurnosProvider.notifier)
                          .atenderActual(),
                      onSaltar: () => ref
                          .read(pantallaTurnosProvider.notifier)
                          .saltarActual(),
                    );

                    if (isCompact) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            header,
                            if (filtro != null) ...[
                              const SizedBox(height: 14),
                              filtro,
                            ],
                            const SizedBox(height: 20),
                            currentCard,
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: flotaCard,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 380,
                              child: queueCard,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        header,
                        if (filtro != null) ...[
                          const SizedBox(height: 14),
                          filtro,
                        ],
                        const SizedBox(height: 24),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(flex: 7, child: currentCard),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    Expanded(flex: 2, child: flotaCard),
                                    const SizedBox(height: 16),
                                    Expanded(flex: 3, child: queueCard),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FiltroSistemasToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroActual = ref.watch(filtroSistemasProvider);
    final colors = Theme.of(context).colorScheme;

    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colors.primaryContainer,
        selectedForegroundColor: colors.onPrimaryContainer,
      ),
      segments: const [
        ButtonSegment(
          value: 'mostrador',
          label: Text('Mostrador'),
          icon: Icon(Icons.storefront_rounded),
        ),
        ButtonSegment(
          value: 'servicio',
          label: Text('Servicio'),
          icon: Icon(Icons.build_rounded),
        ),
      ],
      selected: {filtroActual},
      onSelectionChanged: (selection) =>
          ref.read(filtroSistemasProvider.notifier).state = selection.first,
    );
  }
}
