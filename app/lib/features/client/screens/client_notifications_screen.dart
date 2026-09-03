import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/value_objects.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/client_providers.dart';

/// Notification preferences grouped by category with Email/SMS toggles.
/// Design: client_designs/notification_preferences/screen.png.
class ClientNotificationsScreen extends ConsumerStatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  ConsumerState<ClientNotificationsScreen> createState() =>
      _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState
    extends ConsumerState<ClientNotificationsScreen> {
  NotificationPrefs? _prefs;
  bool _saving = false;

  Future<void> _save(NotificationPrefs prefs) async {
    setState(() => _saving = true);
    try {
      await ref.read(accountActionsProvider.notifier).savePrefs(prefs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save preferences: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final tt = Theme.of(context).textTheme;
    final prefs = _prefs ?? user?.notificationPrefs;

    if (user == null || prefs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    void update(NotificationPrefs next) => setState(() => _prefs = next);

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: tt.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text('Manage your alert preferences',
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.md,
                    boxShadow: AppShadow.card,
                  ),
                  child: Column(
                    children: [
                      _headerRow(tt),
                      _sectionRow(tt, 'DELIVERY UPDATES'),
                      _prefRow(
                        tt,
                        title: 'Driver on the way',
                        subtitle:
                            'Real-time alert when the courier begins transit '
                            'to your location.',
                        email: prefs.pickupStartedEmail,
                        sms: prefs.pickupStartedSms,
                        onEmail: (v) =>
                            update(prefs.copyWith(pickupStartedEmail: v)),
                        onSms: (v) =>
                            update(prefs.copyWith(pickupStartedSms: v)),
                      ),
                      _prefRow(
                        tt,
                        title: 'Delivery completed',
                        subtitle:
                            'Confirmation and proof of delivery once items '
                            'reach their destination.',
                        email: prefs.deliveryCompletedEmail,
                        sms: prefs.deliveryCompletedSms,
                        onEmail: (v) => update(
                            prefs.copyWith(deliveryCompletedEmail: v)),
                        onSms: (v) =>
                            update(prefs.copyWith(deliveryCompletedSms: v)),
                      ),
                      _sectionRow(tt, 'STORAGE UPDATES'),
                      _prefRow(
                        tt,
                        title: 'Storage threshold reached',
                        subtitle:
                            'Alert when you approach your plan\'s unit '
                            'allowance.',
                        email: prefs.storageThresholdEmail,
                        sms: prefs.storageThresholdSms,
                        onEmail: (v) => update(
                            prefs.copyWith(storageThresholdEmail: v)),
                        onSms: (v) =>
                            update(prefs.copyWith(storageThresholdSms: v)),
                      ),
                      _sectionRow(tt, 'BILLING'),
                      _prefRow(
                        tt,
                        title: 'Invoice ready',
                        subtitle:
                            'Notification when new monthly statements are '
                            'available for download.',
                        email: prefs.invoiceReadyEmail,
                        sms: prefs.invoiceReadySms,
                        onEmail: (v) =>
                            update(prefs.copyWith(invoiceReadyEmail: v)),
                        onSms: (v) =>
                            update(prefs.copyWith(invoiceReadySms: v)),
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _save(prefs),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.amberDark),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Preferences'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const ContactUsCard(dense: true),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _headerRow(TextTheme tt) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        child: Row(
          children: [
            Expanded(
              child: Text('ALERT TYPE',
                  style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
            SizedBox(
              width: 72,
              child: Text('EMAIL',
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
            SizedBox(
              width: 72,
              child: Text('SMS',
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ),
          ],
        ),
      );

  Widget _sectionRow(TextTheme tt, String label) => Container(
        width: double.infinity,
        color: AppColors.surfaceContainer,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Text(label,
            style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.amberDark)),
      );

  Widget _prefRow(
    TextTheme tt, {
    required String title,
    required String subtitle,
    required bool email,
    required bool sms,
    required ValueChanged<bool> onEmail,
    required ValueChanged<bool> onSms,
    bool last = false,
  }) =>
      Container(
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tt.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: tt.bodySmall),
                ],
              ),
            ),
            SizedBox(
              width: 72,
              child: Switch(
                value: email,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.amber,
                onChanged: onEmail,
              ),
            ),
            SizedBox(
              width: 72,
              child: Switch(
                value: sms,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.amber,
                onChanged: onSms,
              ),
            ),
          ],
        ),
      );
}
