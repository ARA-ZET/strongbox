import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Confirms a driver invite and offers the password-setup link to copy —
/// for sharing by WhatsApp/SMS, or before email delivery is set up.
class InviteLinkDialog extends StatelessWidget {
  const InviteLinkDialog({super.key, required this.email, required this.link});

  final String email;
  final String link;

  static Future<void> show(BuildContext context,
          {required String email, required String link}) =>
      showDialog<void>(
        context: context,
        builder: (_) => InviteLinkDialog(email: email, link: link),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Invite sent'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We emailed $email a link to set their password. You can also '
              'send them this link yourself — it works for one hour.',
              style: tt.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: AppRadius.sm,
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(link,
                  maxLines: 3,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy link'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invite link copied')),
            );
          },
        ),
      ],
    );
  }
}
