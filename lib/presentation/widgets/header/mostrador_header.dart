import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

class MostradorHeader extends ConsumerWidget {
  final int totalEnEspera;

  const MostradorHeader({super.key, required this.totalEnEspera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final session = ref.watch(appSessionProvider);
    final dispState = ref.watch(disponibilidadProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'MOSTRADOR • REPUESTOS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
        ),

        // Botones izquierda — sesión + toggle disponibilidad
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: session?.usNombre ?? 'Sesión',
                style: IconButton.styleFrom(
                  backgroundColor:
                      colors.surfaceContainerHighest.withValues(alpha: .45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: .45)),
                  ),
                ),
                icon: Icon(Icons.person_rounded, color: colors.primary),
                onPressed: () =>
                    _showSessionSheet(context, ref, colors, session),
              ),
              const SizedBox(width: 8),
              _ToggleDisponibilidadButton(state: dispState, colors: colors,
                onToggle: () =>
                    ref.read(disponibilidadProvider.notifier).toggle(),
              ),
            ],
          ),
        ),

        // Contador en espera — derecha
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_rounded, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  totalEnEspera.toString(),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'en espera',
                  style:
                      TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSessionSheet(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
    session,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _SessionSheet(session: session, ref: ref),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _SessionSheet extends StatelessWidget {
  final dynamic session;
  final WidgetRef ref;

  const _SessionSheet({required this.session, required this.ref});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
        
            // Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.person_rounded,
                  size: 34, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 12),
        
            Text(
              session?.usNombre ?? '—',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${session?.usLogin ?? '—'}',
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
        
            // Info tiles
            _InfoTile(
              colors: colors,
              icon: Icons.business_rounded,
              label: 'Agencia',
              value: session?.agenciaNombre ?? '—',
            ),
            const SizedBox(height: 10),
            _InfoTile(
              colors: colors,
              icon: Icons.grid_view_rounded,
              label: 'Módulo',
              value: session?.puModulo?.isNotEmpty == true
                  ? session!.puModulo
                  : 'Sin módulo',
            ),
            const SizedBox(height: 28),
        
            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await ref.read(appSessionProvider.notifier).clearSession();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error.withValues(alpha: .5)),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final ColorScheme colors;
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.colors,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: colors.onSurfaceVariant)),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Toggle disponibilidad ─────────────────────────────────────────────────────

class _ToggleDisponibilidadButton extends StatelessWidget {
  final DisponibilidadState state;
  final ColorScheme colors;
  final VoidCallback onToggle;

  const _ToggleDisponibilidadButton({
    required this.state,
    required this.colors,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActivo = state.isActivo;
    final isLoading = state.isLoading;

    final bgColor = isActivo
        ? colors.primaryContainer
        : colors.surfaceContainerHighest.withValues(alpha: .45);
    final iconColor = isActivo ? colors.primary : colors.onSurfaceVariant;
    final borderColor = isActivo
        ? colors.primary.withValues(alpha: .40)
        : colors.outlineVariant.withValues(alpha: .45);

    return Tooltip(
      message: isActivo ? 'Activo — toca para desactivar' : 'Inactivo — toca para activar',
      child: InkWell(
        onTap: isLoading ? null : onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActivo
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      size: 18,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActivo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
