import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../../admin/providers/clients_providers.dart';
import '../providers/driver_jobs_providers.dart';

/// Full-screen camera QR scanner. When [jobId] is set, a successful scan
/// confirms the box on that job; standalone scans just show box info.
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
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (raw == null) return;
    await _handleCode(raw);
  }

  Future<void> _handleCode(String code) async {
    setState(() => _handling = true);
    await _controller.stop();

    final box = await ref.read(unitByScanProvider(code).future);
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

    final clientName =
        ref.read(clientNamesProvider)[box.clientId] ?? 'Client';
    final pickup = job?.type == JobType.pickup;

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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(job == null
                      ? 'Done'
                      : pickup
                          ? 'Confirm Pickup'
                          : 'Confirm Delivery'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((confirmed) async {
      if (confirmed == true && job != null) {
        await ref
            .read(driverJobActionsProvider.notifier)
            .confirmUnit(job.id, box.id);
        if (mounted) context.go('/driver/jobs/${job.id}');
        return;
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
      await _handleCode(code.toUpperCase());
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
                border: Border.all(color: AppColors.amber, width: 3),
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
                    _circleButton(Icons.close,
                        () => context.go('/driver/jobs')),
                    Row(
                      children: [
                        _circleButton(Icons.bolt,
                            () => _controller.toggleTorch()),
                        const SizedBox(width: 12),
                        _circleButton(Icons.help_outline, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Align the QR code within the amber frame.')),
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
                    Text('SCANNING…',
                        style: tt.labelLarge?.copyWith(
                            color: AppColors.amber,
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
