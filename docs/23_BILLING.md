# 23 — Billing Feature Spec

## Purpose
Manage client subscriptions and payments via Stripe (through the Firebase Stripe Extension). Billing is Stripe-owned — the app never stores card data, calculates prices, or manually writes subscription state. All subscription data flows in via Stripe webhooks and is read from Firestore subcollections managed by the extension.

---

## Designs

| Screen | Route | Design File |
|---|---|---|
| Client Subscription & Billing | `/client/subscription` | `client_subscription_billing` |
| Admin Settings (billing config) | `/admin/settings` | — |

---

## Tech: Firebase Stripe Extension

The Firebase "Run Payments with Stripe" extension manages:
- `customers/{uid}` — Stripe customer record
- `customers/{uid}/subscriptions/{subId}` — active subscription
- `customers/{uid}/payments/{paymentId}` — payment records
- `customers/{uid}/checkout_sessions/{sessionId}` — checkout flow

The Flutter app **reads** these collections. It **never writes** to them directly.

---

## Subscription Plans

| Plan | Price | Unit Limit | Drivers |
|---|---|---|---|
| Starter | R899/mo | 20 units | 1 |
| Professional | R3,499/mo | 100 units | 5 |
| Enterprise | Custom | Unlimited | Unlimited |

Stripe Price IDs are stored in `lib/core/constants/stripe_constants.dart`:
```dart
class StripeConstants {
  static const starterMonthlyPriceId      = 'price_xxx';
  static const professionalMonthlyPriceId = 'price_yyy';
}
```

---

## Subscription States (SubscriptionStatus enum)

| Status | Meaning |
|---|---|
| `trialing` | 14-day free trial, no payment collected |
| `active` | Paid and current |
| `pastDue` | Payment failed, grace period (3 days) |
| `cancelled` | Subscription ended |
| `incomplete` | Checkout started but not completed |
| `paused` | Admin manually paused (Enterprise only) |

---

## Firestore Data (managed by Stripe Extension)

```
customers/{uid}
  stripeId: String          // Stripe customer ID
  email: String

customers/{uid}/subscriptions/{subId}
  status: SubscriptionStatus
  priceId: String           // Stripe price ID
  planName: String          // 'starter' | 'professional' | 'enterprise'
  currentPeriodStart: Timestamp
  currentPeriodEnd: Timestamp
  cancelAtPeriodEnd: Boolean
  unitLimit: int
  driverLimit: int
  trialEnd: Timestamp?

customers/{uid}/payments/{paymentId}
  amount: int               // in cents
  currency: String
  status: 'succeeded' | 'failed' | 'pending'
  created: Timestamp
  invoiceUrl: String?       // Stripe-hosted invoice PDF
```

---

## Client Portal: Subscription Screen

### Reads
- `clientSubscriptionProvider(uid)` → `StreamProvider<Subscription?>`
  - reads `customers/{uid}/subscriptions` ordered by `created` desc, limit 1
- `clientPaymentsProvider(uid)` → `StreamProvider<List<Payment>>`
  - reads `customers/{uid}/payments` ordered by `created` desc, limit 12

### UI

**Current Plan Card**
- Plan name (e.g. "Professional")
- Price per month
- Renewal date (formatted `currentPeriodEnd`)
- StatusChip: active / trialing / pastDue / cancelled
- Units used vs limit: progress bar (`currentUnitCount / unitLimit`)
- Drivers: `X of Y`

**Warnings**
- `pastDue` → amber banner: "Payment failed. Update your payment method to avoid losing access."
- `trialing` → navy banner: "Trial ends [date]. Add a payment method to continue."
- `cancelAtPeriodEnd == true` → grey banner: "Your subscription ends [date]."

**Action Buttons**
- "Upgrade Plan" → `subscriptionRepository.createCheckoutSession(uid, newPriceId)` → redirect to Stripe Checkout
- "Manage Billing" → `subscriptionRepository.createPortalLink(uid)` → redirect to Stripe Customer Portal
  - Customer Portal handles: update card, cancel, view invoices
- "Reactivate" (if cancelled) → same as Upgrade

**Payment History Table**
- Columns: Date | Description | Amount | Status | Invoice
- Status chip: succeeded (green) / failed (red) / pending (amber)
- Invoice column: "Download" link → opens `invoiceUrl` in new tab

---

## Checkout Flow

