import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/storage_unit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/inventory_providers.dart';

/// Right-side Quick Scan panel opened from the sidebar button.
///
/// Stage 2 ships manual code entry with a live Firestore lookup; the camera
/// viewfinder wires into this panel when the scanner is built in Stage 3.
class QuickScanDrawer extends ConsumerStatefulWidget {
  const QuickScanDrawer({super.key});

  @override
  ConsumerState<QuickScanDrawer> createState() => _QuickScanDrawerState();
}

class _QuickScanDrawerState extends ConsumerState<QuickScanDrawer> {
  final _controller = TextEditingController();
  StorageUnit? _result;
  bool _searched = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = false;
    });

    final unit = await ref.read(unitByQrCodeProvider(code).future);

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
              // Viewfinder placeholder — camera scanning lands in Stage 3.
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner,
                          color: AppColors.amber, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'Camera scanner arrives with the\nQR module (Stage 3)',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.white70),
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
                            strokeWidth: 2, color: AppColors.amberDark),
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
