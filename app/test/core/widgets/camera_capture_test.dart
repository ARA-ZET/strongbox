import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/widgets/camera_capture.dart';

void main() {
  tearDown(() => CameraCapture.listCameras = availableCameras);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: CameraCapture(title: 'Box photo')));
    await tester.pumpAndSettle();
  }

  testWidgets('with no camera it offers choosing a photo instead',
      (tester) async {
    CameraCapture.listCameras = () async => const [];
    await pump(tester);
    expect(find.text('No camera found on this device.'), findsOneWidget);
    expect(find.text('Choose a photo instead'), findsOneWidget);
    expect(find.bySemanticsLabel('Take photo'), findsNothing); // no shutter
  });

  testWidgets('a blocked camera says how to allow it', (tester) async {
    CameraCapture.listCameras =
        () async => throw CameraException('CameraAccessDenied', 'denied');
    await pump(tester);
    expect(find.textContaining('Camera access is blocked'), findsOneWidget);
    expect(find.text('Try the camera again'), findsOneWidget);
  });
}
