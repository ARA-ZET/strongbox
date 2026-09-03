import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/widgets/quantity_stepper.dart';

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('QuantityStepper', () {
    testWidgets('reports the incremented and decremented value', (tester) async {
      final reported = <int>[];

      await tester.pumpWidget(_host(QuantityStepper(
        value: 2,
        onChanged: reported.add,
      )));

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.remove));

      expect(reported, [3, 1]);
    });

    testWidgets('will not step below min or above max', (tester) async {
      var changed = false;

      await tester.pumpWidget(_host(QuantityStepper(
        value: 1,
        min: 1,
        max: 1,
        onChanged: (_) => changed = true,
      )));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.tap(find.byIcon(Icons.add));

      expect(changed, isFalse);
    });
  });
}
