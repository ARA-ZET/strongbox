import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/job.dart';
import '../../admin/providers/clients_providers.dart';
import '../../admin/providers/inventory_providers.dart';
import '../providers/driver_jobs_providers.dart';

/// Driver's single-job manifest with the Start Job → confirm-each-box flow.
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
          child: Text('Could not load job: $error',
              style: tt.bodyMedium?.copyWith(color: AppColors.statusError)),
        ),
        data: (model) {
          if (model == null) {
            return Center(
                child: Text('Job not found.', style: tt.titleMedium));
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
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _startJob(BuildContext context, WidgetRef ref) async {
    await ref.read(driverJobActionsProvider.notifier).startJob(job);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final boxes = ref.watch(jobManifestProvider(job.id));
    final clientName =
        ref.watch(clientNamesProvider)[job.clientId] ?? 'Client';
    final started = job.status == JobStatus.inProgress;
    final completed = job.status == JobStatus.completed;
    final pickup = job.type == JobType.pickup;

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
                    child: Text(clientName,
                        style: tt.headlineSmall?.copyWith(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: pickup
                          ? AppColors.statusWarningBg
                          : AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pickup ? 'PICKUP' : 'DELIVERY',
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: pickup
                            ? AppColors.amberDark
                            : AppColors.statusSuccess,
                      ),
                    ),
                  ),
                ],
              ),
              if (job.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(job.notes!,
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openMaps(clientName),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 18, color: AppColors.amberDark),
                    const SizedBox(width: 6),
                    Text('Open in Maps',
                        style: tt.labelLarge
                            ?.copyWith(color: AppColors.amberDark)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('MANIFEST ITEMS (${job.storageUnitIds.length})',
                  style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              boxes.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text('Could not load manifest: $error',
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.statusError)),
                data: (list) => Column(
                  children: [
                    for (final box in list)
                      _ManifestTile(
                        job: job,
                        box: box,
                        started: started,
                        confirmed: job.scannedUnitIds.contains(box.id),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomBar(
          job: job,
          started: started,
          completed: completed,
          onStart: () => _startJob(context, ref),
        ),
      ],
    );
  }
}

class _ManifestTile extends ConsumerWidget {
  const _ManifestTile({
    required this.job,
    required this.box,
    required this.started,
    required this.confirmed,
  });

  final Job job;
  final StorageUnit box;
  final bool started;
  final bool confirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final delivered = job.status == JobStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confirmed || delivered
            ? AppColors.surfaceContainer
            : AppColors.surface,
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
                      box.qrCodeId,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: delivered
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      box.label.isEmpty ? 'Box' : box.label,
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _ManifestStatusChip(
                      delivered: delivered,
                      confirmed: confirmed,
                      pickup: job.type == JobType.pickup,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (started && !confirmed && !delivered) ...[
            const SizedBox(height: 10),
            Row(
              children: [
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
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => context.go(
                        '/driver/capture?jobId=${job.id}&boxId=${box.id}'),
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
}

class _ManifestStatusChip extends StatelessWidget {
  const _ManifestStatusChip({
    required this.delivered,
    required this.confirmed,
    required this.pickup,
  });

  final bool delivered;
  final bool confirmed;
  final bool pickup;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (label, color, icon) = delivered
        ? (
            pickup ? 'Stored' : 'Delivered',
            AppColors.statusSuccess,
            Icons.done_all
          )
        : confirmed
            ? ('Loaded', AppColors.statusSuccess, Icons.check_circle_outline)
            : ('Pending', AppColors.textSecondary, Icons.schedule);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color == AppColors.statusSuccess
            ? AppColors.statusSuccessBg
            : AppColors.statusPendingBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: tt.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.job,
    required this.started,
    required this.completed,
    required this.onStart,
  });

  final Job job;
  final bool started;
  final bool completed;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final allConfirmed = job.storageUnitIds.isNotEmpty &&
        job.scannedUnitIds.toSet().containsAll(job.storageUnitIds);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              blurRadius: 8,
              color: Color(0x14000000),
              offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: completed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.statusSuccess),
                  const SizedBox(width: 8),
                  Text('Job completed',
                      style: tt.titleMedium
                          ?.copyWith(color: AppColors.statusSuccess)),
                ],
              )
            : !started
                ? SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Start Job'),
                    ),
                  )
                : SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allConfirmed
                            ? AppColors.amber
                            : AppColors.surfaceContainer,
                        foregroundColor: allConfirmed
                            ? AppColors.amberDark
                            : AppColors.textSecondary,
                      ),
                      onPressed: allConfirmed
                          ? () => context.go('/driver/signoff/${job.id}')
                          : null,
                      icon: const Icon(Icons.draw_outlined),
                      label: Text(allConfirmed
                          ? 'Get Client Sign-Off'
                          : 'Confirm all ${job.storageUnitIds.length} boxes'),
                    ),
                  ),
      ),
    );
  }
}

/// Resolves a unit's first photo URL for the manifest thumbnail.
class _UnitThumb extends ConsumerWidget {
  const _UnitThumb({required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(entityPhotosProvider(unitId)).valueOrNull;
    final url =
        (photos != null && photos.isNotEmpty) ? photos.first.storageUrl : null;
    if (url == null) {
      return Container(
        width: 72,
        height: 72,
        color: AppColors.border.withValues(alpha: 0.4),
        child: const Icon(Icons.inventory_2_outlined,
            color: AppColors.textSecondary),
      );
    }
    return CachedNetworkImage(
        imageUrl: url, width: 72, height: 72, fit: BoxFit.cover);
  }
}
