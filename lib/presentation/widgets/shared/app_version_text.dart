import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  final TextStyle? style;

  const AppVersionText({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null) return const SizedBox.shrink();

        return Text(
          'v$version',
          style: style ??
              TextStyle(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.40),
              ),
        );
      },
    );
  }
}
