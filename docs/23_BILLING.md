# 23 — Billing Feature Spec

## Purpose
Charge each client monthly for what we store, and let them see what they owe and how to pay. v1
has **no card provider**: invoices are issued by a Cloud Function, clients pay by EFT, and an admin
records the payment. The app never computes an invoice or changes an amount.

---

## Model (matches the website)

- Storage is charged **per unit per month**. Each `StorageUnit` records `priceKey` and
  `monthlyRateZar` when registered, so later price changes never re-price stored goods.
- Billable statuses: `inTransit`, `inStorage`, `pendingDelivery` (`StorageStatusX.isBillable`).
- Units with no recorded rate fall back to the current price list (`priceLists/{tenantId}`, or
  the generated defaults); units with no size are not billed and are counted as *unpriced*.
- Monthly, in advance, no contract, no minimum term, no discounts. Pickup is a once-off fee by
  vehicle (quoted on the website). There are **no subscription plans**.
- `StorageBill` (app) and `functions/src/billing.js` implement the same arithmetic.

---

## Designs

| Screen | Route | Design File |
|---|---|---|
| Client Billing | `/client/subscription` | `client_subscription_billing` |
| Admin client detail → Invoices | `/admin/clients/:clientId` | `admin_client_detail` |
| Admin Settings → EFT payment details | `/admin/settings` | — |

---

## Lifecycle

```
1st of month, 06:00 SAST   monthlyInvoices issues invoices/{clientId}_{YYYY-MM}   status: open
                           + notification invoiceReady to the client (push + email)
client pays by EFT         quoting the reference, e.g. INV-202611-AB12CD
admin                      Mark paid (optional note)  → status: paid
                           or Void (reason required)  → status: voided
onInvoiceUpdated           recomputes Client.subscriptionStatus; "payment received" to client
07:00 SAST daily           dailyBillingSweep: open + past dueAt → client pastDue
```

Nothing is issued for a tenant until **Admin → Settings → EFT payment details** is filled in —
clients need somewhere to pay. Until then the run sends admins one "invoices not issued" alert a
month. Invoice ids are deterministic, so a re-run never bills a client twice for a month. Settled
invoices are final (rules reject any further change).

---

## Firestore: `invoices/{clientId}_{YYYY-MM}`

```
tenantId, clientId
reference: String          // INV-{YYYYMM}-{first 6 of clientId}
description: String        // "Storage — November 2026"
amount: number             // Rand, VAT inclusive
currency: 'zar'
status: PaymentStatus      // open | paid | voided  (uncollectible reserved)
lines: [{ unitId, qrCodeId, label, priceKey, rateZar }]
unitCount, unpricedUnitCount
periodStart, periodEnd, dueAt (periodStart + 7 days)
paidAt?, paidBy?, paymentNote?, voidReason?
isDeleted, createdAt, updatedAt
```

Model: `Invoice` / `InvoiceLine` (`lib/core/models/invoice.dart`).

### Client billing status (`Client.subscriptionStatus`)

Written only by the functions (rule 25), never by the app:

| Status | Meaning |
|---|---|
| `incomplete` | No invoice yet (nothing stored) |
| `active` | No overdue invoices |
| `pastDue` | An open invoice is past its due date |
| `cancelled` | Set by ops; the functions leave it alone |

---

## Rules

- `invoices`: clients read their own; admins read all and may only move an **open** invoice to
  `paid` or `voided`, touching only `status, paidAt, paidBy, paymentNote, voidReason, updatedAt`.
  Nobody creates or deletes invoices from a client.
- `tenants/{tenantId}.paymentInstructions` (≤ 500 chars) is public like the rest of that doc —
  bank details only.

---

## Client Billing screen (`/client/subscription`)

- **Monthly Storage** — `StorageBill` of the client's units, one line per unit.
- **Billing card** — status chip and the **how-to-pay panel**: amount due across open invoices,
  due date, the EFT reference (copyable) and the tenant's payment instructions; "all paid up"
  when nothing is open.
- **Price List** — live prices.
- **Invoices** — `InvoiceTable`: period, reference, amount, due, status (overdue shows *Past
  Due*), and *Download PDF* (`printInvoice`, `lib/core/utils/invoice_pdf.dart`).

## Admin

- Client detail: *Billing* card shows monthly storage and the outstanding amount; the
  *Invoices* table adds *Mark paid…* and *Void…* on open invoices (`InvoiceActions`).
- Settings → Business details: *EFT payment details* (`BusinessSettings.paymentInstructions`).
- Reports: *Monthly Storage Revenue* = every billable unit at its rate.

---

## Repository & providers

```dart
abstract class SubscriptionRepository {
  Stream<List<Invoice>> watchInvoices(String tenantId, String clientId);
  Future<void> markPaid(Invoice invoice, {required String actorId, String? note});
  Future<void> voidInvoice(Invoice invoice, {required String actorId, required String reason});
}
```
Both writes run in a transaction that re-checks the invoice is still open and writes an
`AuditEvent` (`invoicePaid` / `invoiceVoided`).

```
myInvoicesProvider                 client's invoices
clientInvoicesProvider(clientId)   admin view
invoiceActionsProvider             markPaid / voidInvoice
```

---

## Adding a card provider later

Keep the `invoices` docs as the source of truth: a provider's webhook (Paystack, Stripe, …)
should set `status: paid` (+ `paidAt`, `paymentNote`) on the matching invoice, and the client
page can add a "Pay now" link per open invoice. Nothing else in the app needs to change.

---

## Acceptance Criteria

- [x] One invoice per client per month, one line per billable unit at its recorded rate
- [x] Re-running the invoice job never double-bills
- [x] Client sees amount due, due date, EFT reference and bank details
- [x] Invoice PDF downloads with lines, total and how to pay
- [x] Admin marks paid / voids; settled invoices cannot change again
- [x] Overdue invoices turn the account `pastDue`; settling returns it to `active`
- [x] Client is notified when an invoice is issued and when payment is received
