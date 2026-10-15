import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/core/widgets/dialog_actions.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  /// Inside a real dialog with the app theme, whose elevated buttons are
  /// full-width — the case that used to make the buttons vanish.
  Future<void> pump(WidgetTester tester, Widget actions) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const Text('Title'), actions],
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('both buttons render under the app theme', (tester) async {
    var saved = 0;
    await pump(tester,
        DialogActions(saveLabel: 'Send Invite', onSave: () => saved++));
    expect(tester.takeException(), isNull);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Send Invite'), findsOneWidget);
    expect(tester.getSize(find.byType(ElevatedButton)).width,
        lessThan(300)); // a normal button, not full-width
    await tester.tap(find.text('Send Invite'));
    expect(saved, 1);
  });

  testWidgets('saving shows a spinner and disables both', (tester) async {
    var saved = 0;
    await pump(tester, DialogActions(
        saveLabel: 'Save', saving: true, onSave: () => saved++));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.byType(ElevatedButton));
    expect(saved, 0);
    expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
  });
}
