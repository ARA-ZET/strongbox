import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/fleet_providers.dart';

/// Confirms a driver invite: whether the invite email went out (live, from
/// the onMailCreated function) and the password-setup link to copy — for
/// WhatsApp/SMS, or when the email could not be sent.
class InviteLinkDialog extends StatelessWidget {
  const InviteLinkDialog({
    super.key,
    required this.email,
    required this.link,
    this.mailId,
  });

  final String email;
  final String link;

  /// The invite's `mail` doc; null hides the delivery line.
  final String? mailId;

  static Future<void> show(
    BuildContext context, {
    required String email,
    required String link,
    String? mailId,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) =>
            InviteLinkDialog(email: email, link: link, mailId: mailId),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final id = mailId;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Driver invited'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (id != null && id.isNotEmpty) ...[
              _EmailStatusLine(mailId: id, email: email),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              'Setup link — works for one hour. You can send it to them '
              'yourself, e.g. on WhatsApp:',
              style: tt.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
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

/// "Sending…" → "Emailed to …" or "Couldn't email … (reason)". If the
/// mail service never answers (e.g. email isn't set up), stops waiting
/// after [_patience] and points to the link.
class _EmailStatusLine extends ConsumerStatefulWidget {
  const _EmailStatusLine({required this.mailId, required this.email});

  final String mailId;
  final String email;

  @override
  ConsumerState<_EmailStatusLine> createState() => _EmailStatusLineState();
}

const _patience = Duration(seconds: 30);

class _EmailStatusLineState extends ConsumerState<_EmailStatusLine> {
  Timer? _timer;
  bool _gaveUp = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_patience, () {
      if (mounted) setState(() => _gaveUp = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final email = widget.email;
    final status =
        ref.watch(inviteEmailStatusProvider(widget.mailId)).valueOrNull;
    var state = status?.state ?? EmailDeliveryState.sending;
    if (state == EmailDeliveryState.sending && _gaveUp) {
      state = EmailDeliveryState.failed;
    }

    final (Widget icon, String text, Color colour) = switch (state) {
      EmailDeliveryState.sending => (
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          'Sending the invite email to $email…',
          AppColors.textSecondary,
        ),
      EmailDeliveryState.sent => (
          const Icon(Icons.mark_email_read_outlined,
              size: 20, color: AppColors.statusSuccess),
          'Invite emailed to $email.',
          AppColors.statusSuccess,
        ),
      EmailDeliveryState.failed => (
          const Icon(Icons.error_outline,
              size: 20, color: AppColors.statusError),
          status?.state == EmailDeliveryState.failed
              ? 'Couldn\'t email $email${status?.error == null ? '' : ' — '
                  '${status!.error}'}. Send them the link below instead.'
              : 'No word from the email service yet — if $email doesn\'t '
                  'get it, send them the link below.',
          AppColors.statusError,
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: icon),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: tt.bodyMedium?.copyWith(color: colour)),
        ),
      ],
    );
  }
}
