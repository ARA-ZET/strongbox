# StrongBox — End-to-End Journey (as built)

The journey from first visit to delivery, step by step, for the **client**,
**admin / ops** and **driver** — and what the system does at each step.
This is the source of truth for the flow; `strongbox-journey-v5.drawio` is
the same journey as a swimlane diagram. Where an older spec doc disagrees,
this file and the code win.

v1 boundaries: invoices + EFT (no card payments or plans), push + email (no
SMS), driver check-in buttons (no GPS tracking), no phone OTP, no
pro-rating, no insurance claims. See `01_PRODUCT_VISION.md` → v2 backlog.

---

## Status model

**Job** — `type`: `pickup` · `delivery` · `supplyDrop`

```
pendingConfirmation ──confirm──▶ scheduled ──assign──▶ assigned ──start──▶ inProgress
        │                                                                     │
        └──decline──▶ cancelled ◀──cancel (client or ops, before start)───────┤
                                                                              ▼
   pickup:   inProgress ──client signs──▶ collected ──last unit received──▶ completed
   delivery / supplyDrop:   inProgress ──client signs──▶ completed
```

Check-ins on the job: `departedAt` ("on my way") and `arrivedAt` ("arrived").

**StorageUnit**

```
pendingPickup ─scan at door─▶ inTransit ─scan at facility─▶ inStorage
inStorage ─delivery requested─▶ pendingDelivery ─scan out─▶ inTransit ─signed─▶ delivered
```

Billable: `inTransit`, `inStorage`, `pendingDelivery`.

---

## Client

| # | Step | Where | What happens |
|---|---|---|---|
| 1 | Discovers StrongBox and browses prices | Website `/`, `/pricing`, `/loose-items` | Quick calculator (boxes + loose items) and full calculator (boxes, loose items, **packing & supplies**, pickup vehicle). No account needed. |
| 2 | "Book Your Pickup" | Website → app `/register?boxes=…&loose=…&vehicle=…&supplies=…&helper=…` | The quote rides along in the link. |
| 3 | Creates an account | App `/register` (or Google on `/login`) | `users` + `clients` docs created; welcome email queued. The quote is restored after sign-up. |
| 4 | Reviews / edits the quote | `/client/order` | Boxes, loose items, supplies (bubble wrap, paper, tape — once-off), packing helper (R/hour, min hours), vehicle. Running monthly + once-off totals. |
| 5 | Books the pickup | `/client/order/book` | Date (from tomorrow), time window, address, **access notes**, notes. Optional **"Deliver supplies before the pickup"** with its own date (≥ 1 day before pickup) and window — journey **Path A**; otherwise the driver brings supplies on the day — **Path B**. |
| 6 | Sees "Booking received" | Notification + `/client/orders/:jobId` (opened straight after booking) | `bookPickup` creates the pickup (+ supply drop-off for Path A) as **Awaiting confirmation**, one unit per item (`pendingPickup`, rate locked) each with its own QR code. |
| 6a | *(Optional)* Cancels the order | `/client/orders/:jobId` → **Change of plans?** → Cancel pickup | Allowed while the order is awaiting confirmation, confirmed or assigned — until the driver sets off. `cancelOrder` cancels the job (`cancelledBy: client`, optional reason) and its items; a Path A pickup's supply drop-off goes with it, but once the supplies are on their way or delivered the client contacts us instead. Client, admins and any assigned driver are notified. |
| 7 | Prints labels and packs | Order page or `/client/storage` → Print labels; dashboard **To do** shows "Get N items ready" | A4 sheet, 12 labels; each label's QR opens the item. |
| 7a | Photographs each box while packing | `/client/storage/:unitId` → "Pack & photograph this box" | While the unit is awaiting pickup: take or upload up to 8 photos (**Contents** before sealing, **Sealed box** with its label), remove their own, and note "What's inside?". Photos sit on the unit — the driver sees them on the manifest, ops on the unit, and the client in their inventory afterwards. Read-only once collected. |
| 8 | Gets "Booking confirmed" | Notification | Shows date/window — or "We couldn't confirm" with the reason if declined. |
| 9 | *(Path A)* Receives supplies | At home | Driver arrives with flat-pack boxes, supplies and label sheets; client signs for them. "Your packing supplies are here." |
| 10 | Gets "Driver on the way" | Notification | Includes the **driver's name and E-ID (`DRV-…`)**, also shown on the order (`/client/orders/:jobId`). |
| 11 | Gets "Driver has arrived" | Notification | |
| 12 | Checks the item list on the driver's device, gives name, signs | Driver's phone | Pickup becomes **Collected — in transit**. |
| 13 | Gets "Your items are in storage" | Notification | Sent when the driver has scanned every unit in at the facility. |
| 14 | Views inventory | `/client/storage`, `/client/storage/:unitId` | Photos, QR, condition, bay, monthly rate, status, activity. **Export inventory (PDF)**. |
| 15 | Requests a delivery | `/client/requests/new` | Pick in-storage units (partial retrieval is just picking a subset), date tomorrow → +30 days, window, saved or different address, instructions. `requestDelivery` checks ownership/status, moves units to `pendingDelivery`, job **Awaiting confirmation**. The client can cancel it from the order page until the driver starts loading — the units go back to **In storage**. |
| 16 | Gets "Delivery confirmed" → "On the way" (E-ID) → "Arrived" | Notifications | |
| 17 | Receives items, signs | Driver's phone | "Delivery complete — signed for by …" (also emailed). Units `delivered`. |
| 18 | Pays the monthly invoice by EFT | `/client/subscription` | Issued on the 1st: storage lines for billable units + **once-off lines** (vehicle, supplies, helper) for jobs collected/completed since the last invoice. Delivered units drop off the next invoice. |
| 19 | Books more | `/client/order` | Same flow again. |

