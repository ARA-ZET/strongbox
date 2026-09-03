# 16 — Driver Portal Feature Spec

## Purpose
Give drivers a mobile-first interface to manage their shift, view and execute daily jobs (pickups + deliveries), scan QR codes on storage units, capture photos at collection/drop-off, and collect client sign-off. Everything is optimised for one-handed use on a phone while in the field.

---

## Screens & Designs

| Screen | Route | Design File |
|---|---|---|
| Jobs List | `/driver/jobs` | `driver_portal_jobs` |
| Job Detail | `/driver/jobs/:jobId` | `driver_job_detail` |
| QR Scanner | `/driver/scan` | `driver_qr_scanner` |
| Photo Capture | `/driver/jobs/:jobId/capture` | `driver_photo_capture` |
| Client Sign-Off | `/driver/jobs/:jobId/signoff` | `driver_client_sign_off` |
| Shift Management | `/driver/shift` | `driver_shift_management_id` |
| Profile & Stats | `/driver/account` | `driver_profile_stats` |
| Report Issue | `/driver/report-issue` | `driver_report_issue_maintenance` |

---

## Shell Layout

- **Mobile-first** — all driver screens are designed for 390px–430px phones
- **Bottom NavigationBar**: Jobs | Scan | Shift | Account
- **Shift badge**: When shift is active, a green dot pulses on the "Shift" tab
- Report Issue accessible via account screen or overflow menu on job detail
- Photo capture and sign-off are **full-screen** (no bottom nav) — use `context.push()` not `context.go()`

---

## Screen: Jobs List

### Reads
- `driverJobsProvider` → `StreamProvider<List<Job>>`
  - filtered by `driverId == currentUser.uid`, `isDeleted == false`
  - ordered by `scheduledDate` ascending
  - only today's jobs by default; toggle for future

### UI
- **Shift status banner at top**: "Shift Active — 4h 12m" (green) or "No active shift" (grey) with start button
- **Date tabs**: Today | Tomorrow | This Week
- Job cards (full-width):
  - Pickup/Delivery chip (navy/amber pill)
  - Client name + address truncated
  - Scheduled time window
  - Status chip
  - Box count badge (e.g. "3 units")
- Tap card → `/driver/jobs/:jobId`
- Empty state: "No jobs scheduled for today"
- **Cannot accept or start jobs without an active shift** — blocked with toast if attempted

---

## Screen: Job Detail

### Reads
- `driverJobDetailProvider(jobId)` → `StreamProvider<Job>`
- `jobUnitsProvider(jobId)` → `StreamProvider<List<StorageUnit>>` (units in this job)
- `clientSummaryProvider(clientId)` → `FutureProvider<Client>` (name, address, phone)

### UI
- Header: job type badge, client name, address with map link
- Scheduled date/time + estimated duration
- **Unit list**: each unit shows photo thumbnail, label, QR code, status chip + scan checkmark
- "Start Job" button (enabled only when shift is active, job is `assigned`)
- **Scan progress bar**: "2 of 3 units scanned"
- "Scan Unit" shortcut button (opens scanner filtered to this job)
- "Add Photos" → `/driver/jobs/:jobId/capture`
- "Complete Job" → `/driver/jobs/:jobId/signoff` (enabled when all units scanned)
- "Report Issue" link at bottom

### State Machine
- Tap "Start Job" → job status `assigned → inProgress`, all units `→ inTransit` (for pickup) or `→ inTransit` (for delivery)
- Each unit scan → `markUnitScanned(jobId, unitId)` → unit status advances
- All units scanned → "Complete Job" button activates
- "Complete Job" → navigate to sign-off screen

---

## Screen: QR Scanner

### Reads / Writes
- `scannerNotifier` → `AsyncNotifier<ScannerState>`
- On scan → `qrRepository.resolveCode(value)` → get unit info
- On confirm → `jobRepository.markUnitScanned(jobId, unitId)` + `storageUnitRepository.updateStatus(unitId, newStatus)`

### UI
- Full camera viewfinder with amber corner-bracket animating pulse
- "SCANNING…" amber label with dots
- Current job context shown at top: "Scanning for: Job #JB-1042"
- **On successful scan**: haptic + slide-up bottom sheet:
  - Unit photo + label + client name
  - Status chip before → after arrow (e.g. `pendingPickup → inTransit`)
  - "Confirm Scan" amber button | "Wrong Unit?" cancel
- **Manual entry**: "Type code manually" link → text field with `SBX-` prefix
- **Already scanned**: if unit already marked, show "Already scanned ✓" state

---

## Screen: Photo Capture

### Full-screen, no nav chrome

### Reads / Writes
- `photoCaptureNotifier(jobId)` → `AsyncNotifier<PhotoCaptureState>`
- Upload: `photoRepository.uploadPhoto(...)` → writes to Storage + Firestore

### UI
- Large camera preview at top (60% screen height)
- "Take Photo" amber FAB (camera shutter icon)
- Thumbnail strip below: captured photos slide in from right
- Photo count: "3 photos captured"
- Each thumbnail: tap → full-screen preview; long-press → delete option
- "Done" button → pops back to job detail
- Min 1 photo required before "Done" is enabled
- Compress to 1280px before upload (`image` package)

### Photo Types by Job Type
- **Pickup:** exterior photos of units at client's address (before loading)
- **Delivery:** photos of units at delivery address (after unloading)

---

## Screen: Client Sign-Off

### Full-screen, no nav chrome

