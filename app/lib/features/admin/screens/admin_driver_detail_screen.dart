import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/job.dart';
import '../providers/clients_providers.dart';
import '../providers/fleet_providers.dart';

/// Single driver view: profile header, stats, active assignment,
/// compliance and recent history. Design: admin_driver_detail_view/screen.png.
class AdminDriverDetailScreen extends ConsumerWidget {
  const AdminDriverDetailScreen({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverByIdProvider(driverId));
    final textTheme = Theme.of(context).textTheme;

    return driver.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Could not load driver: $error',
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.statusError)),
      ),
      data: (model) {
        if (model == null) {
          return Center(
              child:
                  Text('Driver not found.', style: textTheme.titleMedium));
        }
        return _DriverDetailBody(driver: model);
      },
    );
  }
}

class _DriverDetailBody extends ConsumerWidget {
  const _DriverDetailBody({required this.driver});

  final AppUser driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeJobs =
        ref.watch(activeJobsByDriverProvider);
    final activeJob = activeJobs[driver.id];
    final completed =
        ref.watch(driverCompletedCountProvider(driver.id));
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => context.go('/admin/fleet'),
                ),
                Text('Fleet / ${driver.name}',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            _HeaderCard(
                driver: driver, onJob: activeJob != null, desktop: desktop),
            const SizedBox(height: 24),
            _StatsRow(completed: completed, desktop: desktop),
            const SizedBox(height: 24),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 65,
                      child: _ActiveAssignmentCard(job: activeJob)),
                  const SizedBox(width: 24),
                  const Expanded(flex: 35, child: _ComplianceCard()),
                ],
              )
            else ...[
              _ActiveAssignmentCard(job: activeJob),
              const SizedBox(height: 24),
              const _ComplianceCard(),
            ],
            const SizedBox(height: 24),
            _RecentHistoryCard(driverId: driver.id),
          ],
        ),
      );
    });
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.driver,
    required this.onJob,
    required this.desktop,
  });

  final AppUser driver;
  final bool onJob;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final identity = Row(
      children: [
        InitialsAvatar(name: driver.name, size: 80),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                      child: Text(driver.name,
                          style: textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 12),
                  StatusChip(status: onJob ? 'on_job' : 'available'),
                ],
              ),
              const SizedBox(height: 4),
              Text('Driver • DRV-${driver.id.substring(0, driver.id.length.clamp(0, 8)).toUpperCase()}',
                  style: textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _contact(Icons.mail_outline, driver.email, textTheme),
                  _contact(Icons.phone_outlined, driver.phone ?? '', textTheme),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => context.go('/admin/jobs/new'),
          icon: const Icon(Icons.assignment_outlined, size: 18),
          label: const Text('Assign to Job'),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Messaging arrives with FCM in Stage 7')),
          ),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Send Message'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: desktop
          ? Row(children: [Expanded(child: identity), actions])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 16), actions],
            ),
    );
  }

  Widget _contact(IconData icon, String value, TextTheme textTheme) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(value,
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.completed, required this.desktop});

  final int? completed;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget card(IconData icon, String value, String label, Color color) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: textTheme.headlineSmall),
                Text(label, style: textTheme.bodySmall),
              ],
            ),
          ],
        ),
      );
    }

    // Rating and on-time tracking wire up once driver sign-offs flow in
    // Stage 5; jobs-completed is live.
    final cards = [
      card(Icons.star_outline, '—', 'Average Rating', AppColors.accentDeep),
      card(Icons.schedule, '—', 'On-time Rate', AppColors.statusSuccess),
      card(Icons.check_circle_outline, completed?.toString() ?? '…',
          'Jobs Completed', AppColors.navy),
    ];

    if (desktop) {
      return Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: 20),
            Expanded(child: card),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (final (index, card) in cards.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          card,
        ],
      ],
    );
  }
}

class _ActiveAssignmentCard extends ConsumerWidget {
  const _ActiveAssignmentCard({required this.job});

  final Job? job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final clientNames = ref.watch(clientNamesProvider);
    final current = job;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Assignment',
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 20),
          if (current == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Icon(Icons.gps_fixed,
                    size: 40, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Center(
                  child: Text('Waiting for Assignment',
                      style: textTheme.titleMedium
                          ?.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'This driver is in the dispatch queue. Create a job to '
                    'assign a route.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.go('/admin/jobs/new'),
                    child: const Text('Open Dispatch Board'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#JB-${current.id.substring(0, current.id.length.clamp(0, 4)).toUpperCase()} — '
                        '${current.type == JobType.pickup ? 'Pickup' : 'Delivery'}',
                        style: textTheme.titleMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Client: ${clientNames[current.clientId] ?? '—'} · '
                        '${current.storageUnitIds.length} boxes',
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                      Text(
                        DateFormat('MMM d, y · hh:mm a')
                            .format(current.scheduledDate ?? DateTime.now()),
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: current.status.name),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: () => context.go('/admin/jobs'),
              child: const Text('View in Jobs List'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Static compliance checklist — certification records get real data when
/// driver onboarding lands (Stage 7).
class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, String detail, {bool warning = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              warning
                  ? Icons.warning_amber_rounded
                  : Icons.verified_outlined,
              size: 20,
              color: warning
                  ? AppColors.statusWarning
                  : AppColors.statusSuccess,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(detail, style: textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compliance', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          row('CDL License', 'Verification pending onboarding'),
          row('Hazmat Endorsement', 'Verification pending onboarding'),
          row('Medical Certificate', 'Verification pending onboarding'),
          row('D.O.T. Physical', 'Records arrive with driver onboarding',
              warning: true),
        ],
      ),
    );
  }
}

class _RecentHistoryCard extends ConsumerWidget {
  const _RecentHistoryCard({required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(driverRecentJobsProvider(driverId));
    final clientNames = ref.watch(clientNamesProvider);
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
                    child: Text('Recent History',
                        style: textTheme.headlineSmall)),
                TextButton(
                  onPressed: () => context.go('/admin/jobs'),
                  child: const Text('View All →'),
                ),
              ],
            ),
          ),
          jobs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text('No jobs on record for this driver yet.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  )
                : SingleChildScrollView(
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
                                _headerCell('JOB ID', 2, textTheme),
                                _headerCell('DATE', 2, textTheme),
                                _headerCell('CLIENT', 3, textTheme),
                                _headerCell('BOXES', 1, textTheme),
                                _headerCell('STATUS', 2, textTheme),
                              ],
                            ),
                          ),
                          for (final job in jobs)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '#JB-${job.id.substring(0, job.id.length.clamp(0, 4)).toUpperCase()}',
                                      style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat('MMM d, y')
                                          .format(job.scheduledDate ?? DateTime.now()),
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      clientNames[job.clientId] ?? '—',
                                      style: textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text('${job.storageUnitIds.length}',
                                        style: textTheme.bodyMedium),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child:
                                          StatusChip(status: job.status.name),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, int flex, TextTheme textTheme) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}
