import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../../core/widgets/secondary_button.dart';
import '../providers/client_providers.dart';

final _date = DateFormat('d MMMM y');

/// Account settings → closing the account. Before asking: what is deleted,
/// what is kept and why. While pending: the closing date, what's left to
/// do, and a way to change their mind (functions/src/closure.js).
class AccountClosureSection extends ConsumerStatefulWidget {
  const AccountClosureSection({super.key});

  @override
  ConsumerState<AccountClosureSection> createState() =>
      _AccountClosureSectionState();
}

class _AccountClosureSectionState extends ConsumerState<AccountClosureSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AppException
                  ? error.message
                  : 'Something went wrong: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _close() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Close your account?',
      message:
          'It closes in $closureGraceDays days, once your items are '
          'back with you and your invoices are settled. Then your sign-in '
          'and contact details are deleted. You can cancel until then.',
      confirmLabel: 'Close my account',
      isDestructive: true,
    );
    if (!confirmed) return;
    await _run(() async {
      final date = await ref
          .read(accountActionsProvider.notifier)
          .requestAccountClosure();
      if (mounted && date != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your account closes on ${_date.format(date)}. '
              "We've emailed you the details.",
            ),
          ),
        );
      }
    });
  }

  Future<void> _keep() => _run(() async {
    await ref.read(accountActionsProvider.notifier).cancelAccountClosure();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your account stays open.')));
    }
  });

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(currentClientProvider).valueOrNull;
    if (client == null) return const SizedBox.shrink();
    return client.isClosing ? _pending(client) : _ask();
  }

  Widget _pending(Client client) {
    final tt = Theme.of(context).textTheme;
    final blockers = ref.watch(myClosureBlockersProvider);
    final due = client.closure?.scheduledFor;
    final holdingItems = blockers.any(
      (b) => b.kind == ClosureBlockerKind.itemsHeld,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.statusPastDueBg,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.statusPastDue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_busy, color: AppColors.statusPastDue),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  due == null
                      ? 'Your account is closing'
                      : 'Your account closes on ${_date.format(due)}',
                  style: tt.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            blockers.isEmpty
                ? "Everything's done. We'll close it on that date."
                : "Before then, finish these. If anything's still "
                      "outstanding on the day, we close it as soon as "
                      "it's done.",
            style: tt.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ClosureChecklist(blockers: blockers, forClient: true),
          const SizedBox(height: AppSpacing.sm),
          if (holdingItems) ...[
            SecondaryButton(
              label: 'Get my items back',
              icon: Icons.local_shipping_outlined,
              onPressed: () => context.go('/client/requests/new'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SecondaryButton(
            label: _busy ? 'Working…' : 'Keep my account',
            onPressed: _busy ? null : _keep,
          ),
        ],
      ),
    );
  }

  Widget _ask() {
    final tt = Theme.of(context).textTheme;
    Widget point(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$title ',
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: body, style: tt.bodyMedium),
          ],
        ),
      ),
    );

    return Container(
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
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.statusError,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Close your account',
                style: tt.titleMedium?.copyWith(color: AppColors.statusError),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your account closes $closureGraceDays days after you ask. '
            'That leaves time to get your items back and settle any '
            'invoices, and you can change your mind until then.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          point('Deleted when it closes:', closureClearedSummary),
          point('Kept:', closureKeptSummary),
          const SizedBox(height: AppSpacing.sm),
          DestructiveButton(
            label: _busy ? 'Working…' : 'Close my account',
            onPressed: _busy ? null : _close,
          ),
        ],
      ),
    );
  }
}
