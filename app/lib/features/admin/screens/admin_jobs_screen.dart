import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/destructive_button.dart';
import '../../../core/widgets/dialog_actions.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../../core/widgets/label_print_dialog.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/utils/currency.dart';
import '../providers/clients_providers.dart';
import '../providers/vehicle_providers.dart';
import '../providers/inventory_providers.dart';
import '../providers/jobs_providers.dart';
import '../../../core/widgets/table_scroll.dart';
import '../../../core/utils/public_ref.dart';

const _pageSize = 10;

/// Jobs List with type/status/date/driver filters.
/// Design: admin_jobs_list/screen.png.
class AdminJobsScreen extends ConsumerStatefulWidget {
  const AdminJobsScreen({super.key, this.initialQuery = '', this.openJobId});

  /// Pre-fills search (deep-linked from the top-bar global search via ?q=).
  final String initialQuery;

  /// Opens this job's sheet (?job=) — from an alert or the dashboard, so a
  /// booking to confirm is one tap away.
  final String? openJobId;

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
    // Provider writes must wait for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery.isNotEmpty) {
        final filter = ref.read(jobsFilterStateProvider);
        ref
            .read(jobsFilterStateProvider.notifier)
            .update(filter.copyWith(query: widget.initialQuery));
      }
      _openLinkedJob();
    });
  }

  @override
  void didUpdateWidget(AdminJobsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openJobId != oldWidget.openJobId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openLinkedJob());
    }
  }

  /// Opens the ?job= sheet once jobs have loaded, then drops the param so
  /// the same link opens it again next time.
  Future<void> _openLinkedJob() async {
    final id = widget.openJobId;
    if (id == null || id.isEmpty) return;
    final jobs = await ref.read(allJobsProvider.future);
    if (!mounted) return;
    final job = jobs.where((j) => j.id == id).firstOrNull;
    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That job no longer exists.')));
    } else {
      await showJobSheet(context, job);
    }
    if (mounted && widget.openJobId == id) context.go('/admin/jobs');
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
    final settings = ref.watch(businessSettingsProvider);

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
          TableScroll(
  minWidth: 860,
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
                      when: [
                        if (job.scheduledDate != null)
                          DateFormat('MMM d, y').format(job.scheduledDate!),
                        settings.windowLabel(job.timeWindow),
                      ].join(' · '),
                    ),
                ],
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
              ButtonSegment(value: 'supplyDrop', label: Text('Supplies')),
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
              // Values are JobStatus names — what filteredJobs compares.
              items: [
                const DropdownMenuItem(
                    value: 'all', child: Text('All Statuses')),
                for (final status in JobStatus.values)
                  DropdownMenuItem(
                      value: status.name, child: Text(status.label)),
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
    required this.when,
  });

  final Job job;
  final String clientName;
  final String? driverName;

  /// Day and booked time window — jobs carry a window, not a clock time.
  final String when;

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
                jobRef(job),
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
                        ? AppColors.skyTint
                        : AppColors.statusPendingBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    job.type.label.toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: pickup
                          ? AppColors.accentDeep
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(widget.when, style: textTheme.bodyMedium),
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
                onPressed: () => showJobSheet(context, job),
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The job sheet: details, live progress and the action its status calls
/// for (confirm / decline, dispatch, receive).
Future<void> showJobSheet(BuildContext context, Job job) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _JobSheet(jobId: job.id, initial: job),
    );

/// A job at a glance — where, what, progress — with the action its status
/// calls for: confirm or decline a booking, dispatch, or receive units.
class _JobSheet extends ConsumerWidget {
  const _JobSheet({required this.jobId, required this.initial});

