import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/widgets/storage_image.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: SizedBox(width: 80, height: 80, child: child)),
  );

  testWidgets('no URL shows the broken-image fallback', (tester) async {
    await tester.pumpWidget(host(const StorageImage('')));
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('a custom error widget replaces the fallback', (tester) async {
    await tester.pumpWidget(
      host(const StorageImage('', error: Text('No photo yet'))),
    );
    expect(find.text('No photo yet'), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
  });
}
