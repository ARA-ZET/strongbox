import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/core/widgets/label_print_dialog.dart';

StorageUnit _unit(
  String id,
  String client,
  String code,
  String label, {
  StorageStatus status = StorageStatus.inStorage,
}) => StorageUnit(
  id: id,
  tenantId: 'strongbox-default',
  clientId: client,
  qrCodeId: code,
  label: label,
  status: status,
);

final _units = [
  _unit(
    'u1',
    'zoe',
    'SBX-1001-A1',
    'Small Box 1',
    status: StorageStatus.pendingPickup,
  ),
  _unit('u2', 'zoe', 'SBX-1002-A2', 'Bicycle'),
  _unit('u3', 'amir', 'SBX-1003-A3', 'Desk'),
  _unit('u4', 'amir', '', 'Unlabelled'),
  _unit('u5', 'amir', 'SBX-1005-A5', 'Old', status: StorageStatus.archived),
];

Future<void> _open(WidgetTester tester, LabelPrintDialog dialog) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: dialog),
    ),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('lists only labelled, unarchived units, preselected ticked', (
    tester,
  ) async {
    await _open(
      tester,
      LabelPrintDialog(units: _units, preselected: const {'u1', 'u4'}),
    );

    expect(find.text('Small Box 1'), findsOneWidget);
    expect(find.text('Bicycle'), findsOneWidget);
    expect(find.text('Desk'), findsOneWidget);
    expect(find.text('Unlabelled'), findsNothing);
    expect(find.text('Old'), findsNothing);
    // u4 has no code, so only u1 counts.
    expect(find.text('Print 1 label'), findsOneWidget);

    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(find.text('Print 3 labels'), findsOneWidget);

    await tester.tap(find.text('None'));
    await tester.pump();
    expect(find.text('0 selected'), findsOneWidget);
  });

  testWidgets('admin view groups by client with a tick-all each', (
    tester,
  ) async {
    await _open(
      tester,
      LabelPrintDialog(
        units: _units,
        groupNames: const {'zoe': 'Zoe Mokoena', 'amir': 'Amir Patel'},
      ),
    );

    expect(find.text('Amir Patel'), findsOneWidget);
    expect(find.text('Zoe Mokoena'), findsOneWidget);
    // A–Z: Amir's group comes first.
    expect(
      tester.getTopLeft(find.text('Amir Patel')).dy,
      lessThan(tester.getTopLeft(find.text('Zoe Mokoena')).dy),
    );

    await tester.tap(find.text('Zoe Mokoena'));
    await tester.pump();
    expect(find.text('Print 2 labels'), findsOneWidget);
  });
}