  final String jobId;
  final Job initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
    final job = jobs.where((j) => j.id == jobId).firstOrNull ?? initial;
    final linked = jobs.where((j) => j.id == job.linkedJobId).firstOrNull;
    final clientName = ref.watch(clientNamesProvider)[job.clientId] ?? 'Client';
    final driverName = ref.watch(driverNamesProvider)[job.driverId];
    final settings = ref.watch(businessSettingsProvider);
    final vehicle = (ref.watch(fleetVehiclesProvider).valueOrNull ?? const [])
        .where((v) => v.id == job.fleetVehicleId)
        .firstOrNull;
    final catalog = ref.watch(priceCatalogProvider);
    final day = DateFormat('EEE d MMM y');
    final total = job.storageUnitIds.length;
    final time = DateFormat('HH:mm');

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(label,
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Text(value, style: textTheme.bodyMedium)),
            ],
          ),
        );

    final address = [job.address.line1, job.address.line2, job.address.city]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(', ');
    final supplies = [
      for (final MapEntry(:key, :value) in job.emptyBoxes.entries)
        '$value × ${catalog.box(key)?.label ?? key} (flat-pack)',
      for (final s in job.supplies) '${s.qty} × ${s.label}',
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${jobRef(job)} — ${job.type.label}',
                    style: textTheme.headlineSmall),
              ),
              StatusChip(status: job.status.name),
            ],
          ),
          const SizedBox(height: 16),
          line('Client', clientName),
          line('When', [
            if (job.scheduledDate != null) day.format(job.scheduledDate!),
            settings.windowLabel(job.timeWindow),
          ].join(', ')),
          if (address.isNotEmpty) line('Address', address),
          if (job.accessNotes?.isNotEmpty == true)
            line('Access', job.accessNotes!),
          if (job.notes?.isNotEmpty == true) line('Notes', job.notes!),
          if (job.status == JobStatus.cancelled)
            line('Cancelled', [
              job.cancelledBy == 'client' ? 'By the client' : 'By ops',
              if (job.cancelledAt != null) day.format(job.cancelledAt!),
              if (job.cancelReason?.isNotEmpty == true) job.cancelReason!,
            ].join(' · ')),
          line('Driver', driverName ?? 'Unassigned'),
          if (vehicle != null) line('Vehicle', vehicle.displayName),
          if (job.type != JobType.supplyDrop) line('Units', '$total'),
          if (supplies.isNotEmpty) line('Supplies', supplies.join(', ')),
          if (job.helperHours > 0)
            line('Packing helper', '${job.helperHours} hours'),
          if (job.onceOffZar > 0)
            line('Once-off', [
              formatZar(job.onceOffZar),
              job.invoicedIn == null ? 'next invoice' : 'invoiced',
            ].join(' · ')),
          if (linked != null)
            line(linked.type == JobType.supplyDrop ? 'Supplies first' : 'For pickup',
                '${jobRef(linked)} · ${linked.scheduledDate == null ? '' : day.format(linked.scheduledDate!)} · ${linked.status.label}'),
          if (job.status != JobStatus.pendingConfirmation &&
              job.status != JobStatus.cancelled) ...[
            const SizedBox(height: 12),
            Text('PROGRESS',
                style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            if (job.confirmedAt != null)
              line('Confirmed', day.format(job.confirmedAt!)),
            if (job.departedAt != null)
              line('On the way', time.format(job.departedAt!)),
            if (job.arrivedAt != null)
              line('Arrived', time.format(job.arrivedAt!)),
            if (job.type != JobType.supplyDrop)
              line(job.type == JobType.pickup ? 'Collected' : 'Loaded',
                  '${job.scannedUnitIds.length}/$total'),
            if (job.type == JobType.pickup)
              line('In storage', '${job.receivedUnitIds.length}/$total'),
            if (job.type == JobType.delivery)
              line('Handed over', '${job.handedOverUnitIds.length}/$total'),
            if (job.recipientName?.isNotEmpty == true)
              line('Signed by', job.recipientName!),
          ],
          const SizedBox(height: 16),
          _JobLabelsButton(job: job),
          const SizedBox(height: 8),
          switch (job.status) {
            JobStatus.pendingConfirmation => _ConfirmPanel(job: job),
            JobStatus.scheduled || JobStatus.assigned => _DispatchActions(job: job),
            JobStatus.collected => _ReceivePanel(job: job),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

/// Review a client booking or delivery request: keep or move the date and
/// window, optionally dispatch a driver and vehicle, then confirm — or
/// decline with a reason the client sees.
class _ConfirmPanel extends ConsumerStatefulWidget {
  const _ConfirmPanel({required this.job});

  final Job job;

  @override
  ConsumerState<_ConfirmPanel> createState() => _ConfirmPanelState();
}

class _ConfirmPanelState extends ConsumerState<_ConfirmPanel> {
  late DateTime? _date = widget.job.scheduledDate;
  late TimeWindow _window = widget.job.timeWindow;
  String? _driverId;
  String? _vehicleId;
  bool _busy = false;

  Future<void> _run(String failure, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      navigator.pop();
    } catch (error) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('$failure: $error')));
    }
  }

  Future<void> _decline() async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Decline ${jobRef(widget.job)}?'),
        content: TextField(
          controller: reason,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (the client sees this)',
            hintText: 'e.g. We don\'t collect in that area yet.',
          ),
        ),
        actions: [
          DialogActions(
            saveLabel: 'Decline',
            onSave: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (ok != true || !mounted) return;
    await _run('Could not decline',
        () => ref.read(jobMutationsProvider.notifier).decline(
            widget.job, text.isEmpty ? 'Not available.' : text));
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(driverUsersProvider).valueOrNull ?? const [];
    final vehicles = (ref.watch(fleetVehiclesProvider).valueOrNull ?? const [])
        .where((v) => v.status == VehicleStatus.available &&
            v.type != VehicleType.trailer)
        .toList();
    final settings = ref.watch(businessSettingsProvider);
    final changed = _date != widget.job.scheduledDate ||
        _window != widget.job.timeWindow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CONFIRM BOOKING',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _busy
              ? null
              : () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? now,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: now.add(const Duration(days: 180)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
          icon: const Icon(Icons.event_outlined, size: 18),
          label: Text(_date == null
              ? 'Pick a date'
              : DateFormat('EEE d MMM y').format(_date!)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final window in TimeWindow.values)
              ChoiceChip(
                label: Text(settings.windowLabel(window)),
                selected: _window == window,
                onSelected:
                    _busy ? null : (_) => setState(() => _window = window),
              ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _driverId,
          decoration:
              const InputDecoration(labelText: 'Driver (optional — assign later)'),
          items: [
            for (final driver in drivers)
              DropdownMenuItem(value: driver.id, child: Text(driver.name)),
          ],
          onChanged: _busy ? null : (v) => setState(() => _driverId = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _vehicleId,
          decoration: const InputDecoration(labelText: 'Vehicle (optional)'),
          items: [
            for (final v in vehicles)
              DropdownMenuItem(value: v.id, child: Text(v.displayName)),
          ],
          onChanged: _busy ? null : (v) => setState(() => _vehicleId = v),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: changed ? 'Confirm new time' : 'Confirm booking',
          icon: null,
          loading: _busy,
          onPressed: _busy || _date == null
              ? null
              : () => _run(
                  'Could not confirm',
                  () => ref.read(jobMutationsProvider.notifier).confirm(
                        widget.job,
                        scheduledDate:
                            _date == widget.job.scheduledDate ? null : _date,
                        timeWindow: _window == widget.job.timeWindow
                            ? null
                            : _window,
                        driverId: _driverId,
                        fleetVehicleId: _vehicleId,
                      )),
        ),
        const SizedBox(height: 8),
        DestructiveButton(
          label: 'Decline',
          fullWidth: true,
          onPressed: _busy ? null : _decline,
        ),
      ],
    );
  }
}

