import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/driver_jobs_providers.dart';

/// Cargo-verification capture flow. Uses the platform camera via
/// image_picker (native camera UI on mobile, file picker on web), collects
/// up to four photos, then uploads them to the job.
/// Design: driver_photo_capture/screen.png.
class DriverPhotoCaptureScreen extends ConsumerStatefulWidget {
  const DriverPhotoCaptureScreen({
    super.key,
    required this.jobId,
    required this.boxId,
  });

  final String jobId;
  final String boxId;

  @override
  ConsumerState<DriverPhotoCaptureScreen> createState() =>
      _DriverPhotoCaptureScreenState();
}

class _DriverPhotoCaptureScreenState
    extends ConsumerState<DriverPhotoCaptureScreen> {
  static const _maxPhotos = 4;
  final _picker = ImagePicker();
  final List<Uint8List> _photos = [];
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    // Jump straight to the camera on open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (_photos.length >= _maxPhotos) return;
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _photos.add(bytes));
    await _confirmSheet(bytes);
  }

  Future<void> _confirmSheet(Uint8List bytes) async {
    final keep = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
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
              Text('Confirm Capture', style: tt.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Ensure the label and cargo condition are clearly visible '
                'before proceeding.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(bytes,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(false),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Use Photo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (keep == false && mounted) {
      // Drop the just-taken shot and offer the camera again.
      setState(() => _photos.removeLast());
      await _capture();
    }
  }

  Future<void> _finish() async {
    if (_photos.isEmpty) {
      context.go('/driver/jobs/${widget.jobId}');
      return;
    }
    setState(() => _uploading = true);
    try {
      final actions = ref.read(driverJobActionsProvider.notifier);
      for (final bytes in _photos) {
        await actions.uploadCapturePhoto(widget.jobId, widget.boxId, bytes);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_photos.length} photos uploaded')),
        );
        context.go('/driver/jobs/${widget.jobId}');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/driver/jobs/${widget.jobId}'),
        ),
        title: Column(
          children: [
            Text('Cargo Verification',
                style: tt.titleMedium?.copyWith(color: Colors.white)),
            Text('Box capture',
                style: tt.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.center_focus_strong,
                        size: 64, color: AppColors.amber),
                    const SizedBox(height: 16),
                    Text('Center cargo inside the frame',
                        style:
                            tt.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 24),
                    Text('${_photos.length} / $_maxPhotos Photos',
                        style: tt.titleMedium
                            ?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
            // Photo strip.
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < _maxPhotos; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: i < _photos.length
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(_photos[i],
                                  width: 60, height: 60, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(Icons.image_outlined,
                                  color: Colors.white24),
                            ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: _photos.length >= _maxPhotos || _uploading
                        ? null
                        : _capture,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Capture'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52)),
                    onPressed: _uploading ? null : _finish,
                    icon: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.amberDark),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
