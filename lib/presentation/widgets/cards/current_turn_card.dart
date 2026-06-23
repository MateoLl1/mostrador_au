import 'package:flutter/material.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/widgets/buttons/action_button.dart';
import 'package:mostrador_au/presentation/widgets/shared/panel.dart';

class CurrentTurnCard extends StatelessWidget {
  final Turno? turnoActual;
  final VoidCallback onLlamarSiguiente;
  final VoidCallback onRellamar;
  final VoidCallback onAtender;
  final VoidCallback onSaltar;

  const CurrentTurnCard({
    super.key,
    required this.turnoActual,
    required this.onLlamarSiguiente,
    required this.onRellamar,
    required this.onAtender,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tieneTurno = turnoActual != null;
    final turnoTexto = turnoActual?.turno.trim().isNotEmpty == true
        ? turnoActual!.turno.trim()
        : '-';
    final cliente = turnoActual?.nombreCliente.trim().isNotEmpty == true
        ? turnoActual!.nombreCliente.trim()
        : 'Sin turno en atención';

    return Panel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TURNO ACTUAL',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 150,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .7),
                width: 1.4,
              ),
            ),
            child: Text(
              turnoTexto,
              style: TextStyle(
                color: tieneTurno ? colors.primary : colors.onSurfaceVariant,
                fontSize: 48,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            cliente,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 448,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        text: 'Llamar siguiente',
                        icon: Icons.phone_in_talk_rounded,
                        background: colors.primary,
                        foreground: colors.onPrimary,
                        onPressed: tieneTurno ? null : onLlamarSiguiente,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        text: 'Re-llamar',
                        icon: Icons.replay_rounded,
                        background: colors.surfaceContainerHighest,
                        foreground: colors.onSurfaceVariant,
                        onPressed: tieneTurno ? onRellamar : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        text: 'Atender',
                        icon: Icons.check_circle_outline_rounded,
                        background: colors.tertiaryContainer,
                        foreground: colors.onTertiaryContainer,
                        onPressed: tieneTurno ? onAtender : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
                        text: 'Saltar',
                        icon: Icons.skip_next_rounded,
                        background: colors.errorContainer,
                        foreground: colors.onErrorContainer,
                        onPressed: tieneTurno ? onSaltar : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
