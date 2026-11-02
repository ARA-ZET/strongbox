import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/invoice.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/features/client/utils/client_orders.dart';

const _t = 'strongbox-default';
final _now = DateTime(2026, 11, 10, 9);

Job _job(
  String id, {
  JobType type = JobType.pickup,
  JobStatus status = JobStatus.scheduled,
  List<String> units = const [],
  DateTime? date,
  DateTime? departedAt,
  DateTime? arrivedAt,
  String? driverName,
}) => Job(
  id: id,
  tenantId: _t,
  clientId: 'c1',
  type: type,
  status: status,
  storageUnitIds: units,
  scheduledDate: date,
  departedAt: departedAt,
  arrivedAt: arrivedAt,
  driverName: driverName,
);

StorageUnit _unit(
  String id, {
  StorageStatus status = StorageStatus.pendingPickup,
  List<String> photos = const [],
}) => StorageUnit(
  id: id,
  tenantId: _t,
  clientId: 'c1',
  status: status,
  photoIds: photos,
);

void main() {
  group('orders', () {
    test('active soonest first, past newest first', () {
      final jobs = [
        _job('late', date: DateTime(2026, 11, 20)),
        _job('soon', date: DateTime(2026, 11, 12)),
        _job('undated', status: JobStatus.pendingConfirmation),
        _job('old', status: JobStatus.completed, date: DateTime(2026, 10, 1)),
        _job(
          'newer',
          status: JobStatus.cancelled,
          date: DateTime(2026, 10, 20),
        ),
      ];
      expect(activeOrders(jobs).map((j) => j.id), ['soon', 'late', 'undated']);
      expect(pastOrders(jobs).map((j) => j.id), ['newer', 'old']);
    });

    test('status in the client\'s words', () {
      expect(
        orderStatusLabel(_job('a', status: JobStatus.pendingConfirmation)),
        'Awaiting confirmation',
      );
      expect(
        orderStatusLabel(
          _job('a', status: JobStatus.inProgress, departedAt: _now),
        ),
        'On the way',
      );
      expect(
        orderStatusLabel(_job('a', status: JobStatus.completed)),
        'In storage',
      );
      expect(
        orderStatusLabel(
          _job('a', type: JobType.delivery, status: JobStatus.completed),
        ),
        'Delivered',
      );
      expect(orderTitle(_job('a', units: ['u1', 'u2'])), 'Pickup · 2 items');
    });

    test('a pickup\'s timeline runs to "In storage"', () {
      final steps = orderSteps(
        _job('a', status: JobStatus.collected, units: ['u1', 'u2']),
      );
      expect(steps.map((s) => s.label), [
        'Requested',
        'Confirmed',
        'Driver on the way',
        'Driver arrived',
        'Collected',
        'In storage',
      ]);
      expect(steps.map((s) => s.done), [true, true, true, true, true, false]);
      expect(steps.last.note, '0 of 2 checked in');
    });

    test('a cancelled order ends at Cancelled', () {
      final steps = orderSteps(_job('a', status: JobStatus.cancelled));
      expect(steps.map((s) => s.label), ['Requested', 'Cancelled']);
    });
  });

  group('to-dos', () {
    test('driver at the door, then money, then packing', () {
      final todos = clientTodos(
        jobs: [
          _job(
            'pickup',
            units: ['u1', 'u2', 'u3'],
            date: DateTime(2026, 11, 12),
          ),
          _job(
            'delivery',
            type: JobType.delivery,
            status: JobStatus.inProgress,
            departedAt: _now,
            driverName: 'Thabo',
          ),
        ],
        units: [
          _unit('u1', photos: ['p1']),
          _unit('u2'),
          _unit('u3', status: StorageStatus.inTransit),
        ],
        invoices: [
          Invoice(
            id: 'i1',
            tenantId: _t,
            clientId: 'c1',
            reference: 'SB-123',
            amount: 590,
            dueAt: DateTime(2026, 11, 7),
          ),
          const Invoice(
            id: 'i2',
            tenantId: _t,
            clientId: 'c1',
            amount: 100,
            status: PaymentStatus.paid,
          ),
        ],
        now: _now,
      );
      expect(todos.map((t) => t.kind), [
        TodoKind.live,
        TodoKind.invoice,
        TodoKind.packing,
      ]);
      expect(todos[0].title, 'Thabo is on the way');
      expect(todos[0].route, '/client/orders/delivery');
      expect(todos[1].title, 'Invoice SB-123 is overdue');
      expect(todos[1].urgent, isTrue);
      // u3 is already collected — two left to pack, one photographed.
      expect(todos[2].title, 'Get 2 items ready for Thu 12 Nov');
      expect(todos[2].detail, contains('1 of 2 photographed'));
    });

    test('nothing to do when all is quiet', () {
      expect(
        clientTodos(
          jobs: [_job('done', status: JobStatus.completed)],
          units: [_unit('u1', status: StorageStatus.inStorage)],
          invoices: const [],
          now: _now,
        ),
        isEmpty,
      );
    });
  });

  test('balance due adds open invoices and flags overdue', () {
    final balance = balanceDue([
      Invoice(
        id: 'a',
        tenantId: _t,
        clientId: 'c1',
        amount: 100,
        dueAt: DateTime(2026, 11, 20),
      ),
      Invoice(
        id: 'b',
        tenantId: _t,
        clientId: 'c1',
        amount: 50,
        dueAt: DateTime(2026, 11, 1),
      ),
      const Invoice(
        id: 'c',
        tenantId: _t,
        clientId: 'c1',
        amount: 999,
        status: PaymentStatus.voided,
      ),
    ], _now);
    expect(balance.due, 150);
    expect(balance.overdue, isTrue);
    expect(balance.nextDue, DateTime(2026, 11, 1));
    expect(invoiceMonthLabel('2026-11'), 'November 2026');
  });
}
