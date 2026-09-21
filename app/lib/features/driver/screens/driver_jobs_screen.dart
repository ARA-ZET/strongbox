import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../admin/providers/clients_providers.dart';
import '../providers/driver_jobs_providers.dart';

/// Driver's daily job list. Design: driver_portal_jobs/screen.png.
class DriverJobsScreen extends ConsumerStatefulWidget {
  const DriverJobsScreen({super.key});

  @override
  ConsumerState<DriverJobsScreen> createState() => _DriverJobsScreenState();
}

class _DriverJobsScreenState extends ConsumerState<DriverJobsScreen> {
  bool _today = true;

  @override
  Widget build(BuildContext context) {
    final jobs = _today
        ? ref.watch(driverTodayJobsProvider)
        : ref.watch(driverUpcomingJobsProvider);
    final clientNames = ref.watch(clientNamesProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        onPressed: () => context.go('/driver/scan'),
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text('Active Jobs', style: textTheme.displaySmall),
          const SizedBox(height: 4),
          Text('Your assigned pickups and deliveries.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _SegToggle(
            today: _today,
            onChanged: (value) => setState(() => _today = value),
          ),
          const SizedBox(height: 16),
          _buildList(jobs, clientNames, textTheme),
        ],
      ),
    );
  }

  Widget _buildList(
      List<Job> jobs, Map<String, String> clientNames, TextTheme tt) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              _today
                  ? 'No jobs scheduled for today.'
                  : 'No upcoming jobs.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[];
    for (final (index, job) in jobs.indexed) {
      children.add(_JobCard(
        job: job,
        stopNumber: index + 1,
        clientName: clientNames[job.clientId] ?? 'Client',
      ));
      // Warehouse-sync promo between the first two cards, matching the design.
      if (index == 0 && jobs.length > 1) {
        children.add(const _ScanPromoCard());
      }
    }
    return Column(children: children);
  }
}

class _SegToggle extends StatelessWidget {
  const _SegToggle({required this.today, required this.onChanged});

  final bool today;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _segButton(context, 'Today', today, () => onChanged(true)),
          _segButton(context, 'Upcoming', !today, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segButton(
      BuildContext context, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? const [AppTheme.cardShadow] : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active
                      ? AppColors.navy
                      : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({
    required this.job,
    required this.stopNumber,
    required this.clientName,
  });

  final Job job;
  final int stopNumber;
  final String clientName;

  Future<void> _openMaps(String query) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final pickup = job.type == JobType.pickup;
    final inProgress = job.status == JobStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/driver/jobs/${job.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pickup
                        ? AppColors.skyTint
                        : AppColors.statusSuccessBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pickup ? 'Pickup' : 'Delivery',
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: pickup
                          ? AppColors.accentDeep
                          : AppColors.statusSuccess,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(job.scheduledDate == null ? '' : DateFormat('hh:mm a').format(job.scheduledDate!),
                        style: tt.titleMedium),
                    Text('Stop #$stopNumber', style: tt.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(clientName, style: tt.headlineSmall?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.accentDeep),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    job.notes?.isNotEmpty == true
                        ? job.notes!
                        : 'Tap for manifest and address',
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 18, color: AppColors.navy),
                const SizedBox(width: 6),
                Text('${job.storageUnitIds.length} Units', style: tt.bodyMedium),
                const Spacer(),
                _DriverStatusChip(status: job.status.name),
              ],
            ),
            if (inProgress) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openMaps(clientName),
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text('Start Navigation'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small dotted status chip variant used on driver job cards.
class _DriverStatusChip extends StatelessWidget {
  const _DriverStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (label, color) = switch (status) {
      'inProgress' => ('In Transit', AppColors.statusWarning),
      'completed' => ('Completed', AppColors.statusSuccess),
      'assigned' => ('Assigned', AppColors.textSecondary),
      _ => ('Pending', AppColors.textSecondary),
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: tt.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

class _ScanPromoCard extends StatelessWidget {
  const _ScanPromoCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner,
                color: AppColors.onAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to scan?',
                    style: tt.titleMedium?.copyWith(color: Colors.white)),
                Text('Sync with the warehouse in one tap.',
                    style: tt.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