/// Fallback receiving at the facility: tick the units that arrived and
/// record a bay, when the driver couldn't scan them in.
class _ReceivePanel extends ConsumerStatefulWidget {
  const _ReceivePanel({required this.job});

  final Job job;

  @override
  ConsumerState<_ReceivePanel> createState() => _ReceivePanelState();
}

class _ReceivePanelState extends ConsumerState<_ReceivePanel> {
  final _bay = TextEditingController();
  final _picked = <String>{};
  bool _busy = false;

  @override
  void dispose() {
    _bay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final ids = job.storageUnitIds
        .where((id) => !job.receivedUnitIds.contains(id))
        .toSet();
    final units = (ref.watch(allUnitsProvider).valueOrNull ?? const [])
        .where((u) => ids.contains(u.id))
        .toList();
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('RECEIVE AT FACILITY',
            style: tt.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        Text('Drivers scan units in on arrival. Use this if they couldn\'t.',
            style: tt.bodySmall),
        for (final unit in units)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _picked.contains(unit.id),
            onChanged: _busy
                ? null
                : (v) => setState(() =>
                    v == true ? _picked.add(unit.id) : _picked.remove(unit.id)),
            title: Text(unit.label.isEmpty ? 'Box' : unit.label),
            subtitle: Text(unit.displayCode),
          ),
        TextField(
          controller: _bay,
          textCapitalization: TextCapitalization.characters,
          decoration:
              const InputDecoration(labelText: 'Storage bay / shelf (optional)'),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Mark ${_picked.length} in storage',
          icon: null,
          loading: _busy,
          onPressed: _busy || _picked.isEmpty
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  setState(() => _busy = true);
                  try {
                    await ref.read(jobMutationsProvider.notifier).receiveUnits(
                        job, _picked.toList(),
                        bay: _bay.text);
                    if (mounted) setState(() => _picked.clear());
                  } catch (error) {
                    messenger.showSnackBar(SnackBar(
                        content: Text('Could not receive units: $error')));
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
        ),
      ],
    );
  }
}

