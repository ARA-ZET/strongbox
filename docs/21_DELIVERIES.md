# 21 — Deliveries Feature Spec

## Purpose
Cover the full lifecycle of a delivery job: client requests it, admin schedules and assigns a driver, driver executes the delivery in the field (scans units at facility exit, drives to client address, delivers, collects sign-off). Deliveries are the exit point for items leaving the facility.

---

## Designs

| Screen | Design File |
|---|---|
| Create Delivery Request (client) | `client_request_delivery_step_1` |
| Admin Jobs List | `admin_jobs_list` |
| Create Job Steps 1–4 | `admin_create_new_job_step_1/_2/_3/_4` |
| Driver Job Detail | `driver_job_detail` |
| Driver Photo Capture | `driver_photo_capture` |
| Driver Sign-Off | `driver_client_sign_off` |

---

## State Machine: Delivery Job

```
[Requested]   → status: scheduled    (client submits request OR admin creates)
[Assigned]    → status: assigned     (driver assigned)
[Started]     → status: inProgress   (driver taps "Start Job" at facility)
[Units loaded] → all units: inTransit (scanned out of facility)
[Delivered]   → status: completed    (signature collected at client address)
```

Storage unit status during delivery:
```
inStorage → pendingDelivery → inTransit → delivered
```

> **Note:** Units stay as `inStorage` until admin schedules the delivery. Once scheduled, they move to `pendingDelivery`. When driver scans at facility exit, they move to `inTransit`. On sign-off, they become `delivered`.

---

## Client: Request Delivery (4 Steps)

See **15_CLIENT_PORTAL.md** for the full screen breakdown. Summary:

1. **Select Items**: multi-select from `inStorage` units (cannot request units already `pendingDelivery` or `inTransit`)
2. **Date & Time**: date picker + time window (morning/afternoon/evening)
3. **Confirm Address**: saved address or one-time address override
4. **Review & Submit**: creates a `Job` with `type: delivery, status: scheduled`

On submit:
- `jobRepository.create(Job{type: delivery, ...})`
- Each selected unit → `storageUnitRepository.updateStatus(unitId, pendingDelivery)`
- AuditEvent: `deliveryRequested`
- Admin receives in-app notification

---

## Admin: Schedule & Assign Delivery

### From Job List
- Delivery requests appear with status `scheduled` and no driver
- Admin clicks → Job Detail
- "Assign Driver" → driver dropdown → saves
- Optionally adjusts date/time

### Admin Creates Delivery Directly
- Same 4-step flow as pickup (see 20_PICKUPS.md) but with:
  - Step 2: select units with status `inStorage`
  - On create → units move to `pendingDelivery`

### Validation
- Cannot schedule delivery for units not in `inStorage`
- Cannot schedule delivery for client with `subscriptionStatus == cancelled`
- Cannot assign driver without an active user account

---

## Driver: Execute Delivery

### Pre-departure (at facility)
1. Driver opens job on `/driver/jobs/:jobId`
2. Taps "Start Job" → status `assigned → inProgress`
3. "Scan Units at Exit" prompt appears
4. Driver scans each unit QR as it leaves the facility
5. Each scan: unit `pendingDelivery → inTransit` + AuditEvent
6. When all units scanned → "Drive to Client" confirmed state

### At Client Address
1. "Add Photos" → driver photographs units before unloading at the door
2. "Deliver" button → unloads units, marks each as delivered
3. Tap "Collect Signature" → sign-off screen
4. Client draws signature
5. `jobRepository.completeSignOff(jobId, signatureUrl)` transaction:
   - job status → `completed`
   - all units → `delivered`
   - AuditEvent: `jobCompleted`

### Signature Collection
- Same `SignOffScreen` used for pickups
- Screen shows: "Delivered items: [list]", signature canvas, "Confirm Delivery" button
- Signature stored at `jobs/{jobId}/signature.png`

---

## Unit Status Boundary Rules

| From | To | Trigger |
|---|---|---|
| `inStorage` | `pendingDelivery` | Admin schedules delivery / client requests |
| `pendingDelivery` | `inTransit` | Driver scans unit at facility exit |
| `inTransit` | `delivered` | Job sign-off completed |
| `pendingDelivery` | `inStorage` | Job cancelled (revert) |
| `inTransit` | `inStorage` | Job cancelled mid-delivery (revert, admin action) |

---

## Admin: Cancel or Reschedule Delivery

### Cancel
- Allowed before `inProgress`
- Requires reason (text field in confirm dialog)
- `jobRepository.cancel(jobId, reason)` → units revert to `inStorage`
- AuditEvent: `jobCancelled`
- Client + driver notified

### Reschedule
- Allowed before `inProgress`
- Admin edits scheduled date/time on job detail
- `jobRepository.update(jobId, {scheduledDate, timeWindow})`
- AuditEvent: `jobUpdated`
- Driver re-notified

---

## Providers

```dart
// Admin side
adminDeliveryJobsProvider           → StreamProvider<List<Job>>
  // filtered: type == delivery
adminJobDetailProvider(jobId)       → StreamProvider<Job>

// Client side
clientDeliveryRequestNotifier       → AsyncNotifier<DeliveryRequestState>
clientPendingDeliveriesProvider     → StreamProvider<List<Job>>
  // filtered: clientId, type == delivery, status != completed|cancelled

// Driver side
driverJobDetailProvider(jobId)      → StreamProvider<Job>
```

---

## Notifications Triggered

| Trigger | Recipient | Channel |
|---|---|---|
| Client submits delivery request | Admin | In-app + email |
| Driver assigned | Driver | Push (FCM) + in-app |
| Job starts | Client | Push: "Your driver is on the way" |
| All units scanned (inTransit) | Client | Push: "Delivery en route" |
| Delivery completed | Client | Push + email with summary |
| Job cancelled | Client + Driver | Push + email |

---

## Business Rules

- Client can only request delivery for units in `inStorage` state
- Units in `pendingDelivery` cannot be requested again (already queued)
- Admin must review and schedule within SLA (admin alert after 4 hours of unscheduled request)
- Driver must scan each unit individually — bulk-mark-all is not allowed
- Signature is mandatory — cannot complete delivery without it
- If driver cannot reach client, job is put on hold (admin resolves): status → `scheduled` with note

---

## Error States

| Error | Handling |
|---|---|
| No `inStorage` units to deliver | Client: "No items are ready for delivery" |
| Unit already `pendingDelivery` | Excluded from selection, tooltip explains |
| Driver no-show / not available | Admin reassigns driver on job detail |
| Client not home at delivery | Driver adds note + issues report, admin resolves |
| Sign-off fail | Preserve signature, retry button |
| Mid-delivery cancellation | Admin-only, units revert to `inStorage` |

---

## Acceptance Criteria

- [ ] Client can request delivery for 1 or more `inStorage` units in 4 steps
- [ ] Requested units immediately move to `pendingDelivery` on submission
- [ ] Admin receives notification of new delivery request within 30 seconds
- [ ] Admin can assign driver and adjust schedule from job detail
- [ ] Driver receives push notification on assignment
- [ ] Cancellation before `inProgress` reverts all unit statuses atomically
- [ ] Driver scan at facility exit moves units to `inTransit`
- [ ] Delivery sign-off atomically marks job completed + all units delivered
- [ ] Client receives confirmation notification on delivery completion
- [ ] All status changes have corresponding AuditEvents
