import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/invoice.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/utils/currency.dart';

// Orders = the client's jobs (pickups, deliveries, supply drop-offs), in the
// client's words. Pure functions so the portal's wording and to-dos are
// tested without widgets.

final _day = DateFormat('EEE d MMM');

/// "Pickup · 6 items", "Delivery · 1 item", "Supplies drop-off · 4 items".
String orderTitle(Job job) {
  if (job.type == JobType.supplyDrop) {
    return 'Supplies drop-off · ${_count(job.supplyItemCount, 'item')}';
  }
  return '${job.type.label} · ${_count(job.storageUnitIds.length, 'item')}';
}

/// Short status for the order's chip.
String orderStatusLabel(Job job) => switch (job.status) {
  JobStatus.pendingConfirmation => 'Awaiting confirmation',
  JobStatus.scheduled || JobStatus.assigned => 'Confirmed',
  JobStatus.inProgress =>
    job.arrivedAt != null
        ? 'Driver arrived'
        : job.departedAt != null
        ? 'On the way'
        : 'Being prepared',
  JobStatus.collected => 'Collected — in transit',
  JobStatus.completed =>
    job.type == JobType.pickup ? 'In storage' : 'Delivered',
  JobStatus.cancelled => 'Cancelled',
};

/// What happens next, in one line.
String orderNextStep(Job job) => switch (job.status) {
  JobStatus.pendingConfirmation =>
    'We\'re reviewing your request and will confirm it shortly.',
  JobStatus.scheduled => 'Confirmed — a driver will be assigned.',
  JobStatus.assigned => 'Confirmed — your driver is booked.',
  JobStatus.inProgress =>
    job.arrivedAt != null
        ? 'Your driver has arrived.'
        : job.departedAt != null
        ? 'Your driver is on the way.'
        : job.type == JobType.delivery
        ? 'Your items are being loaded at our facility.'
        : 'Your driver is getting ready.',
  JobStatus.collected =>
    'Collected — checking in at our facility '
        '(${job.receivedUnitIds.length}/${job.storageUnitIds.length}).',
  JobStatus.completed =>
    job.recipientName?.isNotEmpty == true
        ? 'Signed for by ${job.recipientName}.'
        : 'Done.',
  JobStatus.cancelled =>
    job.cancelReason?.isNotEmpty == true ? job.cancelReason! : 'Cancelled.',
};

/// Open orders, soonest first (undated last).
List<Job> activeOrders(List<Job> jobs) =>
    jobs.where((job) => job.status.isOpen).toList()..sort(
      (a, b) => (a.scheduledDate ?? DateTime(9999)).compareTo(
        b.scheduledDate ?? DateTime(9999),
      ),
    );

/// Finished and cancelled orders, newest first.
List<Job> pastOrders(List<Job> jobs) =>
    jobs.where((job) => !job.status.isOpen).toList()
      ..sort((a, b) => _finishedAt(b).compareTo(_finishedAt(a)));

DateTime _finishedAt(Job job) =>
    job.completedAt ?? job.scheduledDate ?? job.createdAt ?? DateTime(0);

/// One step on an order's timeline.
class OrderStep {
  const OrderStep(this.label, {this.done = false, this.at, this.note});

  final String label;
  final bool done;
  final DateTime? at;
  final String? note;
}

/// The order's progress, from request to done.
List<OrderStep> orderSteps(Job job) {
  final status = job.status;
  final requested = OrderStep('Requested', done: true, at: job.createdAt);
  if (status == JobStatus.cancelled) {
    return [
      requested,
      OrderStep('Cancelled', done: true, note: orderNextStep(job)),
    ];
  }
  final confirmed =
      job.confirmedAt != null || status != JobStatus.pendingConfirmation;
  final collectedOrDone =
      status == JobStatus.collected || status == JobStatus.completed;
  final done = status == JobStatus.completed;

  final steps = [
    requested,
    OrderStep('Confirmed', done: confirmed, at: job.confirmedAt),
    OrderStep(
      'Driver on the way',
      done: job.departedAt != null || collectedOrDone,
      at: job.departedAt,
    ),
    OrderStep(
      'Driver arrived',
      done: job.arrivedAt != null || collectedOrDone,
      at: job.arrivedAt,
    ),
  ];
  if (job.type == JobType.pickup) {
    steps
      ..add(OrderStep('Collected', done: collectedOrDone, at: job.collectedAt))
      ..add(
        OrderStep(
          'In storage',
          done: done,
          at: job.completedAt,
          note: status == JobStatus.collected
              ? '${job.receivedUnitIds.length} of '
                    '${job.storageUnitIds.length} checked in'
              : null,
        ),
      );
  } else {
    steps.add(
      OrderStep(
        'Delivered',
        done: done,
        at: job.completedAt,
        note: done && job.recipientName?.isNotEmpty == true
            ? 'Signed for by ${job.recipientName}'
            : null,
      ),
    );
  }
  return steps;
}

