import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/client.dart';
import 'package:strong_box/core/models/invoice.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/billing/providers/billing_providers.dart';
import 'package:strong_box/features/billing/widgets/invoice_table.dart';
import 'package:strong_box/repositories/repository_providers.dart';
import 'package:strong_box/repositories/subscription_repository.dart';

class _FakeBillingRepository implements SubscriptionRepository {
  final paid = <(String, String, String?)>[];
  final voided = <(String, String, String)>[];

  @override
  Stream<List<Invoice>> watchInvoices(String tenantId, String clientId) =>
      Stream.value(const []);

  @override
  Future<void> markPaid(Invoice invoice,
      {required String actorId, String? note}) async {
    paid.add((invoice.id, actorId, note));
  }

  @override
  Future<void> voidInvoice(Invoice invoice,
      {required String actorId, required String reason}) async {
    voided.add((invoice.id, actorId, reason));
  }
}

/// An invoice doc exactly as the monthlyInvoices function writes it.
Map<String, dynamic> _functionDoc() => {
      'tenantId': 'strongbox-default',
      'clientId': 'abc123',
      'reference': 'INV-202611-ABC123',
      'description': 'Storage — November 2026',
      'amount': 490,
      'currency': 'zar',
      'status': 'open',
      'lines': [
        {
          'unitId': 'u1',
          'qrCodeId': 'SBX-0001-A1',
          'label': 'Books',
          'priceKey': 'small',
          'rateZar': 195,
        },
        {
          'unitId': 'u2',
          'qrCodeId': 'SBX-0002-A1',
          'label': '',
          'priceKey': null,
          'rateZar': 295,
        },
      ],
      'unitCount': 2,
      'unpricedUnitCount': 1,
      'periodStart': Timestamp.fromDate(DateTime.utc(2026, 10, 31, 22)),
      'periodEnd': Timestamp.fromDate(DateTime.utc(2026, 11, 30, 22)),
      'dueAt': Timestamp.fromDate(DateTime.utc(2026, 11, 7, 22)),
      'isDeleted': false,
    };

const _client = Client(
  id: 'abc123',
  tenantId: 'strongbox-default',
  displayName: 'Thandi Nkosi',
);

void main() {
  group('Invoice', () {
    test('parses what the monthlyInvoices function writes', () {
      final invoice = Invoice.fromJson({..._functionDoc(), 'id': 'abc_2026-11'});
      expect(invoice.amount, 490);
      expect(invoice.status, PaymentStatus.open);
      expect(invoice.lines.map((l) => l.rateZar), [195, 295]);
      expect(invoice.lines.last.priceKey, isNull);
      expect(invoice.unpricedUnitCount, 1);
      expect(invoice.dueAt, DateTime.utc(2026, 11, 7, 22).toLocal());
    });

    test('is overdue only while open and past its due date', () {
      final invoice =
          Invoice.fromJson({..._functionDoc(), 'id': 'abc_2026-11'});
      final before = DateTime.utc(2026, 11, 5);
      final after = DateTime.utc(2026, 11, 9);
      expect(invoice.isOverdue(before), isFalse);
      expect(invoice.isOverdue(after), isTrue);
      expect(invoice.copyWith(status: PaymentStatus.paid).isOverdue(after),
          isFalse);
    });
  });

  group('InvoiceActions', () {
    late _FakeBillingRepository repo;
    late ProviderContainer container;
    final invoice = Invoice.fromJson({..._functionDoc(), 'id': 'inv-1'});

    setUp(() {
      repo = _FakeBillingRepository();
      container = ProviderContainer(overrides: [
        subscriptionRepositoryProvider.overrideWithValue(repo),
        currentActorIdProvider.overrideWithValue('admin-1'),
      ]);
    });
    tearDown(() => container.dispose());

    test('records the payment with the acting admin', () async {
      await container
          .read(invoiceActionsProvider.notifier)
          .markPaid(invoice, note: 'EFT 12 Nov');
      expect(repo.paid, [('inv-1', 'admin-1', 'EFT 12 Nov')]);
    });

    test('voids with a reason', () async {
      await container
          .read(invoiceActionsProvider.notifier)
          .voidInvoice(invoice, 'Billed in error');
      expect(repo.voided, [('inv-1', 'admin-1', 'Billed in error')]);
    });
  });

  group('InvoiceTable', () {
    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

    Future<_FakeBillingRepository> pump(WidgetTester tester,
        {required bool canSettle, PaymentStatus status = PaymentStatus.open}) async {
      final repo = _FakeBillingRepository();
      final invoice = Invoice.fromJson(
          {..._functionDoc(), 'id': 'inv-1', 'status': status.name});
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repo),
          currentActorIdProvider.overrideWithValue('admin-1'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: InvoiceTable(
              invoices: AsyncData([invoice]),
              client: _client,
              canSettle: canSettle,
            ),
          ),
        ),
      ));
      return repo;
    }

    testWidgets('lists the period, reference and amount', (tester) async {
      await pump(tester, canSettle: false);
      expect(find.text('Storage — November 2026'), findsOneWidget);
      expect(find.text('INV-202611-ABC123'), findsOneWidget);
      expect(find.text('R490.00'), findsOneWidget);
    });

    testWidgets('clients can only download', (tester) async {
      await pump(tester, canSettle: false);
      await tester.tap(find.byTooltip('Invoice actions'));
      await tester.pumpAndSettle();
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Mark paid…'), findsNothing);
    });

    testWidgets('an admin marks an open invoice paid', (tester) async {
      final repo = await pump(tester, canSettle: true);
      await tester.tap(find.byTooltip('Invoice actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark paid…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'EFT received');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Mark paid'));
      await tester.pumpAndSettle();
      expect(repo.paid, [('inv-1', 'admin-1', 'EFT received')]);
      expect(find.text('INV-202611-ABC123 marked paid'), findsOneWidget);
    });

    testWidgets('voiding needs a reason', (tester) async {
      final repo = await pump(tester, canSettle: true);
      await tester.tap(find.byTooltip('Invoice actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Void…'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Void invoice'));
      await tester.pumpAndSettle();
      expect(repo.voided, isEmpty);
      await tester.enterText(find.byType(TextField), 'Billed in error');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Void invoice'));
      await tester.pumpAndSettle();
      expect(repo.voided, [('inv-1', 'admin-1', 'Billed in error')]);
    });

    testWidgets('settled invoices cannot be settled again', (tester) async {
      await pump(tester, canSettle: true, status: PaymentStatus.paid);
      await tester.tap(find.byTooltip('Invoice actions'));
      await tester.pumpAndSettle();
      expect(find.text('Mark paid…'), findsNothing);
      expect(find.text('Void…'), findsNothing);
    });
  });
}
