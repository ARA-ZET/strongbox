import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/business_settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Prominent "talk to a human" card — call/email CTAs.
///
/// StrongBox is a new business; this is the trust signal that a real
/// person is reachable at any stage, not just a self-serve flow. Used on
/// login/register and across the client
/// portal (doc: not in the original spec docs — added on direct request).
class ContactUsCard extends ConsumerWidget {
  const ContactUsCard({
    super.key,
    this.title = 'Need help? Talk to a real person.',
    this.subtitle = "We're a new team, so we'd rather talk than leave you "
        'guessing — call or email any time.',
    this.dense = false,
  });

  final String title;
  final String subtitle;

  /// Tighter padding for screens where the card is a secondary element
  /// (e.g. below a data table) rather than the page's main content.
  final bool dense;

  Future<void> _launch(String uri) =>
      launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final contact = ref.watch(businessSettingsProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: AppColors.navy),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: tt.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm + 4,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44)),
                onPressed: () => _launch(contact.phoneUri),
                icon: const Icon(Icons.call, size: 18),
                label: Text(contact.contactPhone),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44)),
                onPressed: () => _launch(contact.emailUri),
                icon: const Icon(Icons.email_outlined, size: 18),
                label: Text(contact.contactEmail),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