### Reads / Writes
- `signOffNotifier(jobId)` → `AsyncNotifier<SignOffState>`
- On confirm → `jobRepository.completeSignOff(jobId, signatureUrl)` (transaction)

### UI
- Job summary at top: client name, units count, timestamp
- "Please sign below to confirm receipt" label
- **Signature canvas**: white area with "Sign here" placeholder using `signature` package
- "Clear" ghost button, "Confirm & Complete" amber button
- Signature is uploaded to Storage at `jobs/{jobId}/signature.png`
- On success → `context.go('/driver/jobs')` + success toast

### Transaction (completeSignOff)
```
Firestore.runTransaction((tx) {
  tx.update(jobs/{jobId}, { 
    status: completed, 
    clientSignatureUrl: signatureUrl, 
    completedAt: now 
  })
  // Update each unit status to delivered (for delivery jobs)
  for unit in job.unitIds:
    tx.update(storageUnits/{unitId}, { status: delivered })
  // Write audit event
  tx.set(auditEvents/{newId}, AuditEvent(action: jobCompleted, ...))
})
```

---

## Screen: Shift Management

### Reads / Writes
- `activeShiftProvider` → `StreamProvider<DriverShift?>`
- `shiftRepository.startShift(driverId, tenantId)`
- `shiftRepository.endShift(shiftId)`
- `shiftRepository.startBreak(shiftId)` / `endBreak(shiftId)`

### UI
- **No active shift**: large "Start Shift" amber button, last shift summary card
- **Active shift**:
  - Elapsed time ticker (hh:mm:ss, updates every second)
  - "On Break" / "Start Break" toggle
  - Today's job progress: "2 of 4 jobs completed"
  - Mileage entry field (optional, manual)
  - "End Shift" red button (requires confirm dialog)
- **Shift history**: list of past shifts with date, duration, jobs completed

---

## Screen: Profile & Stats

### Reads
- `driverProfileProvider` → `FutureProvider<AppUser>`
- `driverStatsProvider` → `FutureProvider<DriverStats>`
  - jobsThisMonth, avgJobTime, onTimeRate, totalMileage

### UI
- Avatar (tappable → upload new photo)
- Name, email, phone (tap to edit)
- **Stats cards**: Jobs This Month | On-Time Rate | Avg Duration
- **Recent jobs list**: last 10 completed jobs with date + client
- "Change Password" link
- "Sign Out" button

---

## Screen: Report Issue

### Writes
- `issueReportNotifier` → `AsyncNotifier`
- `issueRepository.create(IssueReport)`

### UI
- Issue type picker: Damaged item / Vehicle problem / Client not available / Wrong unit / Other
- Description text area (required)
- Photo attachment (optional, uses `PhotoUploadZone`)
- Job selector (pre-filled if navigated from job detail)
- "Submit Report" amber button
- On submit → write `IssueReport` to Firestore, write AuditEvent, show success

---

## Providers Summary

```dart
driverJobsProvider                  → StreamProvider<List<Job>>
driverJobDetailProvider(jobId)      → StreamProvider<Job>
jobUnitsProvider(jobId)             → StreamProvider<List<StorageUnit>>
clientSummaryProvider(clientId)     → FutureProvider<Client>
scannerNotifier                     → AsyncNotifier<ScannerState>
photoCaptureNotifier(jobId)         → AsyncNotifier<PhotoCaptureState>
signOffNotifier(jobId)              → AsyncNotifier<SignOffState>
activeShiftProvider                 → StreamProvider<DriverShift?>
driverProfileProvider               → FutureProvider<AppUser>
driverStatsProvider                 → FutureProvider<DriverStats>
issueReportNotifier                 → AsyncNotifier<IssueReportState>
```

---

## Business Rules

- Driver cannot start a job without an active shift
- Driver cannot complete a job until all units in the job have been scanned
- Photo capture is required before the "Complete Job" button activates
- Sign-off must include a drawn signature (not just a button tap)
- Driver can only see jobs assigned to them (Firestore query filters by `driverId`)
- Unit status can only advance — driver cannot reverse a status

---

## Permissions

| Action | Driver | Admin |
|---|---|---|
| View own jobs | ✓ | ✓ |
| View other drivers' jobs | ✗ | ✓ |
| Start/end shift | ✓ (own) | ✓ |
| Scan and update unit status | ✓ | ✓ |
| Collect client signature | ✓ | ✗ |
| Report issue | ✓ | ✓ |

---

## Error States

| Error | Handling |
|---|---|
| Start job without shift | Toast: "Start your shift first" |
| Complete job with unscanned units | "Scan button" highlighted, count shown |
| Complete job without photos | Toast: "Add at least 1 photo" |
| Camera permission denied | Permission dialog with settings link |
| Photo upload fails | Queue for retry, show offline banner |
| Sign-off submission fails | Preserve signature, retry button |

---

## Acceptance Criteria

- [ ] Driver cannot start a job without an active shift
- [ ] Job detail shows real-time scan progress for all units
- [ ] Each unit scan updates Firestore atomically with status + audit event
- [ ] Photo capture compresses images and uploads to correct Storage path
- [ ] Sign-off canvas collects a valid drawn signature before allowing submit
- [ ] Job completion is a Firestore transaction (job + all units + audit in one)
- [ ] Driver can report an issue from any job at any time
- [ ] Shift timer updates live while shift is active
- [ ] All driver screens work at 390px width (mobile-first)
