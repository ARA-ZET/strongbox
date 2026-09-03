import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:strong_box/core/widgets/primary_button.dart';
import 'package:strong_box/core/widgets/status_chip.dart';
import 'package:strong_box/core/widgets/step_indicator.dart';

void main() {
  testWidgets('StatusChip renders humanised label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: 'in_transit')),
      ),
    );
    expect(find.text('In Transit'), findsOneWidget);
  });

  testWidgets('PrimaryButton shows spinner when loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Sign In', onPressed: () {}, loading: true),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('StepIndicator marks completed and active steps',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StepIndicator(
            steps: ['Profile', 'Billing', 'Review'],
            currentStep: 1,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget); // step 1 completed
    expect(find.text('2'), findsOneWidget); // active step number
    expect(find.text('3'), findsOneWidget); // future step number
  });
}
