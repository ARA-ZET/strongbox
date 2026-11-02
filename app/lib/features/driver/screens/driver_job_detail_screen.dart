import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/report_failure.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/job.dart';
import '../../../core/widgets/label_print_dialog.dart';
import '../../admin/providers/clients_providers.dart';
import '../../admin/providers/inventory_providers.dart';
import '../../admin/providers/vehicle_providers.dart';
import '../providers/driver_jobs_providers.dart';
import '../../../core/widgets/storage_image.dart';

/// Driver's single job: where, what, and the next step — start, check in,
/// scan, photograph, sign off and (pickups) receive at the facility.
/// Design: driver_job_detail/screen.png.
class DriverJobDetailScreen extends ConsumerWidget {
  const DriverJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(driverJobProvider(jobId));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver/jobs'),
        ),
        title: const Text('Job Details'),
      ),
      body: job.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Could not load job: $error',
            style: tt.bodyMedium?.copyWith(color: AppColors.statusError),
          ),
        ),
        data: (model) {
          if (model == null) {
            return Center(child: Text('Job not found.', style: tt.titleMedium));
          }
          return _JobDetailBody(job: model);
        },
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  const _JobDetailBody({required this.job});

  final Job job;

  Future<void> _openMaps(String query) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Where to navigate: the job's delivery/pickup address when it has one.
  String _mapsQuery(String clientName) {
    final address = job.address;
    final parts = [
      address.line1,
      address.line2,
      address.city,
      address.postCode,
    ].where((part) => part != null && part.trim().isNotEmpty);
    return parts.isEmpty ? clientName : parts.join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final boxes = ref.watch(jobManifestProvider(job.id));
    final clientName = ref.watch(clientNamesProvider)[job.clientId] ?? 'Client';
    final step = scanStepFor(job);
    final pickup = job.type == JobType.pickup;
    final supplyRun = job.type == JobType.supplyDrop;
    final settings = ref.watch(businessSettingsProvider);
    final vehicle = ref
        .watch(fleetVehiclesProvider)
        .valueOrNull
        ?.where((v) => v.id == job.fleetVehicleId)
        .firstOrNull;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      clientName,
                      style: tt.headlineSmall?.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pickup || supplyRun
                          ? AppColors.skyTint
                          : AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      job.type.label.toUpperCase(),
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: pickup || supplyRun
                            ? AppColors.accentDeep
                            : AppColors.statusSuccess,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (job.scheduledDate != null)
                    DateFormat('EEE d MMM').format(job.scheduledDate!),
                  settings.windowLabel(job.timeWindow),
                  job.status.label,
                ].join(' · '),
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                rows: [
                  (Icons.place_outlined, 'Address', _mapsQuery(clientName)),
                  if (job.accessNotes?.isNotEmpty == true)
                    (Icons.vpn_key_outlined, 'Access', job.accessNotes!),
                  if (job.notes?.isNotEmpty == true)
                    (Icons.notes_outlined, 'Notes', job.notes!),
                  if (job.helperHours > 0)
                    (
                      Icons.groups_outlined,
                      'Packing helper',
                      '${job.helperHours} hours booked — help the client pack',
                    ),
                  if (vehicle != null)
                    (
                      Icons.local_shipping_outlined,
                      'Vehicle',
                      vehicle.displayName,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openMaps(_mapsQuery(clientName)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: AppColors.accentDeep,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open in Maps',
                      style: tt.labelLarge?.copyWith(
                        color: AppColors.accentDeep,
                      ),
                    ),
                  ],
                ),
              ),
              if (job.supplies.isNotEmpty || job.emptyBoxes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  supplyRun ? 'DELIVER TO CLIENT' : 'BRING ON THE DAY',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _SupplyChecklist(job: job),
              ],
              if (!supplyRun) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'MANIFEST ITEMS (${job.storageUnitIds.length})',
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Clients who couldn't print, or labels damaged on the
                    // way — a reprint is the same code, so it scans the same.
                    if (job.status != JobStatus.completed &&
                        job.status != JobStatus.cancelled)
                      TextButton.icon(
                        onPressed: () => LabelPrintDialog.show(
                          context,
                          units: boxes.valueOrNull ?? const [],
                          preselected: {
                            for (final id in job.storageUnitIds)
                              if (!job.scannedUnitIds.contains(id)) id,
                          },
                        ),
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Print labels'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                boxes.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(
                    'Could not load manifest: $error',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.statusError,
                    ),
                  ),
                  data: (list) => Column(
                    children: [
                      for (final box in list)
                        _ManifestTile(job: job, box: box, step: step),
                    ],
                  ),
                ),
              ],
              if (job.status.isOpen) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.go('/driver/report-issue?jobId=${job.id}'),
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text('Report a problem with this job'),
                  ),
                ),
              ],
            ],
          ),
        ),
        _BottomBar(job: job, step: step),
      ],
    );
  }
}

