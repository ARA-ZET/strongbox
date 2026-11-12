import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/account_closure.dart';
import '../../../core/widgets/closure_checklist.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/dialog_actions.dart';
import '../providers/account_closure_providers.dart';

final _date = DateFormat('d MMMM y');

void _toast(BuildContext context, Object messageOrError) {
  final text = switch (messageOrError) {
    AppException(:final message) => message,
    String text => text,
    _ => 'Something went wrong: $messageOrError',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

/// A client's account closure on their admin page: while pending, the
/// date, what's left to do, and Cancel / Close now; once closed, what was
/// removed and how long the rest is kept (functions/src/closure.js).
class AccountClosureCard extends ConsumerStatefulWidget {
  const AccountClosureCard({super.key, required this.client});

  final Client client;

  @override
  ConsumerState<AccountClosureCard> createState() => _AccountClosureCardState();
}

class _AccountClosureCardState extends ConsumerState<AccountClosureCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) _toast(context, done);
    } catch (error) {
      if (mounted) _toast(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keep this account open?',
      message:
          'The closure is cancelled and the client is told their '
          'account stays open.',
      confirmLabel: 'Keep open',
    );
    if (!confirmed) return;
    await _run(
      () => ref
          .read(accountClosureActionsProvider.notifier)
          .cancel(widget.client.id),
      'Closure cancelled. The account stays open.',
    );
  }

  Future<void> _closeNow() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Close this account now?',
      message:
          'Their sign-in is deleted and their phone number, addresses, '
          'notifications and emails are cleared straight away. This can\'t '
          'be undone. $closureKeptSummary',
      confirmLabel: 'Close now',
      isDestructive: true,
    );
    if (!confirmed) return;
    await _run(
      () => ref
          .read(accountClosureActionsProvider.notifier)
          .closeNow(widget.client.id),
      'Account closed.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final closure = widget.client.closure;
    if (closure == null) return const SizedBox.shrink();
    final tt = Theme.of(context).textTheme;

    final (
      Color bg,
      Color fg,
      IconData icon,
      String title,
    ) = switch (closure.status) {
      ClosureStatus.requested => (
        AppColors.statusPastDueBg,
        AppColors.statusPastDue,
        Icons.event_busy,
        closure.scheduledFor == null
            ? 'Account closing'
            : 'Account closes on ${_date.format(closure.scheduledFor!)}',
      ),
      ClosureStatus.closed => (
        AppColors.statusErrorBg,
        AppColors.statusError,
        Icons.lock_outline,
        closure.closedAt == null
            ? 'Account closed'
            : 'Account closed on ${_date.format(closure.closedAt!)}',
      ),
      ClosureStatus.purged => (
        AppColors.surfaceContainer,
        AppColors.textSecondary,
        Icons.delete_outline,
        'Records removed',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.md,
        border: Border.all(color: fg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: tt.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...switch (closure.status) {
            ClosureStatus.requested => _pending(closure, tt),
            ClosureStatus.closed => _closed(closure, tt),
            ClosureStatus.purged => [
              Text(
                'Name, email, photos, signatures and item descriptions '
                'were deleted'
                '${closure.purgedAt == null ? '' : ' on ${_date.format(closure.purgedAt!)}'}. '
                'Invoices are kept: they show only the account number.',
                style: tt.bodyMedium,
              ),
            ],
          },
        ],
      ),
    );
  }

  List<Widget> _pending(AccountClosure closure, TextTheme tt) {
    final blockers = ref.watch(clientClosureBlockersProvider(widget.client.id));
    final who = closure.requestedByRole == UserRole.admin
        ? 'Started by an admin'
        : 'Requested by the client';
    final when = closure.requestedAt == null
        ? ''
        : ' on ${_date.format(closure.requestedAt!)}';

    return [
      Text(
        '$who$when. It closes automatically on that date once everything '
        'below is done, or later, as soon as it is.',
        style: tt.bodyMedium,
      ),
      if (closure.reason != null && closure.reason!.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Note: ${closure.reason}',
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      ClosureChecklist(blockers: blockers, forClient: false),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: _busy ? null : _cancel,
            child: const Text('Cancel closure'),
          ),
          DestructiveButton(
            label: 'Close now',
            icon: Icons.lock_outline,
            onPressed: _busy || blockers.isNotEmpty ? null : _closeNow,
          ),
        ],
      ),
      if (blockers.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          '"Close now" unlocks when every check is ticked.',
          style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ];
  }

  List<Widget> _closed(AccountClosure closure, TextTheme tt) {
    final until = closure.retainUntil;
    return [
      Text('Removed: $closureClearedSummary', style: tt.bodyMedium),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Kept${until == null ? '' : ' until ${_date.format(until)}'}: name, '
        'email, invoices, order history, photos and signatures, for tax '
        'records and claims. They are deleted automatically after that.',
        style: tt.bodyMedium,
      ),
    ];
  }
}

/// Starts closing [client]'s account on their behalf — e.g. they asked by
/// email or phone. Returns true when started.
class StartClosureDialog extends ConsumerStatefulWidget {
  const StartClosureDialog({super.key, required this.client});

  final Client client;

  static Future<bool> show(BuildContext context, Client client) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => StartClosureDialog(client: client),
      ) ??
      false;

  @override
  ConsumerState<StartClosureDialog> createState() => _StartClosureDialogState();
}

class _StartClosureDialogState extends ConsumerState<StartClosureDialog> {
  final _reason = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final date = await ref
          .read(accountClosureActionsProvider.notifier)
          .start(widget.client.id, reason: _reason.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      _toast(
        context,
        'Account closes on ${_date.format(date)}. '
        'The client has been told.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Close ${widget.client.displayName}\'s account',
                style: tt.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'For a client who asked by email or phone. It closes in '
                '$closureGraceDays days, once their items are back and '
                'invoices are settled. They are emailed and can cancel '
                'until then.',
                style: tt.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Deleted when it closes: $closureClearedSummary',
                style: tt.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Kept: $closureKeptSummary', style: tt.bodySmall),
              const SizedBox(height: AppSpacing.md),
              Text('How did they ask? (optional)', style: tt.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _reason,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'e.g. Emailed support on 12 Nov',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DialogActions(
                saving: _saving,
                onSave: _save,
                saveLabel: 'Start closure',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
