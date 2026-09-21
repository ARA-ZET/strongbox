import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/pricing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// Client sign-up — split layout: navy panel (35%, desktop only) + a single
/// profile form. The website's "Get Started" buttons land here; pricing and
/// packages are chosen on the site, so there is no billing or review step —
/// the new client goes straight to their portal. Storage is billed monthly.
/// Card capture arrives with Stripe Checkout in Stage 7.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
    // Role-based redirect to /client/dashboard is handled by the router.
  }

  /// The email already belongs to a Google account — offer to sign in with
  /// Google and link this password onto the SAME account (one uid).
  Future<void> _offerGoogleLink(String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Account already exists'),
        content: Text(
          '$message\n\nAfter linking you can sign in with either Google '
          'or your email and password — both reach the same account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Go to Sign In'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue with Google'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      context.go('/login');
      return;
    }
    await ref.read(authNotifierProvider.notifier).linkPasswordWithGoogle(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        if (error is AppException &&
            error.code == AuthErrorCodes.linkGoogle) {
          _offerGoogleLink(error.message);
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

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.35,
                  child: const _MarketingPanel(),
                ),
                Expanded(child: _buildForm(context)),
              ],
            );
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _ProfileStep(
                formKey: _profileFormKey,
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
                passwordController: _passwordController,
                onSubmit: _submit,
                loading: loading,
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    InkWell(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accentDeep,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const ContactUsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Left marketing panel (desktop only)
// ---------------------------------------------------------------------------

class _MarketingPanel extends StatelessWidget {
  const _MarketingPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.navyDeep,
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.onAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'StrongBox',
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              'Storage that comes to you',
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Cape Town's valet storage service. We collect, store and "
              'return your belongings on demand — without you leaving home.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.onNavyVariant),
            ),
            const SizedBox(height: 40),
            _FeatureBullet(
              icon: Icons.local_shipping_outlined,
              title: 'We collect',
              description: 'From your door, anywhere in Cape Town. Pickup '
                  'from ${formatZar(Pricing.pickupFrom)} once-off.',
            ),
            const SizedBox(height: 24),
            _FeatureBullet(
              icon: Icons.inventory_2_outlined,
              title: 'Pay per box',
              description: 'From ${formatZar(Pricing.boxFrom)}/month per box. '
                  'No minimum term — cancel any time.',
            ),
            const SizedBox(height: 24),
            const _FeatureBullet(
              icon: Icons.photo_camera_outlined,
              title: 'See everything you store',
              description: 'Every box is photographed and barcoded to your '
                  'account at collection.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.sky, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.onNavyVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profile form
// ---------------------------------------------------------------------------

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onSubmit,
    required this.loading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Your Account', style: textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Takes a minute — you\'ll go straight to your account.',
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Text('Full Name', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Jane Doe'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Name is required'
                : null,
          ),
          const SizedBox(height: 20),
          Text('Email Address', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'you@example.com'),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text('Phone Number', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+27 82 000 0000'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Phone is required'
                : null,
          ),
          const SizedBox(height: 20),
          Text('Password', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Min. 8 characters'),
            validator: (value) => (value == null || value.length < 8)
                ? 'Password must be at least 8 characters'
                : null,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Create Account',
            onPressed: onSubmit,
            loading: loading,
          ),
          const SizedBox(height: 12),
          Text(
            'By creating an account you agree to StrongBox\'s Terms of '
            'Service and Privacy Policy. Nothing is charged until we collect.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
