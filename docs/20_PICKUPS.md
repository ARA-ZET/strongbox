# 20 — Pickups Feature Spec

## Purpose
Cover the full lifecycle of a pickup job: admin creates it, assigns a driver, driver executes it in the field (scans each unit, captures photos, collects sign-off), and the system automatically advances all unit statuses. Pickups are the entry point for items entering the StrongBox facility.

---

## Designs

| Screen | Design File |
|---|---|
| Jobs List (admin) | `admin_jobs_list` |
| Create Job Step 1 | `admin_create_new_job_step_1` |
| Create Job Step 2 | `admin_create_new_job_step_2` |
| Create Job Step 3 (schedule) | `admin_create_new_job_step_3_schedule` |
| Create Job Step 4 (confirm) | `admin_create_new_job_step_4_confirm` |
| Driver Jobs List | `driver_portal_jobs` |
| Driver Job Detail | `driver_job_detail` |
| Driver Photo Capture | `driver_photo_capture` |
| Driver Sign-Off | `driver_client_sign_off` |

---

## State Machine: Pickup Job

```
[Created]     → status: scheduled
[Assigned]    → status: assigned      (driver assigned)
[Started]     → status: inProgress    (driver taps "Start Job")
[All scanned] → all units: inTransit  (auto when last unit scanned)
[Signed off]  → status: completed     (client signature collected)
```

Storage unit status during pickup:
```
pendingPickup → inTransit → inStorage
                         ↑ (set when driver completes drop-off at facility)
```

---

## Admin: Create Pickup Job (4 Steps)

### Step 1 — Job Type & Client
- Job type selector: **Pickup** (selected) / Delivery
- Client selector (required): searchable dropdown of all clients
- Pickup address: auto-populated from client's default address; editable
- Driver notes (optional)

### Step 2 — Select Units
- Grid of client's units with status `pendingPickup`
- Multi-select with checkboxes
- At least 1 unit required
- For Closed units: shown as a card (no item drill-down)
- For Open units: expandable card showing item list (all items included automatically)
- "Add New Unit" shortcut → opens Add Unit drawer inline

### Step 3 — Schedule
- Date picker (min: today)
- Time window: Morning (8am–12pm) / Afternoon (12pm–5pm) / Evening (5pm–8pm)
- Driver selector (optional; can be assigned later)
  - Shows driver name, active shift status, today's job count
  - "Auto-assign" button (assigns driver with fewest jobs today)
- Estimated duration (calculated: 15 min × unit count + 30 min buffer)

### Step 4 — Review & Confirm
- Summary card: client, address, units, driver, date/time
- `StepIndicator` showing steps 1–4 with step 4 active
- "Create Job" amber button
- On submit → `jobRepository.create(Job {...}, actorId: uid)`
- → `AuditEvent(action: jobCreated)`
- → FCM notification to assigned driver (if assigned)
- → Email notification to client (Cloud Function trigger)

### Validation
- Must select at least 1 unit
- Cannot create pickup for unit not in `pendingPickup` status
- Cannot assign driver with no active account
- Cannot schedule in the past

---

## Admin: Edit & Manage Pickup Jobs

### From Job List (`/admin/jobs`)
- Filter by type: All / Pickup / Delivery
- Filter by status, driver, date range
- Table columns: Job ID | Client | Driver | Units | Scheduled | Status | Actions
- Row actions: View | Edit | Reassign Driver | Cancel

### From Job Detail (`/admin/jobs/:jobId`)
- All info from creation + progress
- Unit list with per-unit scan status (checkmarks appear as driver scans)
- Driver location (not implemented in v1 — placeholder)
- "Cancel Job" button → `jobRepository.cancel(jobId, reason)` → units revert to `pendingPickup`
- "Reassign Driver" → modal with driver dropdown

---

## Driver: Execute Pickup

### On Job Detail Screen
1. Driver taps "Start Job" → job status `assigned → inProgress`
2. All units transition `pendingPickup → inTransit`
3. AuditEvent per unit written in batch

### Scan Loop (per unit)
1. Driver taps "Scan Unit" → opens scanner in job context
2. Scans unit QR code → bottom sheet: unit info + "Confirm Pickup" button
3. Confirm → `jobRepository.markUnitScanned(jobId, unitId)`
4. Unit check-mark appears on job detail
5. Repeat for all units

### Photo Capture
- After all units scanned → "Add Photos" button activates
- Driver photographs all units at client's address
- Min 1 photo required
- Photos stored at `jobs/{jobId}/driver-photos/{timestamp}.jpg`

### Client Sign-Off
- After photos added → "Complete Pickup" button → `/driver/jobs/:jobId/signoff`
- Client signs on device
- Signature stored at `jobs/{jobId}/signature.png`
- `jobRepository.completeSignOff(jobId, signatureUrl)` transaction:
  - job status → `completed`
  - all units → `inStorage` (they physically go to facility)
  - AuditEvent: `jobCompleted`

---

## Providers

```dart
createJobNotifier                   → AsyncNotifier<CreateJobState>
  // CreateJobState { step, jobType, clientId, selectedUnitIds,
  //                  scheduledDate, timeWindow, driverId, notes }
adminJobsProvider                   → StreamProvider<List<Job>>
adminJobDetailProvider(jobId)       → StreamProvider<Job>
assignableDriversProvider(date)     → FutureProvider<List<AppUser>>
```

---

## Notifications Triggered

| Trigger | Recipient | Channel |
|---|---|---|
| Job created + driver assigned | Driver | Push (FCM) + in-app |
| Job starts (`inProgress`) | Client | Push + email |
| All units scanned | Admin | In-app alert |
| Job completed | Client | Push + email with summary |
| Job cancelled | Driver + Client | Push + email |

---

## Business Rules

- A job must contain at least 1 storage unit
- A job can only be started by the assigned driver
- Units cannot be added to a job after it reaches `inProgress`
- Cancelling a job when `inProgress` requires admin override + reason
- All unit status changes within a job are written in a single Firestore transaction
- Driver photos are required before sign-off can be collected
- Sign-off signature must be a drawn image (not an empty canvas)

---

## Error States

| Error | Handling |
|---|---|
| No units in `pendingPickup` for client | Step 2 shows "No units ready for pickup" + link to create unit |
| Driver has no active shift | Toast on "Start Job" tapped |
| QR scan matches unit not in this job | Show "Wrong unit — not on this job" error |
| Photo upload fails | Queue locally, retry on connectivity, show banner |
| Signature upload fails | Preserve canvas, retry button |
| Job cancel fails | Toast, job status unchanged |

---

## Acceptance Criteria

- [ ] Admin can create a pickup job in 4 steps with all required info
- [ ] Unit count and estimated duration calculate correctly
- [ ] Driver receives push notification when assigned to a pickup job
- [ ] Driver cannot start job without an active shift
- [ ] Each unit scan advances status and updates UI in real time
- [ ] Job cannot be completed until all units are scanned and photos added
- [ ] Sign-off transaction atomically completes job and sets all units to `inStorage`
- [ ] Cancelled pickup job reverts all unit statuses to `pendingPickup`
- [ ] Full audit trail for every status change from creation to completion
