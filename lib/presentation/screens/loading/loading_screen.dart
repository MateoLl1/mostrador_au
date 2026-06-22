import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateSession());
  }

  Future<void> _validateSession() async {
    final session = ref.read(appSessionProvider);

    if (session == null) {
      context.go('/login');
      return;
    }

    try {
      await ref.read(authRepositoryProvider).login(
            login: session.usLogin,
            password: session.usPassword,
            agenciaId: session.agenciaId,
          );
      if (mounted) context.go('/mostrador');
    } catch (_) {
      // Credenciales inválidas o usuario bloqueado/inactivo
      await ref.read(appSessionProvider.notifier).clearSession();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 72, color: colors.primary),
            const SizedBox(height: 28),
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Verificando sesión...',
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