// ------------------------------------------------------------------ to-dos

enum TodoKind { live, invoice, packing }

/// Something the client should know about or do now — dashboard "To do".
class ClientTodo {
  const ClientTodo({
    required this.kind,
    required this.title,
    required this.detail,
    required this.route,
    this.urgent = false,
  });

  final TodoKind kind;
  final String title;
  final String detail;
  final String route;
  final bool urgent;
}

/// Most pressing first: a driver at the door, money owed, boxes to pack.
List<ClientTodo> clientTodos({
  required List<Job> jobs,
  required List<StorageUnit> units,
  required List<Invoice> invoices,
  required DateTime now,
}) {
  final todos = <ClientTodo>[];

  for (final job in jobs) {
    if (job.status != JobStatus.inProgress) continue;
    if (job.arrivedAt == null && job.departedAt == null) continue;
    final driver = job.driverName?.isNotEmpty == true
        ? job.driverName!
        : 'Your driver';
    todos.add(
      ClientTodo(
        kind: TodoKind.live,
        title: job.arrivedAt != null
            ? '$driver has arrived'
            : '$driver is on the way',
        detail: '${orderTitle(job)} — check their E-ID on the order.',
        route: '/client/orders/${job.id}',
        urgent: true,
      ),
    );
  }

  for (final invoice in invoices) {
    if (invoice.status != PaymentStatus.open || invoice.amount <= 0) continue;
    final overdue = invoice.dueAt != null && invoice.dueAt!.isBefore(now);
    todos.add(
      ClientTodo(
        kind: TodoKind.invoice,
        title: overdue
            ? 'Invoice ${invoice.reference} is overdue'
            : 'Invoice ${invoice.reference} to pay',
        detail:
            '${formatZarExact(invoice.amount)}'
            '${invoice.dueAt == null ? '' : ' · due ${_day.format(invoice.dueAt!)}'}'
            ' · pay by EFT quoting the reference.',
        route: '/client/subscription',
        urgent: overdue,
      ),
    );
  }

  final byId = {for (final unit in units) unit.id: unit};
  for (final job in jobs) {
    if (job.type != JobType.pickup || !job.status.isOpen) continue;
    if (job.status == JobStatus.collected) continue;
    final toPack = [
      for (final id in job.storageUnitIds)
        if (byId[id]?.status == StorageStatus.pendingPickup) byId[id]!,
    ];
    if (toPack.isEmpty) continue;
    final photographed = toPack.where((u) => u.photoIds.isNotEmpty).length;
    final when = job.scheduledDate == null
        ? ''
        : ' for ${_day.format(job.scheduledDate!)}';
    todos.add(
      ClientTodo(
        kind: TodoKind.packing,
        title: 'Get ${_count(toPack.length, 'item')} ready$when',
        detail:
            'Label each one and photograph what you pack — '
            '$photographed of ${toPack.length} photographed.',
        route: '/client/orders/${job.id}',
      ),
    );
  }
  return todos;
}

/// Total of open invoices, and whether any is past due.
({double due, bool overdue, DateTime? nextDue}) balanceDue(
  List<Invoice> invoices,
  DateTime now,
) {
  var due = 0.0;
  var overdue = false;
  DateTime? nextDue;
  for (final invoice in invoices) {
    if (invoice.status != PaymentStatus.open) continue;
    due += invoice.amount;
    final at = invoice.dueAt;
    if (at == null) continue;
    if (at.isBefore(now)) overdue = true;
    if (nextDue == null || at.isBefore(nextDue)) nextDue = at;
  }
  return (due: due, overdue: overdue, nextDue: nextDue);
}

/// `2026-11` → "November 2026" (invoice month an order was billed on).
String invoiceMonthLabel(String yyyyMm) {
  final parsed = DateTime.tryParse('$yyyyMm-01');
  return parsed == null ? yyyyMm : DateFormat('MMMM y').format(parsed);
}

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';