```
1. User clicks "Upgrade Plan"
2. App calls: subscriptionRepository.createCheckoutSession(uid, priceId)
3. Cloud Function creates Stripe Checkout Session, writes to:
   customers/{uid}/checkout_sessions/{sessionId}
4. App reads sessionId and opens Stripe Checkout URL
5. User completes payment on Stripe's hosted page
6. Stripe webhook → Cloud Function → updates:
   customers/{uid}/subscriptions/{subId} { status: active, priceId: newPriceId }
7. App StreamProvider detects change → UI updates automatically
```

---

## Stripe Customer Portal Flow

```
1. User clicks "Manage Billing"
2. subscriptionRepository.createPortalLink(uid) → Cloud Function
3. Cloud Function creates Stripe Billing Portal session
4. Returns URL → app opens in browser (or WebView)
5. User manages card/cancellation on Stripe's portal
6. Changes flow back via webhook → Firestore updates automatically
```

---

## Access Gates (Business Rules)

The app reads `subscriptionStatus` before allowing certain actions:

| Action | trialing | active | pastDue | cancelled |
|---|---|---|---|---|
| Request delivery | ✓ | ✓ | ✓ (grace 3 days) | ✗ |
| Add storage units | ✓ | ✓ | ✓ (grace 3 days) | ✗ |
| View storage | ✓ | ✓ | ✓ | ✓ (read-only) |
| Download invoices | ✓ | ✓ | ✓ | ✓ |

Gate implementation: `subscriptionGateProvider` → wraps feature providers and returns `AppException.subscriptionRequired` when blocked.

---

## Admin View

- Admin can see subscription status per client on `/admin/clients/:clientId`
- No ability to edit Stripe subscriptions — must use Stripe Dashboard directly
- Admin receives notification when any client has `paymentFailed` event

---

## Cloud Functions

```javascript
// functions/index.js

// Create Checkout Session
exports.createCheckoutSession = functions.https.onCall(async (data, context) => {
  const { priceId } = data;
  const uid = context.auth.uid;
  // Creates Stripe Checkout Session and writes to customers/{uid}/checkout_sessions
  // Handled by Firebase Stripe Extension — use extension's callable function
});

// Create Portal Link
exports.createPortalLink = functions.https.onCall(async (data, context) => {
  const uid = context.auth.uid;
  // Returns Stripe Billing Portal URL
  // Handled by Firebase Stripe Extension
});

// Webhook: handle Stripe events
exports.handleStripeWebhook = functions.https.onRequest(async (req, res) => {
  // Handled by Firebase Stripe Extension
  // Updates customers/{uid}/subscriptions on invoice.paid, payment_failed, etc.
});
```

---

## Repositories

```dart
abstract class SubscriptionRepository {
  /// Watch the active subscription for a user
  Stream<Subscription?> watchSubscription(String uid);

  /// Watch payment history
  Stream<List<Payment>> watchPayments(String uid);

  /// Creates a Stripe Checkout session; returns the URL to open
  Future<String> createCheckoutSession(String uid, String priceId);

  /// Creates a Stripe Customer Portal link; returns the URL to open
  Future<String> createPortalLink(String uid);
}
```

---

## Providers

```dart
clientSubscriptionProvider(uid)     → StreamProvider<Subscription?>
clientPaymentsProvider(uid)         → StreamProvider<List<Payment>>
subscriptionGateProvider            → Provider<SubscriptionGate>
  // SubscriptionGate { canRequestDelivery, canAddUnits, isReadOnly }
upgradeCheckoutNotifier             → AsyncNotifier<String?> // returns URL
```

---

## Error States

| Error | Handling |
|---|---|
| Checkout session creation fails | Toast: "Could not start checkout. Try again." |
| Portal link fails | Toast: "Could not open billing portal. Contact support." |
| Subscription not found | Empty state: "No subscription found — contact support" |
| `pastDue` + delivery requested | Gate blocks; amber banner with "Update Payment" CTA |
| `cancelled` + delivery attempted | Blocked with upgrade prompt modal |

---

## Acceptance Criteria

- [ ] Subscription screen shows correct plan name, price, and renewal date from Stripe
- [ ] Usage bar accurately reflects current unit count vs plan limit
- [ ] `pastDue` and trial-ending banners appear with correct messaging
- [ ] "Upgrade" opens Stripe Checkout; after payment, UI updates automatically without refresh
- [ ] "Manage Billing" opens Stripe Customer Portal with valid session
- [ ] Payment history table shows last 12 payments with correct status chips
- [ ] Invoice download links open Stripe-hosted PDF in new tab
- [ ] Cancelled clients see read-only storage but cannot request new deliveries
- [ ] Admin sees subscription status on client detail screen
