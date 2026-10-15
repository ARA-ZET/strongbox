# StrongBox Cloud Functions

Node 22, Firebase Functions v2, region `us-central1` (Firestore is in `nam5`).

| Function | Trigger | What it does |
|---|---|---|
| `onJobCreated` | `jobs/{id}` create | Unassigned job → alert to all admins; job created with a driver → that driver |
| `onJobUpdated` | `jobs/{id}` update | Driver (re)assigned → driver · started → client · completed → client + admins · cancelled → client + driver |
| `onIssueReported` | `issueReports/{id}` create | Alert to all admins |
| `onNotificationCreated` | `notifications/{id}` create | Stamps `route`; FCM push to every token on `users/{uid}.fcmTokens` (prunes dead ones); email to clients who opted in |
| `onClientCreated` | `clients/{id}` create | Welcome email (only for records with a login) |
| `onInvoiceUpdated` | `invoices/{id}` update | Recomputes the client's `subscriptionStatus`; "payment received" to the client |
| `monthlyInvoices` | 06:00 SAST on the 1st | One invoice per client: every billable unit at its recorded rate (same maths as `StorageBill`). Idempotent — id `{clientId}_{YYYY-MM}`. **Held** (admins alerted) until Settings has EFT payment details |
| `dailyBillingSweep` | 07:00 SAST daily | Open invoices past due → client `pastDue`; settled → `active` |
| `weeklyUnlinkedQrSweep` | 07:00 SAST Mondays | Alerts admins to QR labels unused for 30+ days |
| `inviteDriver` / `resendInvite` | Callable (admins only) | Creates the driver's Auth login + `users/{uid}` (role driver, `invited: true`) and emails a password-setup link, also returned for the admin to copy. Refuses emails that already have an account |

The app never sends a push or email itself: it writes a `notifications` doc (or
the functions do), and `onNotificationCreated` delivers it. Unit statuses are
settled by the app in the job transaction — the functions only notify.

## Billing model

Invoices only, no payment provider yet. Clients pay by EFT quoting the invoice
reference (`INV-202611-AB12CD`); an admin marks the invoice paid (or voids it)
on the client page. Bank details come from **Admin → Settings → EFT payment
details**. A card provider can be added later by writing the same `invoices`
docs from its webhook.

## One-time setup

1. **Blaze plan** (already on) — scheduled functions need Cloud Scheduler.
2. **Email** — install the *Trigger Email from Firestore* extension
   (`firebase/firestore-send-email`) with collection **`mail`** and your SMTP
   settings. Until then, email docs simply queue in `mail`; nothing breaks.
3. **Web push** — Firebase Console → Project settings → Cloud Messaging →
   *Web Push certificates* → generate a key pair. Save the public key as the
   GitHub **variable** `FCM_VAPID_KEY` (Settings → Secrets and variables →
   Actions → Variables). Without it the web app runs with push off.
4. **iOS push** (when shipping iOS) — upload an APNs key in the Firebase
   Console and enable *Push Notifications* + *Background Modes → Remote
   notifications* on the Runner target in Xcode.

## Develop & test

```sh
cd functions
npm install
npm test                # pure logic: billing maths, message copy, routes
npm run test:emulator   # triggers + firestore.rules on the emulators (Java 21+)
```

`npm run test:emulator` uses the `demo-strongbox` project id, so it never
touches the live project. CI runs both before deploying rules.

The default rates in `src/default-rates.g.json` are generated from
`packages/pricing/pricing.json` — run `node packages/pricing/build.mjs`.

## Deploy

Not part of CI yet — deploy from the repo root:

```sh
firebase deploy --only functions --project strongbox-app
```

The first deploy enables the Cloud Functions, Cloud Build, Artifact Registry,
Eventarc and Cloud Scheduler APIs and can take several minutes.
