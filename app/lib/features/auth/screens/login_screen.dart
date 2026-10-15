import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/contact_info.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Login — navy full-screen background.
/// Desktop (>768px): centred 480px card + stats chips below.
/// Mobile: accent logo header + "Welcome Back" card.
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
    await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first')));
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
        if (error is AppException && error.code == AuthErrorCodes.useGoogle) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppColors.navy,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Use Google',
                textColor: AppColors.sky,
                onPressed: _signInWithGoogle,
              ),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AppException ? error.message : error.toString(),
            ),
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

/// Pricing and quotes live on the marketing site; the app is for accounts.
void _openPricing() => launchUrl(
  Uri.parse(ContactInfo.pricingUrl),
  mode: LaunchMode.externalApplication,
);

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

  /// Below this width the brand panel would squeeze the form, so the page
  /// falls back to the card alone.
  static const _splitBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context) {
    final card = _SignInCard(
      formKey: formKey,
      emailController: emailController,
      passwordController: passwordController,
      obscurePassword: obscurePassword,
      onToggleObscure: onToggleObscure,
      onSignIn: onSignIn,
      onGoogle: onGoogle,
      onForgotPassword: onForgotPassword,
      loading: loading,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final split = constraints.maxWidth >= _splitBreakpoint;

        // Everything is sized to fit a ~640px-tall browser viewport (a
        // 1366×768 laptop once browser chrome is taken off). Shorter windows
        // scroll rather than clip: the min-height keeps the layout filling
        // the screen whenever it does fit.
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: split
                // IntrinsicHeight lets the two halves stretch to full height.
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(flex: 5, child: _BrandPanel()),
                        Expanded(
                          flex: 6,
                          child: ColoredBox(
                            color: AppColors.scaffold,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: card,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          card,
                          const SizedBox(height: 12),
                          const _ContactLine(onNavy: true, showLead: false),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

/// Navy left half of the desktop sign-in: who we are, and a human to call.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget bullet(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.sky),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.onNavy),
            ),
          ),
        ],
      ),
    );

    return ColoredBox(
      color: AppColors.navyDeep,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandLogo(onDark: true),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your stuff. Safe. Tracked. Delivered.',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to see everything we store for you, request a '
                    'delivery, or manage your account.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onNavyVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  bullet(
                    Icons.photo_camera_outlined,
                    'Every box photographed and barcoded to your account',
                  ),
                  bullet(
                    Icons.local_shipping_outlined,
                    'Next-day delivery back to your door',
                  ),
                  bullet(
                    Icons.shield_outlined,
                    'Monitored, climate-controlled facility in Cape Town',
                  ),
                ],
              ),
            ),
            const Spacer(),
            const _ContactLine(onNavy: true),
          ],
        ),
      ),
    );
  }
}

/// One-line "talk to a human" — phone and email, in the space a full
/// [ContactUsCard] would take three lines for.
class _ContactLine extends ConsumerWidget {
  const _ContactLine({required this.onNavy, this.showLead = true});

  final bool onNavy;

  /// The "Need help?" prompt — dropped where height is tight.
  final bool showLead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(businessSettingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final muted = onNavy ? AppColors.onNavyVariant : AppColors.textSecondary;
    final link = onNavy ? AppColors.sky : AppColors.accentDeep;

    Widget action(IconData icon, String label, String uri) => InkWell(
      onTap: () =>
          launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: link),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: link,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Wrap(
      spacing: 20,
      runSpacing: 4,
      alignment: showLead ? WrapAlignment.start : WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showLead)
          Text(
            'Need help? Talk to a real person.',
            style: textTheme.bodyMedium?.copyWith(color: muted),
          ),
        action(Icons.call, contact.contactPhone, contact.phoneUri),
        action(Icons.email_outlined, contact.contactEmail, contact.emailUri),
      ],
    );
  }
}

/// The compact desktop sign-in form.
class _SignInCard extends StatelessWidget {
  const _SignInCard({
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

    return Container(
      width: 420,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Sign in to manage your storage.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Email Address', style: textTheme.labelLarge),
            const SizedBox(height: 6),
            _EmailField(controller: emailController),
            const SizedBox(height: 16),
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
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.accentDeep,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _PasswordField(
              controller: passwordController,
              obscure: obscurePassword,
              onToggleObscure: onToggleObscure,
              onSubmitted: onSignIn,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Sign In',
              onPressed: onSignIn,
              loading: loading,
            ),
            const SizedBox(height: 16),
            const _OrDivider(label: 'or'),
            const SizedBox(height: 16),
            _GoogleButton(onPressed: onGoogle),
            const SizedBox(height: 20),
            // Wrap, not Row: the prompt and the link run past the card
            // width once the user's text scale is turned up.
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Create one',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  ' · ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                InkWell(
                  onTap: _openPricing,
                  child: Text(
                    'See pricing',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentDeep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
            const Center(child: BrandMark(size: 64, onDark: true)),
            const SizedBox(height: 20),
            Text(
              'StrongBox Logistics',
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Your stuff. Safe. Tracked. Delivered.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
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
                    Text(
                      'Welcome Back',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'EMAIL',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EmailField(controller: emailController),
                    const SizedBox(height: 20),
                    Text(
                      'PASSWORD',
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
                            Text(
                              'Remember device',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: onForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.accentDeep,
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
                    const _OrDivider(label: 'OR'),
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
                  "Don't have an account? ",
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Create one',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.sky,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: InkWell(
                onTap: _openPricing,
                child: Text(
                  'New to StrongBox? See our pricing',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const ContactUsCard(dense: true),
            const SizedBox(height: 20),
            Text(
              'Privacy Policy   •   Terms of Service',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
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
        prefixIcon: Icon(
          Icons.mail_outline,
          size: 20,
          color: AppColors.textSecondary,
        ),
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
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: AppColors.textSecondary,
        ),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
            const Flexible(
              child: Text(
                'Continue with Google',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
