import 'package:flutter/material.dart';

class QueueItem extends StatelessWidget {
  final String code;
  final String name;
  final bool isNext;

  const QueueItem({
    super.key,
    required this.code,
    required this.name,
    this.isNext = false,
  });

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
