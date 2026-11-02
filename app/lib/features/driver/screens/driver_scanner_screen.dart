import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../admin/providers/clients_providers.dart';
import '../providers/driver_jobs_providers.dart';
import '../../../core/utils/qr_link.dart';

/// Full-screen camera QR scanner. When [jobId] is set, a successful scan
/// records the box for the job's current step ([scanStepFor]: collect,
/// receive into a bay, load out, or hand over) and keeps scanning until the
/// step is done; standalone scans just show box info.
/// Design: driver_qr_scanner/screen.png.
class DriverScannerScreen extends ConsumerStatefulWidget {
  const DriverScannerScreen({super.key, this.jobId});

  final String? jobId;

  @override
  ConsumerState<DriverScannerScreen> createState() =>
      _DriverScannerScreenState();
}

class _DriverScannerScreenState extends ConsumerState<DriverScannerScreen> {
  final _controller = MobileScannerController();
  final _bay = TextEditingController();
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    _bay.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (raw == null) return;
    // Labels hold a link to the item; older ones just the code.
    await _handleCode(codeFromScan(raw));
  }

  Future<void> _handleCode(String code) async {
    setState(() => _handling = true);
    await _controller.stop();

    final StorageUnit? box;
    try {
      box = await ref.read(unitByScanProvider(code).future);
    } catch (error) {
      if (mounted) await _showError('Could not look up “$code”: $error');
      return;
    }
    if (!mounted) return;

    if (box == null) {
      await _showError('No box is linked to “$code”.');
      return;
    }
    await _showResult(box);
  }

  Future<void> _showError(String message) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppColors.statusError),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
    if (mounted) {
      setState(() => _handling = false);
      await _controller.start();
    }
  }

  Future<void> _showResult(StorageUnit box) async {
    final jobId = widget.jobId;
    final job = jobId == null
        ? null
        : await ref.read(driverJobProvider(jobId).future);
    if (!mounted) return;

    // Only boxes on this job's manifest can be confirmed against it.
    if (job != null && !job.storageUnitIds.contains(box.id)) {
      await _showError('${box.qrCodeId} is not on this job\'s manifest.');
      return;
    }

    final step = job == null ? null : scanStepFor(job);
    if (job != null && step == null) {
      await _showError('Nothing to scan on this job right now.');
      return;
    }
    if (job != null && step!.doneOn(job).contains(box.id)) {
      await _showError('${box.displayCode} is already scanned.');
      return;
    }

    final clientName =
        ref.read(clientNamesProvider)[box.clientId] ?? 'Client';

    await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final tt = Theme.of(sheetContext).textTheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('VERIFIED',
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.statusSuccess,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Text(box.qrCodeId, style: tt.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(box.label.isEmpty ? 'Storage Box' : box.label,
                  style: tt.headlineSmall?.copyWith(fontSize: 18)),
              Text('Client: $clientName', style: tt.bodyMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _statChip('Type',
                          box.type == UnitType.open ? 'Open Box' : 'Closed Box', tt)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statChip(
                          'Status', _prettyStatus(box.status.name), tt)),
                ],
              ),
              if (step == ScanStep.receive) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _bay,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Storage bay / shelf (optional)',
                    hintText: 'e.g. B-12',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(switch (step) {
                    null => 'Done',
                    ScanStep.collect => 'Confirm Collected',
                    ScanStep.receive => 'Confirm In Storage',
                    ScanStep.load => 'Confirm Loaded',
                    ScanStep.handOver => 'Confirm Handed Over',
                  }),
                ),
              ),
              if (step != null)
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Not this one — keep scanning'),
                ),
            ],
          ),
        );
      },
    ).then((confirmed) async {
      if (confirmed == true && job != null && step != null) {
        try {
          await ref.read(driverJobActionsProvider.notifier).confirmUnit(
              job.id, box.id,
              step: step, bay: step == ScanStep.receive ? _bay.text : null);
        } catch (error) {
          if (mounted) await _showError('Could not confirm box: $error');
          return;
        }
        if (!mounted) return;
        final left = job.storageUnitIds.length - step.doneOn(job).length - 1;
        if (left <= 0) {
          context.go('/driver/jobs/${job.id}');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${box.displayCode} done — $left to go')));
      }
      // Standalone scan or dismissed — resume scanning.
      if (mounted) {
        setState(() => _handling = false);
        await _controller.start();
      }
    });
  }

  Widget _statChip(String label, String value, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.bodySmall),
          const SizedBox(height: 2),
          Text(value,
              style: tt.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  String _prettyStatus(String status) => status
      .split('_')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    await _controller.stop();
    if (!mounted) return;
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Enter tracking number'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'SBX-9942-A1'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Look Up'),
          ),
        ],
      ),
    );
    if (code != null && code.isNotEmpty) {
      await _handleCode(codeFromScan(code));
    } else if (mounted) {
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Dim overlay + viewfinder.
          Center(
            child: Container(
              width: 260,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.sky, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                        Icons.close,
                        () => context.go(widget.jobId == null
                            ? '/driver/jobs'
                            : '/driver/jobs/${widget.jobId}')),
                    Row(
                      children: [
                        _circleButton(Icons.bolt,
                            () => _controller.toggleTorch()),
                        const SizedBox(width: 12),
                        _circleButton(Icons.help_outline, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Align the QR code within the blue frame.')),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.jobId != null)
                      Consumer(builder: (context, ref, _) {
                        final job =
                            ref.watch(driverJobProvider(widget.jobId!)).valueOrNull;
                        final step = job == null ? null : scanStepFor(job);
                        if (job == null || step == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${step.title} · ${step.doneOn(job).length}/'
                            '${job.storageUnitIds.length}',
                            style: tt.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        );
                      }),
                    Text('SCANNING…',
                        style: tt.labelLarge?.copyWith(
                            color: AppColors.sky,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Align the QR code within the frame',
                        style:
                            tt.bodySmall?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _manualEntry,
                      child: Text(
                        'Enter Tracking Number Manually',
                        style: tt.labelLarge?.copyWith(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
