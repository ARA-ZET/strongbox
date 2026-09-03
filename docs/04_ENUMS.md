# 04 — Enums

All enums are defined here. Never use raw strings where an enum exists.
In Flutter, implement these as Dart `enum` types with extension methods for display labels and colours.

---

## UserRole
```dart
enum UserRole { admin, driver, client }
```
| Value | Description |
|---|---|
| admin | Operations staff with full access |
| driver | Field staff performing pickups and deliveries |
| client | Paying customer with self-service portal |

---

## StorageStatus
The lifecycle of a storage unit. Transitions must follow the allowed state machine.
```dart
enum StorageStatus {
  pendingPickup,    // Created, waiting to be collected
  inTransit,        // On a vehicle (pickup or delivery)
  inStorage,        // At the facility
  pendingDelivery,  // Scheduled for return
  delivered,        // Returned to client
  cancelled,        // Job cancelled before completion
  archived,         // Soft-deleted / no longer active
}
```
**Valid transitions:**
- `pendingPickup` → `inTransit` (driver starts pickup job)
- `inTransit` → `inStorage` (pickup job completed)
- `inStorage` → `pendingDelivery` (delivery job created)
- `pendingDelivery` → `inTransit` (driver starts delivery job)
- `inTransit` → `delivered` (delivery job completed)
- Any → `cancelled` (admin only)
- `delivered` | `cancelled` → `archived` (admin only)

---

## JobStatus
```dart
enum JobStatus {
  scheduled,    // Created, not yet assigned to driver
  assigned,     // Driver assigned, not yet started
  inProgress,   // Driver has started the job
  completed,    // All units scanned + client sign-off received
  cancelled,    // Cancelled before completion
}
```

---

## JobType
```dart
enum JobType { pickup, delivery }
```

---

## UnitType
```dart
enum UnitType { closed, open }
```
| Value | Description |
|---|---|
| closed | Sealed unit — exterior photos only, contents not catalogued |
| open | Catalogued — each item inside tracked individually with photos |

---

## SubscriptionStatus
```dart
enum SubscriptionStatus {
  active,        // Paid and current
  trialing,      // Free trial period
  pastDue,       // Payment failed, in grace period
  cancelled,     // Subscription ended
  incomplete,    // Initial payment not completed
  unpaid,        // Past grace period, access restricted
}
```

---

## SubscriptionPlan
```dart
enum SubscriptionPlan { starter, professional, enterprise }
```
| Value | Box Limit | Price |
|---|---|---|
| starter | 20 | R899/mo |
| professional | 100 | R3,499/mo |
| enterprise | unlimited | Custom |

---

## ClientType
```dart
enum ClientType { personal, business }
```

---

## TimeWindow
```dart
enum TimeWindow { morning, afternoon, evening }
```
| Value | Hours |
|---|---|
| morning | 08:00–12:00 |
| afternoon | 12:00–16:00 |
| evening | 16:00–20:00 |

---

## PhotoType
```dart
enum PhotoType {
  exterior,       // Outside of storage unit
  interior,       // Inside of open storage unit
  driverCapture,  // Taken by driver during job
  signature,      // Client sign-off signature image
}
```

---

## AuditAction
```dart
enum AuditAction {
  qrScanned,
  qrLinked,
  qrGenerated,
  unitCreated,
  unitUpdated,
  unitStatusChanged,
  unitArchived,
  photoUploaded,
  jobCreated,
  jobAssigned,
  jobStarted,
  jobCompleted,
  jobCancelled,
  clientSignOff,
  subscriptionCreated,
  subscriptionUpdated,
  subscriptionCancelled,
  adminImpersonated,
  issueReported,
  shiftStarted,
  shiftEnded,
}
```

---

## PaymentStatus
```dart
enum PaymentStatus { paid, open, void_, uncollectible }
```

---

## NotificationType
```dart
enum NotificationType {
  jobScheduled,
  jobStarted,
  jobCompleted,
  pickupConfirmed,
  deliveryCompleted,
  invoiceReady,
  storageThreshold,
  qrUnlinkedAlert,
  issueReported,
  systemAlert,
}
```

---

## IssueType
```dart
enum IssueType {
  vehicleBreakdown,
  cargoDamage,
  deliveryFailed,
  safetyConcern,
  wrongAddress,
  clientUnavailable,
  other,
}
```

---

## IssueStatus
```dart
enum IssueStatus { open, inReview, resolved }
```

---

## ShiftStatus
```dart
enum ShiftStatus { active, onBreak, ended }
```

---

## ScanType
```dart
enum ScanType {
  pickup,    // Scanned to confirm collected
  delivery,  // Scanned to confirm delivered
  audit,     // Scanned for stock check
  lookup,    // Scanned for info only
}
```

---

## TenantPlan (for the tenant/platform, not client subscription)
```dart
enum TenantPlan { starter, professional, enterprise }
```

---

## Extension Pattern (Flutter)
Every enum should have an extension for display and styling:
```dart
extension StorageStatusX on StorageStatus {
  String get label => switch (this) {
    StorageStatus.pendingPickup => 'Pending Pickup',
    StorageStatus.inTransit => 'In Transit',
    StorageStatus.inStorage => 'In Storage',
    StorageStatus.pendingDelivery => 'Pending Delivery',
    StorageStatus.delivered => 'Delivered',
    StorageStatus.cancelled => 'Cancelled',
    StorageStatus.archived => 'Archived',
  };

  Color get chipBgColour => switch (this) {
    StorageStatus.inStorage || StorageStatus.delivered => AppColors.statusSuccessBg,
    StorageStatus.inTransit || StorageStatus.pendingDelivery => AppColors.statusWarningBg,
    StorageStatus.pendingPickup => AppColors.statusPendingBg,
    StorageStatus.cancelled || StorageStatus.archived => AppColors.statusErrorBg,
  };

  Color get chipTextColour => switch (this) {
    StorageStatus.inStorage || StorageStatus.delivered => AppColors.statusSuccess,
    StorageStatus.inTransit || StorageStatus.pendingDelivery => AppColors.statusWarning,
    StorageStatus.pendingPickup => AppColors.statusPending,
    StorageStatus.cancelled || StorageStatus.archived => AppColors.statusError,
  };
}
```
Apply this same pattern to all enums that appear in UI chips or labels.
