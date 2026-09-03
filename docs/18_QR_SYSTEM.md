# 18 — QR System Feature Spec

## Purpose
Generate, print, link, and scan QR codes that uniquely identify every storage unit and individual item. QR codes are the backbone of the entire tracking system — every physical object in the facility has one, and every scan creates an immutable audit trail.

---

## Screens & Designs

| Screen | Route | Design File |
|---|---|---|
| QR Management | `/admin/qr` | `admin_qr_management` |
| Scanner (driver) | `/driver/scan` | `driver_qr_scanner` |
| Scanner (admin) | Sidebar Quick Scan button | `driver_qr_scanner` (same widget) |

---

## QR Code Formats

- **Storage unit:** `SBX-{4 random digits}-{uppercase letter}{digit}` → e.g. `SBX-9942-A1`
- **Item (open unit):** `ITM-{4 random digits}-{letter}{digit}` → e.g. `ITM-1234-B2`
- **Driver E-ID:** `DRV-{first 8 chars of uid}` → e.g. `DRV-A1B2C3`

All formats are validated on both generation and scan with regex before writing to Firestore.

---

## Firestore Documents

### QRCode
```
qrCodes/{codeId}
  tenantId: String
  code: String            // e.g. 'SBX-9942-A1'
  codeType: 'unit' | 'item' | 'driver'
  isLinked: Boolean
  linkedEntityId: String? // storageUnit or item ID once linked
  batchId: String?        // QRBatch that generated this code
  createdAt: Timestamp
  linkedAt: Timestamp?
  isDeleted: Boolean
```

### QRBatch
```
qrBatches/{batchId}
  tenantId: String
  count: int
  linkedCount: int        // incremented on each link
  codes: List<String>     // the code values (e.g. ['SBX-9942-A1', ...])
  createdAt: Timestamp
  createdBy: String       // uid of admin who generated
  isDeleted: Boolean
```

---

## Providers

```dart
// watches all batches for this tenant
qrBatchesProvider → StreamProvider<List<QRBatch>>

// manages the generate-batch form state
qrGenerateNotifier → AsyncNotifier (count, resolution, isLoading)

// active scan session
scannerNotifier → AsyncNotifier (lastScanResult, isScanning, manualEntry)

// unlinked codes
unlinkedCodesProvider → StreamProvider<List<QRCode>>
```

---

## Feature: Generate Batch (Admin)

### Flow
1. Admin opens `/admin/qr`
2. Enters count (1–100 per batch) and label resolution (`72dpi` print / `150dpi` high-quality)
3. Clicks "Generate" → `qrGenerateNotifier.generate(count, resolution)`
4. Repository generates N unique codes, verifies none exist in Firestore, writes `QRBatch` + all `QRCode` docs in a single `WriteBatch`
5. Preview grid of generated codes rendered with `qr_flutter`
6. "Print PDF" → `QRLabelPdfBuilder.build(codes)` → `Printing.layoutPdf()`

### PDF Label Specs
- A4 portrait, 4 columns × 3 rows = 12 labels per page (auto-paginate)
- Each label 52mm × 35mm:
  - "StrongBox" wordmark top-left (8px Inter Bold)
  - QR code image centred (20mm square)
  - Code ID text centred below (7px Inter Bold)
  - Label text below code (italic, grey, 6px) — only if linked
- Uses `pdf` package + `qr_flutter` rendered to PNG bytes via `QrPainter`

### Batch List UI (QR Management Screen)
- Summary cards: Total Generated / Linked / Unlinked
- Table: Batch ID | Created | Count | Linked | Unlinked | Actions
- Row actions: View codes, Print unlinked, Archive batch
- Filter: All / Unlinked / Fully Linked
- Click row → expand inline to show all codes in that batch with link status

---

## Feature: Link QR to Unit

