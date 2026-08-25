import 'package:flutter/material.dart';

class QueueItem extends StatelessWidget {
  final String code;
  final String name;
  final bool isNext;
  final String? canal;

  const QueueItem({
    super.key,
    required this.code,
    required this.name,
    this.isNext = false,
    this.canal,
  });

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                canal!,
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
            child: Text(
              name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
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
