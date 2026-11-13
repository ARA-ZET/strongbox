import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/client.dart';
import 'package:strong_box/core/models/invoice.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/core/utils/account_closure.dart';

StorageUnit _unit(StorageStatus status, {bool deleted = false}) => StorageUnit(
  id: status.name,
  tenantId: 't',
  clientId: 'c',
  status: status,
  isDeleted: deleted,
);

Job _job(JobStatus status, {int onceOffZar = 0, String? invoicedIn}) => Job(
  id: status.name,
  tenantId: 't',
  clientId: 'c',
  status: status,
  onceOffZar: onceOffZar,
  invoicedIn: invoicedIn,
);

Invoice _invoice(PaymentStatus status, double amount) => Invoice(
  id: '${status.name}$amount',
  tenantId: 't',
  clientId: 'c',
  status: status,
  amount: amount,
);

void main() {
  group('closureBlockers', () {
    test('nothing blocks an account with everything returned and paid', () {
      expect(
        closureBlockers(
          units: [
            _unit(StorageStatus.delivered),
            _unit(StorageStatus.pendingPickup),
            _unit(StorageStatus.inStorage, deleted: true),
          ],
          jobs: [
            _job(JobStatus.completed, onceOffZar: 300, invoicedIn: 'c_2026-10'),
            _job(JobStatus.cancelled, onceOffZar: 300),
          ],
          invoices: [
            _invoice(PaymentStatus.paid, 99),
            _invoice(PaymentStatus.voided, 50),
          ],
        ),
        isEmpty,
      );
    });

    // Same cases as functions/test/closure.test.js — the server decides,
    // so the two must agree.
    test('held items, open orders, unpaid invoices, unbilled charges', () {
      final blockers = closureBlockers(
        units: [
          _unit(StorageStatus.inStorage),
          _unit(StorageStatus.inTransit),
          _unit(StorageStatus.pendingDelivery),
          _unit(StorageStatus.delivered),
        ],
        jobs: [
          _job(JobStatus.pendingConfirmation),
          _job(JobStatus.collected, onceOffZar: 450),
          _job(JobStatus.completed, onceOffZar: 200),
        ],
        invoices: [
          _invoice(PaymentStatus.open, 149.5),
          _invoice(PaymentStatus.open, 100),
        ],
      );
      expect(blockers, [
        (kind: ClosureBlockerKind.itemsHeld, count: 3, zar: 0),
        (kind: ClosureBlockerKind.openOrders, count: 2, zar: 0),
        (kind: ClosureBlockerKind.unpaidInvoices, count: 2, zar: 250),
        (kind: ClosureBlockerKind.unbilledCharges, count: 2, zar: 650),
      ]);
    });

    test('wording differs for the client and for admins', () {
      const held = (kind: ClosureBlockerKind.itemsHeld, count: 1, zar: 0);
      expect(
        closureBlockerText(held, forClient: true),
        '1 item still in storage. Ask for them back.',
      );
      expect(
        closureBlockerText(held, forClient: false),
        '1 item still in storage. Deliver them back.',
      );
      const unpaid = (
        kind: ClosureBlockerKind.unpaidInvoices,
        count: 2,
        zar: 250,
      );
      expect(
        closureBlockerText(unpaid, forClient: false),
        '2 unpaid invoices (R250). Mark paid or void.',
      );
    });
  });

  group('AccountClosure', () {
    Client parse(Map<String, dynamic>? closure) => Client.fromJson({
      'id': 'c',
      'tenantId': 't',
      'displayName': 'Cee',
      'closure': ?closure,
    });

    test('a client without a closure is neither closing nor closed', () {
      final client = parse(null);
      expect(client.closure, isNull);
      expect(client.isClosing, isFalse);
      expect(client.isClosed, isFalse);
    });

    test('reads what requestAccountClosure writes', () {
      final client = parse({
        'status': 'requested',
        'requestedAt': Timestamp.fromDate(DateTime.utc(2026, 11, 12, 8)),
        'scheduledFor': Timestamp.fromDate(DateTime.utc(2026, 12, 12, 8)),
        'requestedBy': 'admin-1',
        'requestedByRole': 'admin',
        'reason': 'Emailed support',
      });
      expect(client.isClosing, isTrue);
      expect(client.isClosed, isFalse);
      expect(client.closure!.requestedByRole, UserRole.admin);
      expect(
        client.closure!.scheduledFor!.toUtc(),
        DateTime.utc(2026, 12, 12, 8),
      );
    });

    test('closed and purged accounts are archived records', () {
      for (final status in ['closed', 'purged']) {
        final client = parse({
          'status': status,
          'closedAt': Timestamp.fromDate(DateTime.utc(2026, 12, 12)),
          'retainUntil': Timestamp.fromDate(DateTime.utc(2031, 12, 12)),
        });
        expect(client.isClosed, isTrue, reason: status);
        expect(client.isClosing, isFalse, reason: status);
      }
    });
  });
}
