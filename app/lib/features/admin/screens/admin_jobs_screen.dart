import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../providers/clients_providers.dart';
import '../providers/jobs_providers.dart';

const _pageSize = 10;

/// Jobs List with type/status/date/driver filters.
/// Design: admin_jobs_list/screen.png.
class AdminJobsScreen extends ConsumerStatefulWidget {
  const AdminJobsScreen({super.key, this.initialQuery = ''});

  /// Pre-fills search (deep-linked from the top-bar global search via ?q=).
  final String initialQuery;

  @override
  ConsumerState<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends ConsumerState<AdminJobsScreen> {
  int _page = 0;
  late final _searchController =
      TextEditingController(text: widget.initialQuery);

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      // Provider writes must wait for the first frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final filter = ref.read(jobsFilterStateProvider);
        ref
            .read(jobsFilterStateProvider.notifier)
            .update(filter.copyWith(query: widget.initialQuery));
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(JobsFilter filter) {
    ref.read(jobsFilterStateProvider.notifier).update(filter);
    setState(() => _page = 0);
  }

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(filteredJobsProvider);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return SingleChildScrollView(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jobs List', style: textTheme.displaySmall),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and monitor active logistics tasks across the fleet.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () => context.go('/admin/jobs/new'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Job'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSearchBar(
              hint: 'Search job ID...',
              controller: _searchController,
              onChanged: (value) => _updateFilter(
                  ref.read(jobsFilterStateProvider).copyWith(query: value)),
            ),
            const SizedBox(height: 16),
            _FilterBar(onChanged: _updateFilter),
            const SizedBox(height: 16),
            _buildTable(jobs, textTheme),
          ],
        ),
      );
    });
  }

  Widget _buildTable(List<Job> list, TextTheme textTheme) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Text('No jobs match your filters.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final pageCount = (list.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final visible = list.skip(start).take(_pageSize).toList();
    final clientNames = ref.watch(clientNamesProvider);
    final driverNames = ref.watch(driverNamesProvider);

    Widget headerCell(String label, {required int flex}) => Expanded(
          flex: flex,
          child: Text(label,
              style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 860),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        headerCell('JOB ID', flex: 2),
                        headerCell('CLIENT', flex: 3),
                        headerCell('TYPE', flex: 2),
                        headerCell('SCHEDULED DATE', flex: 3),
                        headerCell('DRIVER', flex: 3),
                        headerCell('STATUS', flex: 2),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),
                  for (final job in visible)
                    _JobRow(
                      job: job,
                      clientName: clientNames[job.clientId] ?? '—',
                      driverName: job.driverId == null
                          ? null
                          : driverNames[job.driverId],
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${start + 1}-${(start + _pageSize).clamp(0, list.length)} of ${list.length} jobs',
                    style: textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: page > 0
                      ? () => setState(() => _page = page - 1)
                      : null,
                ),
                Text('${page + 1} / $pageCount',
                    style: textTheme.bodySmall),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: page < pageCount - 1
                      ? () => setState(() => _page = page + 1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Type toggle + status dropdown + date range + driver dropdown.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.onChanged});

  final ValueChanged<JobsFilter> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobsFilterStateProvider);
    final drivers = ref.watch(driverUsersProvider).valueOrNull ?? const [];
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'pickup', label: Text('Pickup')),
              ButtonSegment(value: 'delivery', label: Text('Delivery')),
            ],
            selected: {filter.type},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.navy,
              selectedForegroundColor: Colors.white,
            ),
            onSelectionChanged: (selection) =>
                onChanged(filter.copyWith(type: selection.first)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filter.status,
              borderRadius: BorderRadius.circular(8),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(
                    value: 'scheduled', child: Text('Scheduled')),
                DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
                DropdownMenuItem(
                    value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(
                    value: 'completed', child: Text('Completed')),
                DropdownMenuItem(
                    value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(filter.copyWith(status: value));
                }
              },
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textPrimary,
              textStyle: textTheme.bodyMedium,
            ),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: now.subtract(const Duration(days: 365)),
                lastDate: now.add(const Duration(days: 365)),
                initialDateRange: filter.dateRange,
              );
              if (picked != null) {
                onChanged(filter.copyWith(dateRange: picked));
              }
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(
              filter.dateRange == null
                  ? 'All Dates'
                  : '${DateFormat('MMM d').format(filter.dateRange!.start)} - '
                      '${DateFormat('MMM d, y').format(filter.dateRange!.end)}',
            ),
          ),
          if (filter.dateRange != null)
            IconButton(
              tooltip: 'Clear date range',
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onChanged(filter.copyWith(dateRange: null)),
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filter.driverId,
              borderRadius: BorderRadius.circular(8),
              items: [
                const DropdownMenuItem(
                    value: 'all', child: Text('All Drivers')),
                for (final driver in drivers)
                  DropdownMenuItem(
                      value: driver.id, child: Text(driver.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  onChanged(filter.copyWith(driverId: value));
                }
              },
            ),
          ),
        ],
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
      child: Container(
        color: _hovered ? AppColors.surfaceContainer : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '#JB-${job.id.substring(0, job.id.length.clamp(0, 4)).toUpperCase()}',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(widget.clientName,
                  style: textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pickup
                        ? AppColors.statusWarningBg
                        : AppColors.statusPendingBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pickup ? 'PICKUP' : 'DELIVERY',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: pickup
                          ? AppColors.amberDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                job.scheduledDate == null ? '' : DateFormat('MMM d, y · hh:mm a').format(job.scheduledDate!),
                style: textTheme.bodyMedium,
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(status: job.status.name),
              ),
            ),
            SizedBox(
              width: 80,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: AppColors.border),
                ),
                onPressed: () => _showJobSheet(context),
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick-look bottom sheet — the full job detail page ships with the
  /// driver flow in Stage 5.
  void _showJobSheet(BuildContext context) {
    final job = widget.job;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#JB-${job.id.substring(0, job.id.length.clamp(0, 4)).toUpperCase()} — '
                    '${job.type == JobType.pickup ? 'Pickup' : 'Delivery'}',
                    style: textTheme.headlineSmall,
                  ),
                ),
                StatusChip(status: job.status.name),
              ],
            ),
            const SizedBox(height: 16),
            Text('Client: ${widget.clientName}',
                style: textTheme.bodyMedium),
            Text('Driver: ${widget.driverName ?? 'Unassigned'}',
                style: textTheme.bodyMedium),
            Text(
              'Scheduled: ${job.scheduledDate == null ? '' : DateFormat('MMM d, y · hh:mm a').format(job.scheduledDate!)}'
              ' (${job.timeWindow.name})',
              style: textTheme.bodyMedium,
            ),
            Text('Units: ${job.storageUnitIds.length}',
                style: textTheme.bodyMedium),
            if (job.notes != null && job.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${job.notes}', style: textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
