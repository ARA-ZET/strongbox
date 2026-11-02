import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../admin/providers/clients_providers.dart';
import '../providers/driver_jobs_providers.dart';
import '../../../core/utils/public_ref.dart';

/// Client sign-off on the driver's device: the client reviews the item
/// list, gives their name and signs. A pickup becomes collected (the driver
/// then scans the units into storage); a delivery or supply drop-off is
/// completed. Design: driver_client_sign_off/screen.png.
class DriverSignOffScreen extends ConsumerStatefulWidget {
  const DriverSignOffScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<DriverSignOffScreen> createState() =>
      _DriverSignOffScreenState();
}

class _DriverSignOffScreenState extends ConsumerState<DriverSignOffScreen> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.navy,
    exportBackgroundColor: Colors.white,
  );
  final _recipient = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Rebuild so the "Signature required here" hint clears on first stroke.
    _controller.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChanged);
    _controller.dispose();
    _recipient.dispose();
    super.dispose();
  }

  Future<void> _confirm(Job job) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a signature first')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final png = await _controller.toPngBytes();
      if (png == null) throw Exception('Could not render signature');
      await ref
          .read(driverJobActionsProvider.notifier)
          .completeJob(job, png, recipientName: _recipient.text);
      if (mounted) await _showSuccess(job);
    } catch (error) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not complete job: $error')),
        );
      }
    }
  }

  Future<void> _showSuccess(Job job) async {
    final pickup = job.type == JobType.pickup;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.statusSuccess, size: 64),
              const SizedBox(height: 16),
              Text(pickup ? 'Collected' : 'Job Completed',
                  style: Theme.of(dialogContext).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                  pickup
                      ? 'Signature captured. Scan every unit into storage '
                          'when you reach the facility.'
                      : 'Signature captured.',
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
    if (mounted) context.go('/driver/jobs');
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(driverJobProvider(widget.jobId));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/driver/jobs/${widget.jobId}'),
        ),
        title: const Text('Client Sign-Off'),
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
          return _buildBody(model);
        },
      ),
    );
  }

  Widget _buildBody(Job job) {
    final tt = Theme.of(context).textTheme;
    final clientName =
        ref.watch(clientNamesProvider)[job.clientId] ?? 'Client';
    final units = ref.watch(jobManifestProvider(job.id)).valueOrNull ?? [];
    final supplyRun = job.type == JobType.supplyDrop;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
            switch (job.type) {
              JobType.pickup => 'Client confirms the collection',
              JobType.delivery => 'Client confirms the delivery',
              JobType.supplyDrop => 'Client signs for the supplies',
            },
            style: tt.headlineSmall?.copyWith(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
            supplyRun
                ? 'Hand the device to the client to check the quantities '
                    'and sign.'
                : 'Hand the device to the client to check every item below '
                    'and sign.',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        if (!supplyRun) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Column(
              children: [
                for (final unit in units)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 18, color: AppColors.statusSuccess),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                unit.label.isEmpty ? 'Box' : unit.label,
                                style: tt.bodyMedium)),
                        Text(
                            [
                              unit.displayCode,
                              if (unit.condition != null)
                                unit.condition!.label,
                            ].join(' · '),
                            style: tt.bodySmall?.copyWith(
                                color: unit.condition ==
                                        UnitCondition.damaged
                                    ? AppColors.statusError
                                    : null)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _recipient,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name of person signing'),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppTheme.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: AppColors.surfaceContainer,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text('Client Signature', style: tt.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(_controller.clear),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Signature(
                    controller: _controller,
                    height: 200,
                    backgroundColor: Colors.white,
                  ),
                  if (_controller.isEmpty)
                    IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              color: AppColors.border, size: 28),
                          const SizedBox(height: 8),
                          Text('Signature required here',
                              style: tt.bodyMedium
                                  ?.copyWith(color: AppColors.border)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.accentDeep),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job ${jobRef(job)}',
                    style: tt.bodySmall,
                  ),
                  Text(
                      supplyRun
                          ? '$clientName · ${job.supplyItemCount} supplies'
                          : '$clientName · ${job.storageUnitIds.length} items',
                      style: tt.titleMedium),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : () => _confirm(job),
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accentDeep),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Confirm Signature'),
          ),
        ),
      ],
    );
  }
}
