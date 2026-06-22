import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(loginProvider);

    ref.listen(appSessionProvider, (_, session) {
      if (session != null) context.go('/');
    });

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.storefront_rounded, size: 64, color: colors.primary),
                const SizedBox(height: 12),
                Text(
                  'Mostrador AU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.step == LoginStep.credentials
                      ? _CredentialsForm(
                          key: const ValueKey('credentials'),
                          formKey: _formKey,
                          loginCtrl: _loginCtrl,
                          passwordCtrl: _passwordCtrl,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          loading: state.loading,
                          errorMessage: state.errorMessage,
                          onSubmit: () {
                            if (!_formKey.currentState!.validate()) return;
                            ref.read(loginProvider.notifier).login(
                                  login: _loginCtrl.text.trim(),
                                  password: _passwordCtrl.text.trim(),
                                );
                          },
                        )
                      : _AgencySelector(
                          key: const ValueKey('agency'),
                          agencias: state.agencias,
                          selected: state.selectedAgencia,
                          loading: state.loading,
                          onChanged: (a) =>
                              ref.read(loginProvider.notifier).selectAgencia(a!),
                          onConfirm: () =>
                              ref.read(loginProvider.notifier).confirmAgencia(),
                          onBack: () =>
                              ref.read(loginProvider.notifier).goBack(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController loginCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const _CredentialsForm({
    super.key,
    required this.formKey,
    required this.loginCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.loading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: loginCtrl,
            decoration: const InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa tu usuario' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: onToggleObscure,
              ),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa tu contraseña' : null,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                errorMessage!,
                style: TextStyle(color: colors.onErrorContainer, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: loading ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AgencySelector extends StatelessWidget {
  final List<Agencia> agencias;
  final Agencia? selected;
  final bool loading;
  final ValueChanged<Agencia?> onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const _AgencySelector({
    super.key,
    required this.agencias,
    required this.selected,
    required this.loading,
    required this.onChanged,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona una agencia',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<Agencia>(
          initialValue: selected,
          decoration: const InputDecoration(
            labelText: 'Agencia',
            prefixIcon: Icon(Icons.business_rounded),
            border: OutlineInputBorder(),
          ),
          items: agencias
              .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(a.agNombre),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: selected == null || loading ? null : onConfirm,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Entrar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onBack,
          child: const Text('Volver'),
        ),
      ],
    );
  }
}
