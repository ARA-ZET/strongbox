import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Full-screen in-app camera: live preview, shutter, front/back switch,
/// then Retake / Use photo. Returns the JPEG, or null if cancelled.
///
/// Unlike `ImagePicker(source: camera)` — which on the web is a file input
/// that only phones turn into a camera — this opens the camera itself in
/// every browser (getUserMedia) and natively on iOS / Android. With no
/// camera, or permission refused, it offers choosing a file instead.
class CameraCapture extends StatefulWidget {
  const CameraCapture({super.key, this.title = 'Take photo'});

  final String title;

  /// Lists the device's cameras — swapped out in tests.
  @visibleForTesting
  static Future<List<CameraDescription>> Function() listCameras =
      availableCameras;

  /// Opens the camera over everything (shells included).
  static Future<Uint8List?> open(
    BuildContext context, {
    String title = 'Take photo',
  }) => Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => CameraCapture(title: title),
    ),
  );

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  int _index = 0;
  CameraController? _controller;
  Uint8List? _shot;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // Release the camera while the app is in the background (native apps).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _shot == null) {
      _open(_cameras[_index]);
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await CameraCapture.listCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      // The back camera is the one for photographing boxes.
      final back = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameras = cameras;
      _index = back == -1 ? 0 : back;
      await _open(cameras[_index]);
    } catch (error) {
      if (mounted) setState(() => _error = _describe(error));
    }
  }

  Future<void> _open(CameraDescription camera) async {
    final previous = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    setState(() {
      _controller = null;
      _error = null;
    });
    await previous?.dispose();
    try {
      await controller.initialize();
    } catch (error) {
      await controller.dispose();
      if (mounted) setState(() => _error = _describe(error));
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  String _describe(Object error) {
    final code = error is CameraException ? error.code : '';
    if (code.contains('Denied') ||
        code.contains('Permission') ||
        code == 'permissionDenied') {
      return 'Camera access is blocked. Allow the camera for this site or '
          'app in your settings, or choose a photo from your files.';
    }
    if (code == 'cameraNotFound' || code == 'notFound') {
      return 'No camera found on this device.';
    }
    return 'Could not start the camera.';
  }

  Future<void> _snap() async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _shot = bytes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not take the photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switch() async {
    if (_cameras.length < 2 || _busy) return;
    _index = (_index + 1) % _cameras.length;
    await _open(_cameras[_index]);
  }

  /// Fallback when there's no usable camera.
  Future<void> _chooseFile() async {
    final navigator = Navigator.of(context);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    navigator.pop(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final controller = _controller;
    final shot = _shot;

    final Widget body;
    if (shot != null) {
      body = Center(child: Image.memory(shot, fit: BoxFit.contain));
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 48,
                color: AppColors.sky,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: AppColors.onNavy),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _chooseFile,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose a photo instead'),
              ),
              TextButton(
                onPressed: _start,
                child: const Text(
                  'Try the camera again',
                  style: TextStyle(color: AppColors.onNavy),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (controller == null || !controller.value.isInitialized) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Center(child: CameraPreview(controller));
    }

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: AppColors.onNavy,
        title: Text(widget.title),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: shot != null
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              foregroundColor: AppColors.onNavy,
                              side: const BorderSide(color: AppColors.navySoft),
                            ),
                            onPressed: () => setState(() => _shot = null),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retake'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                            ),
                            onPressed: () => Navigator.of(context).pop(shot),
                            icon: const Icon(Icons.check),
                            label: const Text('Use photo'),
                          ),
                        ),
                      ],
                    )
                  : _error != null
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 56),
                        const Spacer(),
                        // Shutter.
                        Semantics(
                          button: true,
                          label: 'Take photo',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: controller == null || _busy ? null : _snap,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.onNavy,
                                  width: 4,
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _busy
                                      ? AppColors.navySoft
                                      : AppColors.onNavy,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 56,
                          child: _cameras.length > 1
                              ? IconButton(
                                  tooltip: 'Switch camera',
                                  color: AppColors.onNavy,
                                  onPressed: _busy ? null : _switch,
                                  icon: const Icon(
                                    Icons.flip_camera_android_outlined,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
