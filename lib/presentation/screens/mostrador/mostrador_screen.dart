import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 28),
            child: pantallaState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
              data: (data) => Column(
                children: [
                  MostradorHeader(totalEnEspera: data.turnosPendientes.length),
                  if (session?.grCodigo == 11) ...[
                    const SizedBox(height: 14),
                    _FiltroSistemasToggle(),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: CurrentTurnCard(
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
                                .cancelarActual(),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: QueueCard(pendientes: data.turnosPendientes),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
