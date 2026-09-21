import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/job.dart';
import '../../../core/utils/relative_time.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/summary_card.dart';
import '../providers/clients_providers.dart';
import '../providers/dashboard_providers.dart';
import '../providers/jobs_providers.dart';
import '../providers/notifications_providers.dart';

/// Admin landing page: alert banner, summary counts, today's jobs table and
/// the recent activity feed. Design: admin_portal_dashboard/screen.png.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;
      final padding = EdgeInsets.all(desktop ? 24 : 16);

      return SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _UnlinkedQrBanner(),
            const SizedBox(height: 24),
            _SummaryRow(desktop: desktop),
            const SizedBox(height: 24),
            if (desktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 65, child: _TodaysJobsCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 35, child: _RecentActivityCard()),
                ],
              )
            else ...const [
              _TodaysJobsCard(),
              SizedBox(height: 24),
              _RecentActivityCard(),
            ],
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------------------ banner

class _UnlinkedQrBanner extends ConsumerWidget {
  const _UnlinkedQrBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unlinkedQrCountProvider).valueOrNull ?? 0;
    if (count == 0) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.statusWarningBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.statusWarning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Attention: $count unlinked QR codes detected. Please assign '
              'them to boxes to maintain tracking integrity.',
              style: textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => context.go('/admin/qr'),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- summary cards

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsInStorageCountProvider);
    final active = ref.watch(activeJobsTodayCountProvider);
    final pickupsCount = ref.watch(pendingPickupsCountProvider);
    final deliveries = ref.watch(pendingDeliveriesCountProvider);

    final cards = [
      SummaryCard(
        icon: Icons.inventory_2_outlined,
        value: '$units',
        label: 'Units in Storage',
        trend: '+4%',
      ),
      SummaryCard(
        icon: Icons.assignment_outlined,
        value: '$active',
        label: 'Active Jobs Today',
        trend: 'Ongoing',
      ),
      SummaryCard(
        icon: Icons.upload_outlined,
        value: '$pickupsCount',
        label: 'Pending Pickups',
        trend: pickupsCount > 3 ? 'High Priority' : null,
        trendPositive: false,
      ),
      SummaryCard(
        icon: Icons.local_shipping_outlined,
        value: '$deliveries',
        label: 'Pending Deliveries',
        trend: 'Sch. Today',
      ),
    ];

    if (desktop) {
      return Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: 24),
            Expanded(child: card),
          ],
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: cards,
    );
  }
}

// -------------------------------------------------------- today's jobs card

class _TodaysJobsCard extends ConsumerStatefulWidget {
  const _TodaysJobsCard();

  @override
  ConsumerState<_TodaysJobsCard> createState() => _TodaysJobsCardState();
}

class _TodaysJobsCardState extends ConsumerState<_TodaysJobsCard> {
  int _visibleRows = 10;

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(todaysJobsProvider);
    final clientNames = ref.watch(clientNamesProvider);
    final driverNames = ref.watch(driverNamesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text("Today's Jobs", style: textTheme.headlineSmall),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () => context.go('/admin/jobs'),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => context.go('/admin/jobs/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Job'),
                ),
              ],
            ),
          ),
          _buildTable(jobs, clientNames, driverNames),
        ],
      ),
    );
  }

  Widget _buildTable(
    List<Job> jobs,
    Map<String, String> clientNames,
    Map<String, String> driverNames,
  ) {
    final textTheme = Theme.of(context).textTheme;

    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Text(
          'No jobs scheduled for today.',
          style:
              textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final visible = jobs.take(_visibleRows).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 640),
            child: Column(
              children: [
                Container(
                  color: AppColors.surfaceContainer,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      _headerCell('CLIENT', flex: 3),
                      _headerCell('TYPE', flex: 2),
                      _headerCell('DRIVER', flex: 3),
                      _headerCell('TIME', flex: 2),
                      _headerCell('STATUS', flex: 2),
                    ],
                  ),
                ),
                for (final job in visible)
                  _JobRow(
                    job: job,
                    clientName: clientNames[job.clientId] ?? job.clientId,
                    driverName:
                        job.driverId == null ? null : driverNames[job.driverId],
                  ),
              ],
            ),
          ),
        ),
        if (jobs.length > _visibleRows)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton(
              onPressed: () => setState(() => _visibleRows += 10),
              child: const Text('Load more'),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  Widget _headerCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _JobRow extends StatefulWidget {
  const _JobRow({
    required this.job,
    required this.clientName,
    required this.driverName,
  });

  final Job job;
  final String clientName;
  final String? driverName;

  @override
  State<_JobRow> createState() => _JobRowState();
}

class _JobRowState extends State<_JobRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final job = widget.job;
    final pickup = job.type == JobType.pickup;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        // Job detail lands in Stage 4; keep rows tappable to the jobs list.
        onTap: () => context.go('/admin/jobs'),
        child: Container(
          color: _hovered ? AppColors.surfaceContainer : Colors.transparent,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.clientName,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('#JO-${job.id.substring(0, job.id.length.clamp(0, 5)).toUpperCase()}',
                        style: textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pickup ? AppColors.accent : AppColors.navy,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pickup ? 'PICKUP' : 'DELIVERY',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            pickup ? AppColors.onAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    InitialsAvatar(name: widget.driverName, size: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.driverName ?? 'Unassigned',
                        style: textTheme.bodyMedium?.copyWith(
                          color: widget.driverName == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  job.scheduledDate == null
                      ? '—'
                      : DateFormat('hh:mm a').format(job.scheduledDate!),
                  style: textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(status: job.status.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------- recent activity card

class _RecentActivityCard extends ConsumerWidget {
  const _RecentActivityCard();

  static const _categoryColors = {
    'critical': AppColors.statusError,
    'operational': AppColors.statusWarning,
    'system': AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(recentActivityProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          activity.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
            error: (error, _) => Text('Could not load activity: $error',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.statusError)),
            data: (entries) => entries.isEmpty
                ? Text('No activity recorded yet.',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary))
                : Column(
                    children: [
                      for (final entry in entries) _activityTile(entry, textTheme),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border)),
              onPressed: () => context.go('/admin/reports'),
              child: const Text('View Full Audit Log'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityTile(AuditEvent entry, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _categoryColors[categoryOf(entry)] ??
                    AppColors.statusPending,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auditTitle(entry),
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (entry.timestamp != null) ...[
                  const SizedBox(height: 2),
                  Text(relativeTime(entry.timestamp!),
                      style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
