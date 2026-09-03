import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Login — navy full-screen background.
/// Desktop (>768px): centred 480px card + stats chips below.
/// Mobile: amber logo header + "Welcome Back" card.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberDevice = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }
    await ref.read(authNotifierProvider.notifier).resetPassword(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Surface auth errors as snackbars. A Google-only account gets a
    // one-tap "Use Google" action instead of a dead-end error.
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        if (error is AppException &&
            error.code == AuthErrorCodes.useGoogle) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppColors.navy,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Use Google',
                textColor: AppColors.amber,
                onPressed: _signInWithGoogle,
              ),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                error is AppException ? error.message : error.toString()),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    });

    final loading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _DesktopLayout(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onSignIn: _signIn,
              onGoogle: _signInWithGoogle,
              onForgotPassword: _forgotPassword,
              loading: loading,
            );
          }
          return _MobileLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            obscurePassword: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            rememberDevice: _rememberDevice,
            onToggleRemember: (value) =>
                setState(() => _rememberDevice = value ?? false),
            onSignIn: _signIn,
            onGoogle: _signInWithGoogle,
            onForgotPassword: _forgotPassword,
            loading: loading,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.onGoogle,
    required this.onForgotPassword,
    required this.loading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Container(
              width: 480,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _BoxLogo(color: AppColors.navy)),
                    const SizedBox(height: 20),
                    Text(
                      'StrongBox Logistics',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall
                          ?.copyWith(color: AppColors.navy),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your stuff. Safe. Tracked. Delivered.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Text('Email Address', style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    _EmailField(controller: emailController),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: textTheme.labelLarge),
                        TextButton(
                          onPressed: onForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: passwordController,
                      obscure: obscurePassword,
                      onToggleObscure: onToggleObscure,
                      onSubmitted: onSignIn,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Sign In',
                      onPressed: onSignIn,
                      loading: loading,
                    ),
                    const SizedBox(height: 24),
                    const _OrDivider(label: 'or continue with'),
                    const SizedBox(height: 24),
                    _GoogleButton(onPressed: onGoogle),
                    const SizedBox(height: 24),
                    // Wrap, not Row: the prompt and the link run past the
                    // panel width once the user's text scale is turned up.
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        InkWell(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create an account',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.amberDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: InkWell(
                        onTap: () => context.go('/quote'),
                        child: Text(
                          'Not sure which plan? Get an instant quote',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 480,
              child: Row(
                children: [
                  Expanded(
                      child: _StatChip(value: '2.4M', label: 'Packages')),
                  SizedBox(width: 16),
                  Expanded(child: _StatChip(value: '99.9%', label: 'Uptime')),
                  SizedBox(width: 16),
                  Expanded(child: _StatChip(value: '12k+', label: 'Fleet')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(width: 480, child: ContactUsCard()),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.rememberDevice,
    required this.onToggleRemember,
    required this.onSignIn,
    required this.onGoogle,
    required this.onForgotPassword,
    required this.loading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool rememberDevice;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onSignIn;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Center(child: _BoxLogo(color: AppColors.amber, iconColor: AppColors.navy)),
            const SizedBox(height: 20),
            Text(
              'StrongBox Logistics',
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Enterprise Fleet Management',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Welcome Back',
                        style: textTheme.displaySmall
                            ?.copyWith(color: AppColors.navy)),
                    const SizedBox(height: 24),
                    Text(
                      'WORK EMAIL',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EmailField(controller: emailController),
                    const SizedBox(height: 20),
                    Text(
                      'SECURITY KEY',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: passwordController,
                      obscure: obscurePassword,
                      onToggleObscure: onToggleObscure,
                      onSubmitted: onSignIn,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberDevice,
                              onChanged: onToggleRemember,
                            ),
                            Text('Remember device',
                                style: textTheme.bodyMedium),
                          ],
                        ),
                        InkWell(
                          onTap: onForgotPassword,
                          child: Text(
                            'Forgot access?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.amberDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'SIGN IN',
                      onPressed: onSignIn,
                      loading: loading,
                    ),
                    const SizedBox(height: 24),
                    const _OrDivider(label: 'OR AUTHORIZE WITH'),
                    const SizedBox(height: 24),
                    _GoogleButton(onPressed: onGoogle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'New dispatcher? ',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                InkWell(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Contact System Admin',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: InkWell(
                onTap: () => context.go('/quote'),
                child: Text(
                  'Not sure which plan? Get an instant quote',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ContactUsCard(dense: true),
            const SizedBox(height: 20),
            Text(
              'Privacy Policy   •   Terms of Service',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

class _BoxLogo extends StatelessWidget {
  const _BoxLogo({required this.color, this.iconColor = Colors.white});

  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.inventory_2_outlined, color: iconColor, size: 32),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        hintText: 'name@company.com',
        prefixIcon: Icon(Icons.mail_outline,
            size: 20, color: AppColors.textSecondary),
      ),
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Email is required';
        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (value) => onSubmitted(),
      decoration: InputDecoration(
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline,
            size: 20, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggleObscure,
        ),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Password is required' : null,
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          foregroundColor: AppColors.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple "G" mark placeholder until a branded asset is added.
            Text(
              'G',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