class _ManifestTile extends ConsumerWidget {
  const _ManifestTile({required this.job, required this.box, this.step});

  final Job job;
  final StorageUnit box;
  final ScanStep? step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final done = step?.doneOn(job).contains(box.id) ?? false;
    final (label, ok) = _progress();
    // Photos are taken where the client can see them: at collection
    // (condition baseline) and at handover.
    final canPhoto =
        job.arrivedAt != null && job.status == JobStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? AppColors.surfaceContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _UnitThumb(unitId: box.id),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      box.displayCode,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      [
                        box.label.isEmpty ? 'Box' : box.label,
                        if (box.condition != null) box.condition!.label,
                        if (box.warehouseLocationId?.isNotEmpty == true)
                          'Bay ${box.warehouseLocationId}',
                      ].join(' · '),
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _ManifestStatusChip(label: label, ok: ok),
                  ],
                ),
              ),
            ],
          ),
          if ((step != null && !done) || canPhoto) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (step != null && !done)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        side: const BorderSide(color: AppColors.navy),
                      ),
                      onPressed: () =>
                          context.go('/driver/scan?jobId=${job.id}'),
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Scan QR'),
                    ),
                  ),
                if (step != null && !done && canPhoto) const SizedBox(width: 8),
                if (canPhoto)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textPrimary,
                      ),
                      onPressed: () => context.go(
                        '/driver/capture?jobId=${job.id}&boxId=${box.id}',
                      ),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Photo'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Where this unit is in the job, as the driver would say it.
  (String, bool) _progress() {
    final id = box.id;
    if (job.type == JobType.pickup) {
      if (job.receivedUnitIds.contains(id)) return ('In storage', true);
      if (job.scannedUnitIds.contains(id)) return ('On the truck', true);
      return ('To collect', false);
    }
    if (job.handedOverUnitIds.contains(id) ||
        job.status == JobStatus.completed) {
      return ('Handed over', true);
    }
    if (job.scannedUnitIds.contains(id)) return ('On the truck', true);
    return ('In storage — load it', false);
  }
}

