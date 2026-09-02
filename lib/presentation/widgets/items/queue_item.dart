import 'package:flutter/material.dart';

class QueueItem extends StatelessWidget {
  final String code;
  final String name;
  final bool isNext;
  final String? canal;

  /// Fechas de diagnóstico de la cola: cita y llegada del turno.
  final DateTime? fechaCita;
  final DateTime? fechaLlegada;
  final DateTime? fechaOrden;

  const QueueItem({
    super.key,
    required this.code,
    required this.name,
    this.isNext = false,
    this.canal,
    this.fechaCita,
    this.fechaLlegada,
    this.fechaOrden,
  });

  static String _hora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  /// "Cita 08:00 · Llegó 09:49". La cita solo aparece si el turno la tiene.
  String? get _diagnostico {
    final partes = <String>[
      if (fechaCita != null) 'Cita ${_hora(fechaCita!)}',
      if (fechaLlegada != null) 'Llegó ${_hora(fechaLlegada!)}',
    ];

    return partes.isEmpty ? null : partes.join('  ·  ');
  }

  Color _canalColor(ColorScheme colors) {
    switch (canal) {
      case 'F':
        return const Color(0xFF7C3AED);
      case 'P':
        return const Color(0xFFD97706);
      default:
        return colors.primary;
    }
  }

  /// La API sigue mandando 'R' (Retail) tal cual la clasifica el canal de
  /// atención; en el mostrador se muestra como "L" de Liviano.
  String get _etiquetaCanal => canal == 'R' ? 'L' : (canal ?? '');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final diagnostico = _diagnostico;

    return Container(
      constraints: BoxConstraints(minHeight: diagnostico == null ? 62 : 70),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isNext
            ? colors.primaryContainer.withValues(alpha: .35)
            : colors.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isNext
              ? colors.primary.withValues(alpha: .65)
              : colors.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: Row(
        children: [
          Text(
            code,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (canal != null && canal!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _canalColor(colors).withValues(alpha: .15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _canalColor(colors).withValues(alpha: .55),
                ),
              ),
              child: Text(
                _etiquetaCanal,
                style: TextStyle(
                  color: _canalColor(colors),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (diagnostico != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    diagnostico,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isNext)
            Text(
              'SIGUIENTE',
              style: TextStyle(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}
