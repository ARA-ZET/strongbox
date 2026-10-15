import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/inventory_providers.dart';

/// Right-side Quick Scan panel opened from the sidebar button: scan a label
/// with the camera, or type the code, to pull up the unit.
///
/// The camera only starts when the viewfinder is tapped, so opening the
/// panel never triggers a permission prompt.
class QuickScanDrawer extends ConsumerStatefulWidget {
  const QuickScanDrawer({super.key});

  @override
  ConsumerState<QuickScanDrawer> createState() => _QuickScanDrawerState();
}

class _QuickScanDrawerState extends ConsumerState<QuickScanDrawer> {
  final _controller = TextEditingController();
  MobileScannerController? _camera;
  StorageUnit? _result;
  bool _searched = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _camera?.dispose();
    super.dispose();
  }

  void _startCamera() => setState(() {
        _camera = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          formats: const [BarcodeFormat.qrCode],
        );
      });

  Future<void> _stopCamera() async {
    final camera = _camera;
    if (camera == null) return;
    setState(() => _camera = null);
    await camera.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .firstWhere((value) => value != null && value.isNotEmpty,
            orElse: () => null);
    if (code == null || _loading) return;
    _controller.text = code;
    _stopCamera();
    _lookup();
  }

  Future<void> _lookup() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = false;
    });

    StorageUnit? unit;
    try {
      unit = await ref.read(unitByQrCodeProvider(code).future);
    } catch (_) {
      unit = null; // shown as "not linked"; the code can be re-entered
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _searched = true;
      _result = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      width: 400,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick Scan', style: textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Scan a physical QR code to instantly pull up box details.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: AppRadius.md,
                  child: _camera == null
                      ? _CameraPrompt(onStart: _startCamera)
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _camera,
                              onDetect: _onDetect,
                              errorBuilder: (context, error) =>
                                  _CameraPrompt(
                                onStart: _startCamera,
                                message: error.errorCode ==
                                        MobileScannerErrorCode.permissionDenied
                                    ? 'Camera access was blocked. Allow it '
                                        'in your browser, then try again.'
                                    : 'No camera available — enter the '
                                        'code below.',
                              ),
                            ),
                            Positioned(
                              top: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: IconButton.filled(
                                tooltip: 'Stop camera',
                                style: IconButton.styleFrom(
                                    backgroundColor: AppColors.navyDeep),
                                icon: const Icon(Icons.close,
                                    color: AppColors.onNavy),
                                onPressed: _stopCamera,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Enter code manually', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'SBX-9942-A'),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _lookup(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loading ? null : _lookup,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accentDeep),
                      )
                    : const Icon(Icons.search, size: 18),
                label: const Text('Look Up'),
              ),
              const SizedBox(height: 24),
              if (_searched) _buildResult(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(TextTheme textTheme) {
    final unit = _result;
    if (unit == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusErrorBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'No box is linked to that code.',
          style: textTheme.bodyMedium
              ?.copyWith(color: AppColors.statusError),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(unit.qrCodeId, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            unit.label.isEmpty ? 'Unlabelled unit' : unit.label,
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          StatusChip(status: unit.status.name),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/admin/inventory/${unit.id}');
            },
            child: const Text('Open Unit Detail'),
          ),
        ],
      ),
    );
  }
}

/// Viewfinder idle state: tap to start the camera.
class _CameraPrompt extends StatelessWidget {
  const _CameraPrompt({required this.onStart, this.message});

  final VoidCallback onStart;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.navy,
      child: InkWell(
        onTap: onStart,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, color: AppColors.sky, size: 56),
            const SizedBox(height: AppSpacing.sm + 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                message ?? 'Tap to scan a label with your camera',
                textAlign: TextAlign.center,
                style:
                    textTheme.bodySmall?.copyWith(color: AppColors.onNavy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
