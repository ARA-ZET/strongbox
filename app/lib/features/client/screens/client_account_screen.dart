import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/value_objects.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/client_providers.dart';

/// Account settings: personal info, security, danger zone.
/// Design: client_designs/account_settings/screen.png.
class ClientAccountScreen extends ConsumerStatefulWidget {
  const ClientAccountScreen({super.key});

  @override
  ConsumerState<ClientAccountScreen> createState() =>
      _ClientAccountScreenState();
}

class _ClientAccountScreenState extends ConsumerState<ClientAccountScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _seed() {
    if (_seeded) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    final client = ref.read(currentClientProvider).valueOrNull;
    if (user == null) return;
    _name.text = user.name;
    _phone.text = user.phone ?? '';
    _address.text = client?.address.line1 ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final actions = ref.read(accountActionsProvider.notifier);
      await actions.updateProfile(
          name: _name.text.trim(), phone: _phone.text.trim());
      await actions.updateAddress(Address(line1: _address.text.trim()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save changes: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final email = ref.read(currentUserProvider).valueOrNull?.email;
    if (email == null || email.isEmpty) return;
    await ref.read(authNotifierProvider.notifier).resetPassword(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    }
  }

  Future<void> _requestDeletion() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Request account deletion?',
      message:
          'Deleting your account is permanent. All stored data, delivery '
          'history and billing records will be archived and then removed '
          'after 30 days. Our team will contact you to confirm.',
      isDestructive: true,
      confirmLabel: 'Request Deletion',
    );
    if (!confirmed) return;
    await ref.read(accountActionsProvider.notifier).requestAccountDeletion();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Deletion request logged — our team will be in touch.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final client = ref.watch(currentClientProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;
    _seed();

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final profileRail = Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.md,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.amber, width: 2.5),
              ),
              child: InitialsAvatar(name: user?.name, size: 72),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            Text(user?.name ?? '—', style: tt.titleMedium),
            Text(user?.email ?? '', style: tt.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            if (client != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 4, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'CLIENT ID: '
                  '${client.id.substring(0, client.id.length.clamp(0, 6)).toUpperCase()}',
                  style: tt.bodySmall?.copyWith(letterSpacing: 0.5),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: Colors.transparent,
              borderRadius: AppRadius.sm,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notification Settings'),
                onTap: () => context.go('/client/notifications'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Sign Out',
              icon: Icons.logout,
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).signOut(),
            ),
          ],
        ),
      );

      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal settings ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              boxShadow: AppShadow.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Settings', style: tt.headlineSmall),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth > 560;
                  final name = _field('Full Name', _name, tt);
                  final email = _lockedField(
                      'Email Address', user?.email ?? '', tt);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: name),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: email),
                      ],
                    );
                  }
                  return Column(children: [
                    name,
                    const SizedBox(height: AppSpacing.md),
                    email,
                  ]);
                }),
                const SizedBox(height: AppSpacing.md),
                _field('Phone Number', _phone, tt),
                const SizedBox(height: AppSpacing.md),
                _field('Default Delivery Address', _address, tt),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              _seeded = false;
                              setState(_seed);
                            },
                      child: const Text('Discard'),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.amberDark),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Security ---------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              boxShadow: AppShadow.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.navy),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Security & Access', style: tt.titleMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Account Password', style: tt.labelLarge),
                          Text('Reset via a secure email link',
                              style: tt.bodySmall),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                      onPressed: _changePassword,
                      child: const Text('Change Password'),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Two-Factor Authentication',
                                  style: tt.labelLarge?.copyWith(
                                      color: AppColors.textHint)),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text('COMING SOON',
                                    style: tt.bodySmall?.copyWith(
                                        fontSize: 10,
                                        letterSpacing: 0.5)),
                              ),
                            ],
                          ),
                          Text('Add an extra layer of security to your vault',
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textHint)),
                        ],
                      ),
                    ),
                    const Switch(value: false, onChanged: null),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Danger zone ------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.statusErrorBg,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.statusError),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.statusError),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Danger Zone',
                        style: tt.titleMedium
                            ?.copyWith(color: AppColors.statusError)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Deleting your account is a permanent action. All stored '
                  'data, delivery history, and billing records will be '
                  'archived and then permanently removed after 30 days.',
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusError,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                  ),
                  onPressed: _requestDeletion,
                  child: const Text('Request Account Deletion'),
                ),
              ],
            ),
          ),
        ],
      );

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          children: [
            desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 300, child: profileRail),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: content),
                    ],
                  )
                : Column(
                    children: [
                      profileRail,
                      const SizedBox(height: AppSpacing.lg),
                      content,
                    ],
                  ),
            const SizedBox(height: AppSpacing.lg),
            const ContactUsCard(dense: true),
          ],
        ),
      );
    });
  }

  Widget _field(String label, TextEditingController controller, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextField(controller: controller),
      ],
    );
  }

  Widget _lockedField(String label, String value, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          enabled: false,
          decoration:
              const InputDecoration(suffixIcon: Icon(Icons.lock_outline)),
        ),
      ],
    );
  }
}