## Admin / Ops

| # | Step | Where | What happens |
|---|---|---|---|
| 1 | Sets prices | `/admin/pricing` | Boxes, loose items, vehicles, **packing supplies**, **packing helper** (hourly + minimum). Live for the app; website within ~5 min. |
| 2 | Gets "New pickup / delivery to confirm" | Notification · Dashboard **Bookings to confirm** | One card per booking; a Path A pair shows once. Tapping the alert or a dashboard row opens that job's sheet (`/admin/jobs?job=…`). |
| 3 | Reviews and confirms — or declines | `/admin/jobs` → job sheet | Sees address, access notes, items, supplies, helper hours, once-off total, linked supply drop-off. **Confirm**: keep or change date/window, optionally assign driver + fleet vehicle (confirms the linked supply drop-off too). **Decline**: reason shown to the client; booked units are cancelled, delivery units go back to storage. Declining either half of a Path A pair declines both and releases the pickup's units. |
| 4 | Dispatches | Dashboard **Confirmed — needs a driver** → job sheet | Assign / reassign driver and vehicle (driver's name is saved on the job for the client). Confirmed jobs with no driver — supply drop-offs included — wait on the dashboard. **Cancel** (before start) releases units; cancelling a Path A pickup also cancels its supply drop-off unless that is already under way. |
| 5 | Creates ops jobs directly when needed | `/admin/jobs/new` | 4-step wizard; uses the client's saved address; access notes; already confirmed. |
| 6 | Watches progress | Job sheet | Confirmed, on the way, arrived, collected x/n, in storage x/n, handed over x/n, signed by. |
| 7 | Receives at the facility (fallback) | Dashboard **Collected — arriving** → job sheet | Tick units + bay → `inStorage`, when the driver couldn't scan them in. |
| 8 | Handles driver issues | `/admin/issues` | Open → in review → resolved (or reopen). |
| 9 | Prints/reprints labels; links blank QR batches | Job sheet · `/admin/qr` | Same code reprinted scans the same. |
| 10 | Bills | Automatic on the 1st · client page | Mark invoices paid (EFT ref) or void. Clients go `pastDue` when overdue. |

## Driver

| # | Step | Where | What happens |
|---|---|---|---|
| 1 | Gets "New … assigned" | Notification · `/driver/jobs` | Overdue (unfinished, earlier day), Today, Upcoming. |
| 2 | Opens the job | `/driver/jobs/:jobId` | Address (Open in Maps), access notes, notes, helper hours, vehicle, supplies checklist ("bring on the day" / "deliver to client"), manifest with the client's packing photos. |
| 3 | **Start** | Bottom button | Pickup / supply drop-off: "Start — I'm on my way" (`inProgress` + `departedAt` → client "on the way"). Delivery: "Start — load at facility". |
| 4 | *(Delivery)* Scan out of storage | Scanner | Each unit `pendingDelivery → inTransit`; then "Loaded — I'm on my way" (needs every unit scanned). |
| 5 | **I've arrived** | Bottom button | `arrivedAt` → client "Driver has arrived". |
| 6 | Scan each unit | Scanner (step shown on screen, keeps scanning) | Pickup: `pendingPickup → inTransit`. Delivery: handover scan. Off-manifest or wrong-status codes are refused. |
| 7 | Photos + condition | Per unit → Photo | Up to 4 photos, **Good / Damaged**, saved on the job and the unit. At least one photo before sign-off. |
| 8 | Client sign-off | `/driver/signoff/:jobId` | Client checks the item list, enters their name, signs. Pickup → `collected`; delivery → `completed`, units `delivered`; supply drop-off → `completed`. |
| 9 | *(Pickup)* **Receive at facility** | Scanner, receive step | Each scan → unit `inStorage` with optional bay/shelf; last unit completes the job. |
| 10 | Reports a problem | Job → "Report a problem with this job" | Linked to the job; includes wrong address / client unavailable. |
| 11 | Shift and E-ID | `/driver/shift` | Start/break/end shift; E-ID card with `DRV-…` for gate access and client verification. |

---

## Where it lives in code

| Concern | File |
|---|---|
| Client packing photos + notes | `app/lib/features/client/providers/client_providers.dart` (`PackingActions`), `PhotoRepository.addUnitPhoto` |
| Booking (pickup + Path A drop-off) | `functions/src/booking.js` (`bookPickup`) |
| Delivery request | `functions/src/delivery.js` (`requestDelivery`) |
| Client cancels an order | `functions/src/orders.js` (`cancelOrder`); rules shown in the app by `canCancelOrder` (`client_orders.dart`) |
| Confirm / decline / dispatch / scans / sign-off / receive | `app/lib/repositories/job_repository.dart` |
| Driver step logic | `app/lib/features/driver/providers/driver_jobs_providers.dart` (`ScanStep`, `scanStepFor`) |
| Notifications per step | `functions/src/messages.js` (`jobCreatedMessages`, `jobUpdatedMessages`) |
| Once-off charges on invoices | `functions/src/billing.js` (`onceOffCharges`) |
| Prices (incl. supplies, helper) | `packages/pricing/pricing.json` → `node packages/pricing/build.mjs` |
| End-to-end tests | `app/test/flows/critical_flows_test.dart`, `functions/test/*.test.js` |
