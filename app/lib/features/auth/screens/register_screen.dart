import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_indicator.dart';
import '../providers/auth_provider.dart';

/// Registration & subscription — split layout: navy marketing panel (35%,
/// desktop only) + 3-step form (Profile · Billing · Review).
/// Payment fields are UI-only until Stripe is wired in Stage 7.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _Plan {
  const _Plan(this.name, this.price, this.features, {this.popular = false});

  final String name;
  final String price;
  final List<String> features;
  final bool popular;
}

const _plans = [
  _Plan('Starter', 'R899/mo', ['5 Active Fleets', 'Basic Analytics']),
  _Plan(
    'Professional',
    'R3,499/mo',
    ['Unlimited Fleets', 'Advanced AI Routing', 'API Integration'],
    popular: true,
  ),
  _Plan('Enterprise', 'Custom', ['Global Node Access', 'Dedicated Account Lead']),
];

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _zipController = TextEditingController();

  int _currentStep = 0;
  int _selectedPlan = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _nextFromProfile() {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    setState(() => _currentStep = 1);
  }

  Future<void> _submit() async {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: StepIndicator(
                  steps: const ['Profile', 'Billing', 'Review'],
                  currentStep: _currentStep,
                ),
              ),
              const SizedBox(height: 40),
              switch (_currentStep) {
                0 => _ProfileStep(
                    formKey: _profileFormKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    onNext: _nextFromProfile,
                  ),
                1 => _BillingStep(
                    selectedPlan: _selectedPlan,
                    onPlanSelected: (index) =>
                        setState(() => _selectedPlan = index),
                    cardController: _cardController,
                    expiryController: _expiryController,
                    cvcController: _cvcController,
                    zipController: _zipController,
                    onBack: () => setState(() => _currentStep = 0),
                    onNext: () => setState(() => _currentStep = 2),
                  ),
                _ => _ReviewStep(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    plan: _plans[_selectedPlan],
                    loading: loading,
                    onBack: () => setState(() => _currentStep = 1),
                    onSubmit: _submit,
                  ),
              },
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
                              color: AppColors.amberDark,
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
      color: AppColors.navy,
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
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.navy, size: 20),
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
              'Enterprise Logistics Reimagined',
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              "Streamline your global operations with the industry's most "
              'robust asset management framework.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 40),
            const _FeatureBullet(
              icon: Icons.shield_outlined,
              title: 'Secure Architecture',
              description:
                  'Military-grade encryption for all shipment data and financial records.',
            ),
            const SizedBox(height: 24),
            const _FeatureBullet(
              icon: Icons.location_on_outlined,
              title: 'Global Tracking',
              description:
                  'Real-time GPS telemetry across 140+ countries with zero latency.',
            ),
            const SizedBox(height: 24),
            const _FeatureBullet(
              icon: Icons.hub_outlined,
              title: 'Smart Network',
              description:
                  'AI-driven route optimization and automated fleet dispatching.',
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
          child: Icon(icon, color: AppColors.amber, size: 24),
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
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Profile
// ---------------------------------------------------------------------------

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Your Profile', style: textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Tell us who you are — you can add your team later.',
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
            decoration: const InputDecoration(hintText: 'name@company.com'),
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
          PrimaryButton(label: 'Continue to Billing', onPressed: onNext),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Billing
// ---------------------------------------------------------------------------

class _BillingStep extends StatelessWidget {
  const _BillingStep({
    required this.selectedPlan,
    required this.onPlanSelected,
    required this.cardController,
    required this.expiryController,
    required this.cvcController,
    required this.zipController,
    required this.onBack,
    required this.onNext,
  });

  final int selectedPlan;
  final ValueChanged<int> onPlanSelected;
  final TextEditingController cardController;
  final TextEditingController expiryController;
  final TextEditingController cvcController;
  final TextEditingController zipController;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Choose Plan', style: textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'Select the operational scale that fits your business needs.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 640;
            final cards = [
              for (var i = 0; i < _plans.length; i++)
                _PlanCard(
                  plan: _plans[i],
                  selected: i == selectedPlan,
                  onTap: () => onPlanSelected(i),
                ),
            ];
            if (horizontal) {
              // IntrinsicHeight bounds the Row so stretch can equalise card
              // heights; bare stretch here would demand infinite height
              // inside the scroll view and blank the whole step.
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, card) in cards.indexed) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(child: card),
                    ],
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final (i, card) in cards.indexed) ...[
                  if (i > 0) const SizedBox(height: 16),
                  card,
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card_outlined, size: 22),
                  const SizedBox(width: 10),
                  Text('Payment Details', style: textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              Text('Card Number', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: cardController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: '0000 0000 0000 0000'),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expiry', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: expiryController,
                          decoration:
                              const InputDecoration(hintText: 'MM / YY'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CVC', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: cvcController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '123'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Billing Zip', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: zipController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '10001'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Continue to Review', onPressed: onNext),
              const SizedBox(height: 20),
              const _TrustBadges(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onBack, child: const Text('← Back to Profile')),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.amberDark : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(plan.name, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  plan.price,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                for (final feature in plan.features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.statusSuccess),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(feature, style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (plan.popular)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        for (final (icon, label) in [
          (Icons.lock_outline, 'SSL ENCRYPTED'),
          (Icons.verified_user_outlined, 'PCI COMPLIANT'),
          (Icons.shield_outlined, 'SECURE CHECKOUT'),
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: style),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Review
// ---------------------------------------------------------------------------

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.name,
    required this.email,
    required this.phone,
    required this.plan,
    required this.loading,
    required this.onBack,
    required this.onSubmit,
  });

  final String name;
  final String email;
  final String phone;
  final _Plan plan;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Review & Confirm', style: textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'Double-check your details before finishing setup.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _ReviewRow(label: 'Full Name', value: name),
              const Divider(height: 24),
              _ReviewRow(label: 'Email', value: email),
              const Divider(height: 24),
              _ReviewRow(label: 'Phone', value: phone),
              const Divider(height: 24),
              _ReviewRow(label: 'Plan', value: '${plan.name} — ${plan.price}'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Subscribe & Finish Setup',
          onPressed: onSubmit,
          loading: loading,
        ),
        const SizedBox(height: 12),
        Text(
          'By clicking "Subscribe & Finish Setup", you agree to StrongBox\'s '
          'Terms of Service and Privacy Policy.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onBack, child: const Text('← Back to Billing')),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: textTheme.labelLarge,
        ),
      ],
    );
  }
}
