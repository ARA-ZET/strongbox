import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/widgets/closure_checklist.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ClosureChecklist', () {
    testWidgets('ticks every check when nothing blocks', (tester) async {
      await tester.pumpWidget(
        _host(const ClosureChecklist(blockers: [], forClient: true)),
      );

      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      expect(find.text('Items returned'), findsOneWidget);
      expect(find.text('Invoices settled'), findsOneWidget);
    });

    testWidgets('shows what is left, worded for the reader', (tester) async {
      await tester.pumpWidget(
        _host(
          const ClosureChecklist(
            blockers: [(kind: ClosureBlockerKind.itemsHeld, count: 2, zar: 0)],
            forClient: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(
        find.text('2 items still in storage. Deliver them back.'),
        findsOneWidget,
      );
    });
  });
}
