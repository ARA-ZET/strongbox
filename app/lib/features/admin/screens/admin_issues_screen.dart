import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/issue_report.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/utils/report_failure.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/clients_providers.dart';
import '../providers/issues_providers.dart';

/// Driver issue reports — breakdowns, damage, wrong addresses, clients not
/// home — for ops to review and resolve.
class AdminIssuesScreen extends ConsumerStatefulWidget {
  const AdminIssuesScreen({super.key});

  @override
  ConsumerState<AdminIssuesScreen> createState() => _AdminIssuesScreenState();
}

class _AdminIssuesScreenState extends ConsumerState<AdminIssuesScreen> {
  bool _showResolved = false;

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(issueReportsProvider);
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;
      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver Issues', style: tt.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Problems drivers reported on the road or at a job.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            FilterChip(
              label: const Text('Show resolved'),
              selected: _showResolved,
              onSelected: (v) => setState(() => _showResolved = v),
            ),
            const SizedBox(height: AppSpacing.md),
            reports.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Could not load issues: $error',
                  style:
                      tt.bodyMedium?.copyWith(color: AppColors.statusError)),
              data: (all) {
                final list = all
                    .where((r) =>
                        _showResolved || r.status != IssueStatus.resolved)
                    .toList();
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'No open issues',
                    subtitle: 'Reports from drivers show up here.',
                  );
                }
                return Column(
                  children: [for (final r in list) _IssueTile(report: r)],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _IssueTile extends ConsumerWidget {
  const _IssueTile({required this.report});

  final IssueReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final driver = ref.watch(driverNamesProvider)[report.driverId] ?? 'Driver';
    final mutations = ref.read(issueMutationsProvider.notifier);
    void set(IssueStatus status) => reportFailure(context,
        'Could not update the issue', () => mutations.setStatus(report, status));

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Icon(
                report.isUrgent
                    ? Icons.priority_high
                    : Icons.report_problem_outlined,
                color: report.isUrgent
                    ? AppColors.statusError
                    : AppColors.statusWarning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                    '${report.isUrgent ? 'Urgent · ' : ''}'
                    '${report.issueType.label}',
                    style: tt.titleMedium),
              ),
              StatusChip(
                status: switch (report.status) {
                  IssueStatus.open => 'pending',
                  IssueStatus.inReview => 'inProgress',
                  IssueStatus.resolved => 'completed',
                },
                label: report.status.label,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [
              driver,
              if (report.createdAt != null) relativeTime(report.createdAt!),
              if (report.photoIds.isNotEmpty)
                '${report.photoIds.length} photo'
                    '${report.photoIds.length == 1 ? '' : 's'}',
            ].join(' · '),
            style: tt.bodySmall,
          ),
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(report.description, style: tt.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (report.jobId?.isNotEmpty == true)
                TextButton.icon(
                  onPressed: () => context.go('/admin/jobs'),
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Open jobs'),
                ),
              if (report.status == IssueStatus.open)
                TextButton(
                  onPressed: () => set(IssueStatus.inReview),
                  child: const Text('Mark in review'),
                ),
              if (report.status != IssueStatus.resolved)
                TextButton(
                  onPressed: () => set(IssueStatus.resolved),
                  child: const Text('Resolve'),
                )
              else
                TextButton(
                  onPressed: () => set(IssueStatus.open),
                  child: const Text('Reopen'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
