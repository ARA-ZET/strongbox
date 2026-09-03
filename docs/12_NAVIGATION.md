# 12 — Navigation

All navigation uses `go_router`. Never use `Navigator.push` directly.

---

## Route Table

| Path | Screen | Role | Shell |
|---|---|---|---|
| `/` | Redirect based on role | Any | None |
| `/login` | LoginScreen | Public | None |
| `/register` | RegisterScreen | Public | None |
| `/admin` | Redirect → `/admin/dashboard` | admin | AdminShell |
| `/admin/dashboard` | AdminDashboardScreen | admin | AdminShell |
| `/admin/inventory` | InventoryScreen | admin | AdminShell |
| `/admin/inventory/:unitId` | UnitDetailScreen (admin) | admin | AdminShell |
| `/admin/qr` | QRManagementScreen | admin | AdminShell |
| `/admin/jobs` | JobsListScreen | admin | AdminShell |
| `/admin/jobs/new` | CreateJobScreen | admin | AdminShell |
| `/admin/jobs/:jobId` | JobDetailScreen (admin) | admin | AdminShell |
| `/admin/clients` | ClientsListScreen | admin | AdminShell |
| `/admin/clients/:clientId` | ClientDetailScreen | admin | AdminShell |
| `/admin/fleet` | FleetScreen | admin | AdminShell |
| `/admin/fleet/:driverId` | DriverDetailScreen | admin | AdminShell |
| `/admin/reports` | ReportsScreen | admin | AdminShell |
| `/admin/notifications` | NotificationsScreen (admin) | admin | AdminShell |
| `/admin/settings` | SettingsScreen | admin | AdminShell |
| `/driver` | Redirect → `/driver/jobs` | driver | DriverShell |
| `/driver/jobs` | DriverJobsScreen | driver | DriverShell |
| `/driver/jobs/:jobId` | DriverJobDetailScreen | driver | DriverShell |
| `/driver/scan` | ScannerScreen | driver | DriverShell |
| `/driver/shift` | ShiftScreen | driver | DriverShell |
| `/driver/account` | DriverAccountScreen | driver | DriverShell |
| `/driver/jobs/:jobId/capture` | PhotoCaptureScreen | driver | None (full screen) |
| `/driver/jobs/:jobId/signoff` | SignOffScreen | driver | None (full screen) |
| `/driver/report-issue` | ReportIssueScreen | driver | DriverShell |
| `/client` | Redirect → `/client/dashboard` | client | ClientShell |
| `/client/dashboard` | ClientDashboardScreen | client | ClientShell |
| `/client/storage` | MyStorageScreen | client | ClientShell |
| `/client/storage/:unitId` | UnitDetailScreen (client) | client | ClientShell |
| `/client/requests/new` | DeliveryRequestScreen | client | ClientShell |
| `/client/subscription` | SubscriptionScreen | client | ClientShell |
| `/client/account` | ClientAccountScreen | client | ClientShell |
| `/client/notifications` | ClientNotificationsScreen | client | ClientShell |

---

## Root Redirect Logic

```dart
redirect: (context, state) async {
  final user = await ref.read(currentUserProvider.future);
  final isOnAuthPage = state.matchedLocation.startsWith('/login') 
    || state.matchedLocation.startsWith('/register');

  if (user == null) {
    return isOnAuthPage ? null : '/login';
  }

  if (state.matchedLocation == '/') {
    return switch (user.role) {
      UserRole.admin  => '/admin/dashboard',
      UserRole.driver => '/driver/jobs',
      UserRole.client => '/client/dashboard',
    };
  }

  // Role guard — prevent cross-role navigation
  if (user.role == UserRole.client && state.matchedLocation.startsWith('/admin')) {
    return '/client/dashboard';
  }
  if (user.role == UserRole.driver && state.matchedLocation.startsWith('/admin')) {
    return '/driver/jobs';
  }

  return null;
}
```

---

## Shell Routes

Each shell wraps its child routes in a persistent layout (sidebar/nav bar) using `ShellRoute`:

```dart
ShellRoute(
  builder: (context, state, child) => AdminShell(child: child),
  routes: [/* all /admin/* routes */],
)
```

Full-screen routes (photo capture, scanner) are **not** inside a shell route — they render without nav chrome.

---

## Navigation Flows

### Login → Dashboard
```
/login → [auth success] → / → redirect → /admin/dashboard OR /driver/jobs OR /client/dashboard
```

### Admin creates a job
```
/admin/dashboard → [+ New Job] → /admin/jobs/new → [4 steps] → [Submit] → /admin/jobs
```

### Driver completes a pickup
```
/driver/jobs → [tap job] → /driver/jobs/:jobId → [Start Job] → [Scan each box]
→ [Add Photo] → /driver/jobs/:jobId/capture → [back] → [Complete] → /driver/jobs/:jobId/signoff
→ [Confirm] → /driver/jobs (job marked complete)
```

### Client requests delivery
```
/client/dashboard → [Request Delivery] → /client/requests/new
→ [select items → date → address → confirm] → /client/dashboard
```

### QR Scan (standalone)
```
/driver/scan OR /admin/dashboard [Quick Scan] → [scan QR] → bottom sheet with unit info
→ [Confirm] → write to Firestore → dismiss
```

---

## Deep Linking
go_router handles deep links automatically. Example deep links:
- `strongbox://admin/inventory/unit-uuid` → admin unit detail
- `strongbox://driver/jobs/job-id` → driver job detail
- `strongbox://client/storage/unit-uuid` → client unit detail

Configure URL schemes in `AndroidManifest.xml` and `Info.plist` for native deep links.

---

## Back Navigation
- Always provide a back button on detail screens
- Use `context.pop()` for simple back, `context.go()` for intentional navigation
- On driver job completion, use `context.go('/driver/jobs')` — not `pop()` — to clear the stack