class _ManifestStatusChip extends StatelessWidget {
  const _ManifestStatusChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = ok ? AppColors.statusSuccess : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ok ? AppColors.statusSuccessBg : AppColors.statusPendingBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.schedule,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + label + value rows: address, access, helper, vehicle.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(IconData, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          for (final (icon, label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: AppColors.accentDeep),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: Text(
                      label,
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Text(value, style: tt.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty boxes and packing supplies the job carries.
class _SupplyChecklist extends ConsumerWidget {
  const _SupplyChecklist({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(priceCatalogProvider);
    final lines = [
      for (final MapEntry(:key, :value) in job.emptyBoxes.entries)
        if (value > 0) ('${catalog.box(key)?.label ?? key} (flat-pack)', value),
      for (final s in job.supplies)
        if (s.qty > 0) (s.label.isEmpty ? s.id : s.label, s.qty),
      ('QR label sheets for every box', 1),
    ];
    return _InfoCard(
      rows: [
        for (final (label, qty) in lines)
          (Icons.inventory_2_outlined, '× $qty', label),
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.job, this.step});

  final Job job;
  final ScanStep? step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final actions = ref.read(driverJobActionsProvider.notifier);
    final busy = ref.watch(driverJobActionsProvider).isLoading;
    final total = job.storageUnitIds.length;

    void run(String failure, Future<void> Function() op) =>
        reportFailure(context, failure, op);

    Widget button(String label, IconData icon, VoidCallback? onPressed) =>
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: busy ? null : onPressed,
            icon: Icon(icon),
            label: Text(label),
          ),
        );

    Widget banner(String label, IconData icon, Color color) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(color: color),
          ),
        ),
      ],
    );

    final Widget child = switch (job.status) {
      JobStatus.completed => banner(
        'Job completed',
        Icons.check_circle,
        AppColors.statusSuccess,
      ),
      JobStatus.cancelled => banner(
        'Job cancelled',
        Icons.cancel_outlined,
        AppColors.statusError,
      ),
      JobStatus.pendingConfirmation => banner(
        'Awaiting confirmation by ops',
        Icons.hourglass_top,
        AppColors.textSecondary,
      ),
      JobStatus.scheduled || JobStatus.assigned => button(
        job.type == JobType.delivery
            ? 'Start — load at facility'
            : "Start — I'm on my way",
        Icons.play_circle_outline,
        () => run('Could not start job', () => actions.startJob(job)),
      ),
      JobStatus.collected => button(
        'Receive at facility (${job.receivedUnitIds.length}/$total)',
        Icons.warehouse_outlined,
        () => context.go('/driver/scan?jobId=${job.id}'),
      ),
      JobStatus.inProgress => _inProgress(context, actions, button, run),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppColors.cardShadowStrong,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }

  Widget _inProgress(
    BuildContext context,
    DriverJobActions actions,
    Widget Function(String, IconData, VoidCallback?) button,
    void Function(String, Future<void> Function()) run,
  ) {
    final total = job.storageUnitIds.length;
    void scan() => context.go('/driver/scan?jobId=${job.id}');
    void signOff() => context.go('/driver/signoff/${job.id}');

    if (step == ScanStep.load) {
      return button(
        'Scan out of storage (${job.scannedUnitIds.length}/$total)',
        Icons.qr_code_scanner,
        scan,
      );
    }
    if (job.departedAt == null) {
      return button(
        "Loaded — I'm on my way",
        Icons.local_shipping_outlined,
        () => run('Could not check in', () => actions.markDeparted(job)),
      );
    }
    if (job.arrivedAt == null) {
      return button(
        "I've arrived",
        Icons.where_to_vote_outlined,
        () => run('Could not check in', () => actions.markArrived(job)),
      );
    }
    if (step == ScanStep.collect) {
      return button(
        'Scan to collect (${job.scannedUnitIds.length}/$total)',
        Icons.qr_code_scanner,
        scan,
      );
    }
    if (step == ScanStep.handOver) {
      return button(
        'Scan at handover (${job.handedOverUnitIds.length}/$total)',
        Icons.qr_code_scanner,
        scan,
      );
    }
    if (job.type == JobType.supplyDrop) {
      return button('Client signs for supplies', Icons.draw_outlined, signOff);
    }
    // doc 02: at least one photo before the client signs.
    if (job.photoIds.isEmpty) {
      return button(
        'Take at least one photo',
        Icons.photo_camera_outlined,
        () => context.go(
          '/driver/capture?jobId=${job.id}'
          '&boxId=${job.storageUnitIds.first}',
        ),
      );
    }
    return button('Get Client Sign-Off', Icons.draw_outlined, signOff);
  }
}

/// Resolves a unit's first photo URL for the manifest thumbnail.
class _UnitThumb extends ConsumerWidget {
  const _UnitThumb({required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(entityPhotosProvider(unitId)).valueOrNull;
    final url = (photos != null && photos.isNotEmpty)
        ? photos.first.storageUrl
        : null;
    if (url == null) {
      return Container(
        width: 72,
        height: 72,
        color: AppColors.border.withValues(alpha: 0.4),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: AppColors.textSecondary,
        ),
      );
    }
    return StorageImage(url, width: 72, height: 72);
  }
}
