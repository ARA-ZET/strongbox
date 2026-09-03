# 08 — State Management

All state is managed via Riverpod. No `setState`, no `InheritedWidget`, no `BuildContext.read` in business logic.

---

## Provider Hierarchy

```
FirebaseAuth → authStateProvider
                    ↓
              currentUserProvider (AppUser from Firestore)
                    ↓
         currentTenantIdProvider (derived)
                    ↓
         All feature providers (read tenantId from above)
```

---

## Auth Providers (`features/auth/providers/auth_provider.dart`)

### `authStateProvider`
```dart
@riverpod
Stream<User?> authState(AuthStateRef ref) =>
    FirebaseAuth.instance.authStateChanges();
```

### `currentUserProvider`
```dart
@riverpod
Future<AppUser?> currentUser(CurrentUserRef ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) return null;
  return ref.watch(userRepositoryProvider).getUser(authUser.uid);
}
```

### `currentTenantIdProvider`
```dart
@riverpod
String currentTenantId(CurrentTenantIdRef ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.tenantId ?? 'strongbox-default';
}
```

### `authNotifierProvider`
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // Methods: signInWithEmail, signInWithGoogle, signOut, resetPassword, register
}
```

---

## Admin Providers

### `dashboardProvider`
- **Inputs:** `tenantId`
- **Outputs:** `DashboardSummary` (box count, active jobs, pending pickups, pending deliveries)
- **Dependencies:** `storageUnitRepository`, `jobRepository`
- **Type:** `StreamProvider` — real-time
- **Caching:** 30s stale-while-revalidate

### `inventoryProvider`
- **Inputs:** `tenantId`, optional `clientId`, optional `StorageStatus`, optional `UnitType`
- **Outputs:** `List<StorageUnit>`
- **Dependencies:** `storageUnitRepository`
- **Type:** `StreamProvider` — real-time
- **Pagination:** 20 items per page, `startAfterDocument` cursor

### `inventoryFilterProvider`
- **Type:** `StateNotifier`
- **State:** `{clientId?, status?, unitType?, searchQuery?}`
- **Purpose:** Drives filter bar on inventory screen

### `storageUnitDetailProvider`
- **Inputs:** `unitId`
- **Outputs:** `StorageUnit` + `List<Photo>` + `List<Item>` (if open) + job history
- **Type:** `StreamProvider`

### `jobsProvider`
- **Inputs:** `tenantId`, optional filters
- **Outputs:** `List<Job>`
- **Type:** `StreamProvider`

### `jobFilterProvider`
- **Type:** `StateNotifier`
- **State:** `{type?, status?, dateRange?, driverId?, searchQuery?}`

### `createJobNotifier`
- **Type:** `StateNotifier`
- **State:** `NewJobDraft {type?, clientId?, unitIds, itemIds, scheduledDate?, timeWindow?, driverId?, notes?}`
- **Methods:** `setType`, `setClient`, `toggleUnit`, `setSchedule`, `setDriver`, `submit`, `reset`

### `clientsProvider`
- **Outputs:** `List<Client>` with joined user info
- **Type:** `StreamProvider`

### `clientDetailProvider`
- **Inputs:** `clientId`
- **Outputs:** `Client` + `List<StorageUnit>` + job history + subscription
- **Type:** `StreamProvider`

### `fleetProvider`
- **Outputs:** `List<DriverProfile>` (user + stats)
- **Type:** `StreamProvider`

### `reportsProvider`
- **Inputs:** `dateRange`
- **Outputs:** `ReportData {jobVolume, revenueData, fleetEfficiency, topClients}`
- **Type:** `FutureProvider` (not real-time, refreshed manually)

### `notificationsProvider`
- **Outputs:** `List<AppNotification>` grouped by type
- **Type:** `StreamProvider`

### `qrBatchesProvider`
- **Outputs:** `List<QRBatch>` ordered by date
- **Type:** `StreamProvider`

### `generateQRBatchNotifier`
- **State:** `{count: int, resolution: String, generatedCodes: List<String>?}`
- **Methods:** `setCount`, `setResolution`, `generate`, `print`

---

## Driver Providers

### `driverJobsProvider`
- **Inputs:** `driverId`, `date`
- **Outputs:** `{today: List<Job>, upcoming: List<Job>}`
- **Type:** `StreamProvider`

### `jobDetailProvider`
- **Inputs:** `jobId`
- **Outputs:** `Job` + `List<StorageUnit>` with scan status
- **Type:** `StreamProvider`

### `scannerProvider`
- **Type:** `StateNotifier`
- **State:** `ScannerState {isScanning, lastScannedCode?, resolvedUnit?, error?}`
- **Methods:** `onQRDetected`, `confirmScan`, `reset`
- **Offline behaviour:** Caches scan result locally if Firestore write fails, retries on reconnect

### `photoCaptureProvider`
- **Type:** `StateNotifier`
- **State:** `{jobId, unitId, capturedPhotos: List<XFile>, isUploading}`
- **Methods:** `addPhoto`, `removePhoto`, `upload`

### `signOffProvider`
- **Type:** `StateNotifier`
- **State:** `{method, signatureBytes?, otpSent, otpVerified}`
- **Methods:** `setMethod`, `setSignature`, `sendOTP`, `verifyOTP`, `confirm`

### `shiftProvider`
- **Type:** `StreamProvider`
- **Outputs:** `DriverShift?` — the active shift for this driver
- **Methods (via ShiftNotifier):** `startShift`, `endShift`, `startBreak`, `endBreak`

---

## Client Providers

### `clientStorageProvider`
- **Inputs:** `clientId`, optional filter
- **Outputs:** `List<StorageUnit>` + `List<Item>`
- **Type:** `StreamProvider`

### `unitDetailProvider` (client view)
- **Inputs:** `unitId`
- **Outputs:** `StorageUnit` + photos + items + status timeline
- **Type:** `StreamProvider`

### `deliveryRequestNotifier`
- **State:** `{selectedUnitIds, selectedItemIds, scheduledDate?, timeWindow?, confirmedAddress?, estimatedFee?}`
- **Methods:** `toggleUnit`, `toggleItem`, `setDate`, `setAddress`, `submit`
- **Validation:** At least one unit or item selected; date must be in the future

### `subscriptionProvider`
- **Inputs:** `clientId`
- **Outputs:** `Subscription` + `List<Invoice>` + usage stats
- **Type:** `StreamProvider`

### `clientNotificationsProvider`
- **Outputs:** `List<AppNotification>` for this client
- **Type:** `StreamProvider`

---

## Offline Behaviour
- Firestore has built-in offline persistence — enable in `main.dart`:
  ```dart
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  ```
- Scanner results that fail to write are queued in local state and shown as "pending sync"
- Photo uploads use a local file path until upload completes, then swap to Storage URL
- Show a connectivity banner when offline using a connectivity stream provider