/// Reprint a job's QR labels — e.g. damaged in transit. The code never
/// changes, so a reprint scans exactly like the original. Unscanned units
/// start ticked.
class _JobLabelsButton extends ConsumerWidget {
  const _JobLabelsButton({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = job.storageUnitIds.toSet();
    final units = (ref.watch(allUnitsProvider).valueOrNull ?? const [])
        .where((u) => ids.contains(u.id) && u.qrCodeId.isNotEmpty)
        .toList();
    if (units.isEmpty) return const SizedBox.shrink();

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
      onPressed: () => LabelPrintDialog.show(
        context,
        units: units,
        preselected: {
          for (final u in units)
            if (!job.scannedUnitIds.contains(u.id)) u.id,
        },
      ),
      icon: const Icon(Icons.print_outlined, size: 18),
      label: Text('Print labels (${units.length})'),
    );
  }
}

/// Assign / reassign a driver, or cancel — for jobs that haven't started.
/// Client delivery requests and drafts arrive unassigned and wait here.
class _DispatchActions extends ConsumerStatefulWidget {
  const _DispatchActions({required this.job});

  final Job job;

  @override
  ConsumerState<_DispatchActions> createState() => _DispatchActionsState();
}

class _DispatchActionsState extends ConsumerState<_DispatchActions> {
  late String? _driverId = widget.job.driverId;
  late String? _vehicleId = widget.job.fleetVehicleId;
  bool _busy = false;

  Future<void> _run(String failure, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      navigator.pop();
    } catch (error) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('$failure: $error')));
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel ${jobRef(widget.job)}?',
      message: switch (widget.job.type) {
        JobType.delivery => 'Its boxes go back to "In Storage".',
        JobType.supplyDrop => 'No supplies will be delivered.',
        JobType.pickup => [
            widget.job.source == 'quote'
                ? 'The client\'s booked items are cancelled too.'
                : 'Its boxes stay pending pickup.',
            if (widget.job.linkedJobId != null)
              'Its supply drop-off is cancelled too, unless it\'s already '
                  'under way.',
          ].join(' '),
      },
      confirmLabel: 'Cancel Job',
      cancelLabel: 'Keep',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run('Could not cancel job',
        () => ref.read(jobMutationsProvider.notifier).cancelJob(widget.job));
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(driverUsersProvider).valueOrNull ?? const [];
    final driverId = drivers.any((d) => d.id == _driverId) ? _driverId : null;
    final assigned = widget.job.driverId != null;
    final vehicles = (ref.watch(fleetVehiclesProvider).valueOrNull ?? const [])
        .where((v) => v.type != VehicleType.trailer)
        .toList();
    final vehicleId = vehicles.any((v) => v.id == _vehicleId) ? _vehicleId : null;
    final changed = driverId != widget.job.driverId ||
        vehicleId != widget.job.fleetVehicleId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: driverId,
          decoration: const InputDecoration(labelText: 'Driver'),
          items: [
            for (final driver in drivers)
              DropdownMenuItem(value: driver.id, child: Text(driver.name)),
          ],
          onChanged: _busy ? null : (value) => setState(() => _driverId = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: vehicleId,
          decoration: const InputDecoration(labelText: 'Vehicle'),
          items: [
            for (final v in vehicles)
              DropdownMenuItem(value: v.id, child: Text(v.displayName)),
          ],
          onChanged:
              _busy ? null : (value) => setState(() => _vehicleId = value),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: assigned ? 'Update Dispatch' : 'Assign Driver',
          icon: null,
          loading: _busy,
          onPressed: driverId == null || !changed || _busy
              ? null
              : () => _run(
                  'Could not assign driver',
                  () => ref.read(jobMutationsProvider.notifier).assignDriver(
                      widget.job, driverId,
                      fleetVehicleId: vehicleId)),
        ),
        const SizedBox(height: 8),
        DestructiveButton(
          label: 'Cancel Job',
          fullWidth: true,
          onPressed: _busy ? null : _cancel,
        ),
      ],
    );
  }
}
