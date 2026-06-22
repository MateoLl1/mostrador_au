import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const Panel({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: child,
    );
  }
}
