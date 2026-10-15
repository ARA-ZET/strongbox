import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/widgets/app_data_table.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AppDataTable(
          minWidth: 600,
          columns: [
            TableColumnSpec('Name', flex: 2),
            TableColumnSpec('Status'),
          ],
          rows: [
            [Text('Thandi'), Text('Active')],
          ],
        ),
      ),
    ));
  }

  testWidgets('fills a wide screen', (tester) async {
    await pump(tester, 1200);
    expect(tester.takeException(), isNull);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('Thandi'), findsOneWidget);
    // Two-thirds of the row goes to the flex-2 column.
    expect(tester.getTopLeft(find.text('Active')).dx, greaterThan(700));
  });

  testWidgets('scrolls sideways below its minimum width', (tester) async {
    await pump(tester, 360);
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.getSize(find.byType(SingleChildScrollView)).width, 360);
  });
}
