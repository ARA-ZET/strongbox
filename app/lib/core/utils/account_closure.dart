import '../enums/app_enums.dart';
import '../models/invoice.dart';
import '../models/job.dart';
import '../models/storage_unit.dart';
import 'currency.dart';

/// Days between asking to close an account and it closing
/// (CLOSURE_GRACE_DAYS in functions/src/closure.js).
const closureGraceDays = 30;

/// Years a closed account's records are kept before they are purged
/// (RETAIN_YEARS in functions/src/closure.js; the website's privacy policy).
const closureRetentionYears = 5;

/// One thing stopping an account closing: how many, and the Rand amount
/// for invoices and charges.
typedef ClosureBlocker = ({ClosureBlockerKind kind, int count, int zar});

/// What stops a client's account closing. Mirrors closureBlockers() in
/// functions/src/closure.js, which decides. Nobody's details are erased
/// while we still hold their things, owe them a visit, or are owed money.
List<ClosureBlocker> closureBlockers({
  required List<StorageUnit> units,
  required List<Job> jobs,
  required List<Invoice> invoices,
}) {
  final blockers = <ClosureBlocker>[];
  final held = units.where((u) => !u.isDeleted && u.status.isBillable).length;
  if (held > 0) {
    blockers.add((kind: ClosureBlockerKind.itemsHeld, count: held, zar: 0));
  }
  final open = jobs.where((j) => !j.isDeleted && j.status.isOpen).length;
  if (open > 0) {
    blockers.add((kind: ClosureBlockerKind.openOrders, count: open, zar: 0));
  }
  final unpaid = invoices
      .where((i) => !i.isDeleted && i.status == PaymentStatus.open)
      .toList();
  if (unpaid.isNotEmpty) {
    blockers.add((
      kind: ClosureBlockerKind.unpaidInvoices,
      count: unpaid.length,
      zar: unpaid.fold<double>(0, (sum, i) => sum + i.amount).round(),
    ));
  }
  final unbilled = jobs
      .where(
        (j) =>
            !j.isDeleted &&
            (j.status == JobStatus.collected ||
                j.status == JobStatus.completed) &&
            j.onceOffZar > 0 &&
            j.invoicedIn == null,
      )
      .toList();
  if (unbilled.isNotEmpty) {
    blockers.add((
      kind: ClosureBlockerKind.unbilledCharges,
      count: unbilled.length,
      zar: unbilled.fold(0, (sum, j) => sum + j.onceOffZar),
    ));
  }
  return blockers;
}

String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';

/// The checklist line for [kind], phrased as done ("Items returned").
String closureCheckLabel(ClosureBlockerKind kind) => switch (kind) {
  ClosureBlockerKind.itemsHeld => 'Items returned',
  ClosureBlockerKind.openOrders => 'Orders finished',
  ClosureBlockerKind.unpaidInvoices => 'Invoices settled',
  ClosureBlockerKind.unbilledCharges => 'Charges invoiced',
};

/// What a blocker means and what to do about it — worded for the client
/// ([forClient]) or for an admin.
String closureBlockerText(ClosureBlocker blocker, {required bool forClient}) {
  final n = blocker.count;
  final zar = formatZar(blocker.zar);
  return switch (blocker.kind) {
    ClosureBlockerKind.itemsHeld =>
      forClient
          ? '${_plural(n, 'item')} still in storage. Ask for them back.'
          : '${_plural(n, 'item')} still in storage. Deliver them back.',
    ClosureBlockerKind.openOrders =>
      forClient
          ? '${_plural(n, 'order')} still in progress.'
          : '${_plural(n, 'order')} still open. Complete or cancel them.',
    ClosureBlockerKind.unpaidInvoices =>
      forClient
          ? '${_plural(n, 'unpaid invoice')} ($zar) to settle.'
          : '${_plural(n, 'unpaid invoice')} ($zar). Mark paid or void.',
    ClosureBlockerKind.unbilledCharges =>
      forClient
          ? '$zar in once-off charges, invoiced on the 1st.'
          : '$zar in once-off charges not invoiced yet. They go on the '
                "1st's invoice.",
  };
}

/// What happens to a client's information when their account closes —
/// shown to clients before they ask, and to admins on the client page.
const closureClearedSummary =
    'Sign-in, phone number, addresses, notifications and emails.';

/// What is kept after closing, and why.
const closureKeptSummary =
    'Name, email, invoices, order history, photos and signatures. Kept '
    'for $closureRetentionYears years for tax records and claims about '
    'stored items, visible only to our admin team, then deleted.';
