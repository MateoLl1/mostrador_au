import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/presentation/providers/providers.dart';
import 'package:mostrador_au/presentation/screens/painters/login_painter.dart';
import 'package:mostrador_au/presentation/widgets/widgets.dart';

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(loginProvider.notifier).login(
          login: _loginCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(loginProvider);

    ref.listen(appSessionProvider, (_, session) {
      if (session != null) context.go('/mostrador');
    });

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LoginPainter(primaryColor: colors.primary),
            ),
          ),
          _HeroSection(colors: colors),
          _FormCard(
            colors: colors,
            state: state,
            formKey: _formKey,
            loginCtrl: _loginCtrl,
            passwordCtrl: _passwordCtrl,
            obscurePassword: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onSubmit: _submit,
            onSelectAgencia: (a) =>
                ref.read(loginProvider.notifier).selectAgencia(a),
          ),
        ],
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final ColorScheme colors;
  const _HeroSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height * 0.42,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 52,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mostrador AU',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gestión de turnos',
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.50),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final ColorScheme colors;
  final LoginState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController loginCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final void Function(Agencia) onSelectAgencia;

  const _FormCard({
    required this.colors,
    required this.state,
    required this.formKey,
    required this.loginCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onSelectAgencia,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: height * 0.66,
            minHeight: height * 0.58,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: state.initLoading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _LoginForm(
                      colors: colors,
                      state: state,
                      formKey: formKey,
                      loginCtrl: loginCtrl,
                      passwordCtrl: passwordCtrl,
                      obscurePassword: obscurePassword,
                      onToggleObscure: onToggleObscure,
                      onSubmit: onSubmit,
                      onSelectAgencia: onSelectAgencia,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Form content ──────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final ColorScheme colors;
  final LoginState state;
  final GlobalKey<FormState> formKey;
  final TextEditingController loginCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final void Function(Agencia) onSelectAgencia;

  const _LoginForm({
    required this.colors,
    required this.state,
    required this.formKey,
    required this.loginCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onSelectAgencia,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ingresa tus credenciales para continuar',
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.50),
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: loginCtrl,
            label: 'Usuario',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa tu usuario' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: passwordCtrl,
            label: 'Contraseña',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa tu contraseña' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<Agencia>(
            initialValue: state.selectedAgencia,
            decoration: InputDecoration(
              labelText: 'Agencia',
              prefixIcon: const Icon(Icons.business_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: colors.outline.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: colors.outline.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              filled: true,
              fillColor:
                  colors.surfaceContainerHighest.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            borderRadius: BorderRadius.circular(14),
            items: state.agencias
                .map((a) => DropdownMenuItem(
                      value: a,
                      child: Text(a.agNombre),
                    ))
                .toList(),
            onChanged: (a) {
              if (a != null) onSelectAgencia(a);
            },
            validator: (v) =>
                v == null ? 'Selecciona una agencia' : null,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 18, color: colors.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                          color: colors.onErrorContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Ingresar',
            isLoading: state.submitLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
