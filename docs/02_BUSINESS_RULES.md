# 02 — Business Rules

> **As built (journey v5)** — the end-to-end flow is [`docs/journey/JOURNEY.md`](journey/JOURNEY.md). Rules it settles:
> client bookings and delivery requests need an admin's confirmation; units become `inStorage`
> only when scanned in at the facility, never at the client's door; a pickup's once-off charges
> are billed on the next invoice after collection. v1 has no plans, Stripe or OTP — see
> `23_BILLING.md`.

These are the non-negotiable rules that govern how StrongBox works. Every developer and AI agent must read and follow these before writing any code.

---

## QR Codes
- QR codes are **permanent and immutable** — once generated and linked to a storage unit, they never change.
- A QR code belongs to exactly one storage unit. It cannot be transferred or reused.
- A QR code may be in one of two states: **unlinked** (generated but not yet assigned) or **linked** (assigned to a storage unit).
- Every QR scan creates an **Audit Event** — scans are never silent.
- QR codes follow the format: `SBX-{4digits}-{letter}{digit}` for storage units, `ITM-{4digits}-{letter}{digit}` for individual items, `DRV-{8chars}` for driver ID cards.

## Storage Units
- A storage unit is either **Closed** (sealed, photographed outside only) or **Open** (catalogued, items inside individually tracked).
- A storage unit type cannot be changed after it has had items catalogued inside it.
- Storage units support **soft delete only** — they are never permanently removed from Firestore. Deleted units get `status: 'archived'`.
- An Open storage unit **may contain child storage units** (e.g. a box inside a crate).
- Every storage unit must have at least **one exterior photo** before it can be marked `in_storage`.
- Storage units belong to exactly one **client** and one **tenant**.

## Jobs
- A job is either a **Pickup** (client → facility) or a **Delivery** (facility → client).
- A job must have at least one storage unit assigned before it can be submitted.
- A job cannot be started by a driver unless its status is `assigned`.
- A driver can only start a job assigned to them — not another driver's job.
- A job is only `completed` when: all storage units are scanned, at least one photo per unit is captured, and the client sign-off is received (signature or OTP).
- Completed jobs cannot be edited — only annotated.
- Jobs support **cancellation** up until status `in_progress`. After that, an admin must archive the job with a reason.
- Every job status change is logged in the **Audit Trail**.

## Clients
- A client account belongs to exactly one **tenant** (storage business).
- A client must have an active subscription to request new pickups.
- A client with a `past_due` subscription can still view their items but cannot request new pickups or deliveries.
- A client with a `cancelled` subscription can only view their items for 30 days before the account is frozen.
- A client may add **team members** (sub-accounts) who share visibility of their storage units (Professional and Enterprise plans only).
- Team members cannot manage billing — only the primary account holder can.
- Clients cannot see other clients' data under any circumstances.

## Account Closure (POPIA deletion requests)
Implemented in `functions/src/closure.js`; the patch functions there list every field touched.
- A client asks in **Account settings → Close my account**, or an admin starts it on the client page
  (**⋮ → Close account…**) when they asked by email or phone. Either way it closes **30 days** later;
  the client is notified and emailed, can still sign in, and can cancel until then.
- An account only closes when nothing blocks it: **no items in storage** (`inTransit` / `inStorage` /
  `pendingDelivery`), **no open orders**, **no unpaid invoices**, and **no once-off charges waiting for
  the 1st's invoice**. `dailyClosureSweep` (07:30 SAST) closes it on the first day after its date that
  all four are clear, and alerts admins once if they aren't. An admin can **Close now** once all four
  are clear.
- **Cleared at closing:** the Auth login (and push tokens), phone, addresses (on the client and on every
  order: street, access notes, notes; the suburb stays), admin notes about the client, their
  notification inbox, admin alerts naming them, and copies of emails sent to them.
- **Kept, admin-only, for 5 years** (tax records and claims, as the website's privacy policy says):
  name, email, invoices, order history, unit records, photos and signatures. The client record is
  archived (`isDeleted: true`, `closure.status: closed`) and listed under **Clients → Closed accounts**.
- **Purged after 5 years:** name, email, photos and signatures (Storage files too), unit and item
  descriptions, who signed. What remains is the account number on invoices. Audit events are never
  edited and hold ids only.
- Only the closure functions write `clients.closure`; firestore.rules stop clients writing it, and a
  closed login reads nothing even before its last token expires.

## Drivers
- Drivers cannot modify client subscriptions or billing.
- Drivers cannot create or delete storage units — only scan, photograph, and update status.
- Drivers can only see jobs assigned to them.
- A driver must have an active shift to complete a job.
- Driver shifts are tracked with start time, end time, and break periods.
- A driver's E-ID QR code is unique to their user account and regenerated on each shift.

## Admins
- Admins can view, create, edit, and archive all data within their tenant.
- Admins can impersonate a client account for support purposes — this action is logged in the audit trail.
- Admins cannot delete audit events.
- Admins can create driver accounts but cannot set driver passwords — drivers receive an email invite.

## Photos
- Photos are stored in Firebase Storage — URLs are stored in Firestore, not binary data.
- Every photo is associated with a storage unit, job, or user.
- Photos are soft-deleted only — the Storage file is retained for 90 days after deletion.
- A minimum of 1 photo is required at pickup and 1 at delivery for each storage unit.
- Driver capture photos are watermarked with timestamp and job ID (via Cloud Function).

## Subscriptions & Billing
- Subscriptions are managed entirely by Stripe — Firestore reflects Stripe state via webhook, never the reverse.
- The source of truth for subscription status is always Stripe.
- Overage above plan box limit triggers an automatic upgrade suggestion but does not block existing items.
- Invoices are generated by Stripe — StrongBox stores only the reference ID and status.

## Audit Trail
- Every significant action creates an **AuditEvent** document in Firestore — this includes: QR scans, photo uploads, job status changes, subscription changes, admin impersonation, storage unit status changes.
- Audit events are **append-only** — they are never updated or deleted.
- Audit events include: `actorId`, `actorRole`, `action`, `entityType`, `entityId`, `metadata`, `timestamp`.

## Multi-Tenancy (v1 preparation)
- Every Firestore document includes a `tenantId` field from day one, even in single-tenant v1.
- No data query is ever made without a `tenantId` filter (enforced in repositories).
- Tenant isolation is enforced at the Firestore Security Rules level.
- In v1, all users share `tenantId: 'strongbox-default'`.

## Soft Delete
- No Firestore document is ever permanently deleted in production.
- All entities have an `isDeleted: bool` field and a `deletedAt: Timestamp?` field.
- Queries always filter `where('isDeleted', isEqualTo: false)` unless explicitly fetching deleted records.

## Data Integrity
- All Firestore writes that affect multiple documents use **transactions** or **batch writes**.
- Storage unit status transitions must follow the allowed state machine — no skipping states.
- Storage unit status machine:
  ```
  pending_pickup → in_transit → in_storage → pending_delivery → in_transit → delivered
  ```
  Cancelled: any state → cancelled (admin only)
  Archived: delivered or cancelled → archived (admin only)
