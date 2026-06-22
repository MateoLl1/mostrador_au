import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';
import 'package:mostrador_au/presentation/screens/painters/home3_painter.dart';
import 'package:mostrador_au/presentation/widgets/widgets.dart';

class MostradorScreen extends ConsumerWidget {
  const MostradorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final pantallaState = ref.watch(pantallaTurnosProvider);

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
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: CurrentTurnCard(
                            turnoActual: data.turnoActual,
                            onLlamarSiguiente: () => ref
                                .read(pantallaTurnosProvider.notifier)
                                .llamarSiguiente(),
                            onRellamar: () => ref
                                .read(pantallaTurnosProvider.notifier)
                                .rellamarActual(),
                            onAtender: () => ref
                                .read(pantallaTurnosProvider.notifier)
                                .atenderActual(),
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