### Flow
1. Admin scans or types a QR code ID
2. `qrRepository.resolveCode(scannedValue)` → returns `QRCode` doc
3. If already linked → error: "SBX-9942-A1 is already assigned to [unit label]. Unlink from that unit first."
4. If unlinked → show bottom sheet:
   - Client selector dropdown
   - Unit type picker (Closed / Open)
   - Label text field
   - Optional notes
5. Confirm → `qrRepository.linkToUnit(codeId, unitId, actorId: uid)` (transaction)
6. `AuditEvent` written: `action: qrLinked`, `entityId: unitId`

### Transaction (linkToUnit)
```
Firestore.runTransaction((tx) {
  tx.update(qrCodes/{codeId}, { isLinked: true, linkedEntityId: unitId, linkedAt: now })
  tx.update(storageUnits/{unitId}, { qrCodeId: codeId })
  tx.update(qrBatches/{batchId}, { linkedCount: FieldValue.increment(1) })
  tx.set(auditEvents/{newId}, AuditEvent(action: qrLinked, ...))
})
```

---

## Feature: QR Scanner (Shared Widget)

Used at `/driver/scan` and via sidebar Quick Scan button on admin desktop.

### Scanner Component
- Package: `mobile_scanner` with `MobileScannerController`
- Viewfinder: amber corner-bracket borders (animated pulse 1.5s)
- "SCANNING…" amber label with animated dots
- On successful scan:
  - Haptic feedback (`HapticFeedback.mediumImpact()`)
  - Camera pauses
  - Bottom sheet slides up with unit info (label, client, status, photos)
  - Action buttons contextual to role (driver: confirm scan for job; admin: link/view)
- Manual entry fallback: "Enter code manually" tappable text → inline text field with SBX-/ITM- prefix

### Web Fallback (Admin Desktop)
- Upload image of QR code
- Decoded client-side using `qr_flutter`'s reader or `zxing` WASM

### Driver Scan Context
- When driver has an active job, scan is linked to that job
- After confirming scan → `jobRepository.markUnitScanned(jobId, unitId)` + `storageUnitRepository.updateStatus(unitId, newStatus)`
- Unit status advances per state machine (pickup: `pendingPickup → inTransit`, delivery: `pendingDelivery → inTransit`)

---

## Business Rules

- QR codes never change once linked — `qrRepository` has no `relink` or `unlink` method in v1
- Every scan creates an `AuditEvent` regardless of outcome
- Unlinked codes older than 30 days trigger a warning badge on the QR Management screen
- QR codes are tenant-scoped — `resolveCode` always filters by `tenantId`
- Generating a batch of 100 codes must complete in a single Firebase `WriteBatch` (max 500 ops)
- Duplicate code values are prevented by Firestore security rules + existence check before write

---

## Permissions

| Action | Admin | Driver | Client |
|---|---|---|---|
| Generate batch | ✓ | ✗ | ✗ |
| Print PDF | ✓ | ✗ | ✗ |
| Scan (any context) | ✓ | ✓ | ✗ |
| Link code to unit | ✓ | ✗ | ✗ |
| View batch list | ✓ | ✗ | ✗ |

---

## Error States

| Error | Handling |
|---|---|
| Code already linked | Show red toast with linked unit name |
| Code not found | Show "Unknown QR code — not in this system" |
| Camera permission denied | Show permission request dialog with settings link |
| Batch write fails | Rollback, show retry toast |
| Invalid code format | Reject input, show format hint |

---

## Acceptance Criteria

- [ ] Admin can generate a batch of 1–100 codes with one action
- [ ] Generated codes are globally unique (verified against Firestore)
- [ ] PDF print output renders all codes legibly at both 72dpi and 150dpi
- [ ] Scanning a linked code shows correct unit info within 1 second
- [ ] Linking a code updates all 4 related Firestore documents atomically
- [ ] Every scan (success or failure) appears in the audit log
- [ ] Scanner works on mobile camera and falls back to manual entry on desktop
- [ ] Driver scanner correctly marks units as scanned within the active job context
