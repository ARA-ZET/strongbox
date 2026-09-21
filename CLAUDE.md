# StrongBox Logistics — Claude Code Project Context

This file gives Claude Code persistent context about this project. Read it before making any changes. Then read `docs/25_AI_DEVELOPMENT_RULES.md` — those 37 rules are non-negotiable.

---

## Monorepo Layout

This repo (`ARA-ZET/strongbox`) holds **two apps and shared packages**. Open
`strongbox.code-workspace` in VS Code.

```
strongbox/
├─ app/         Flutter app — everything below in this file refers to app/ unless stated
├─ web/         Next.js marketing site (strongboxstorage.co.za) — separate stack, separate deploy
├─ packages/
│  ├─ tokens/   design tokens: packages/tokens/tokens.json → app/lib/core/theme/tokens.g.dart + web/lib/tokens.g.ts
│  ├─ pricing/  price list: packages/pricing/pricing.json → app/lib/core/constants/price_list.g.dart + web/lib/pricing.g.ts
│  └─ schema/   shared domain-model contract (not built yet)
├─ docs/        the 25 spec docs — shared
├─ firestore.rules · firebase.json · .firebaserc   at repo root
```

- Paths in this document like `lib/...`, `pubspec.yaml`, `test/...` mean `app/lib/...` etc.
- Run Flutter commands from inside `app/`. Run the token generator from the repo root.
- **Never hardcode a colour, spacing or radius.** Edit `packages/tokens/tokens.json`, run
  `node packages/tokens/build.mjs`, then use `AppColors` / `AppSpacing` / `AppRadius`
  (they delegate to the generated `DesignTokens`). `app/test/core/design_tokens_test.dart` guards drift.
- **Never hardcode a price.** Prices (boxes, loose items, pickup vehicles) live in
  `packages/pricing/pricing.json`; run `node packages/pricing/build.mjs`. The app reads them via
  `Pricing` / `PriceList` (`lib/core/constants/pricing.dart`), the site via `web/lib/constants.ts`.
  `app/test/core/pricing_test.dart` guards drift.
- **The app is for account holders.** Marketing, pricing, calculators and quotes live on the
  website. The app opens on `/login` (or the user's portal when signed in); `/register` stays
  because the site's "Get Started" buttons link to it. Old `/quote` links redirect to `/register`.
- Deployment: `app/` → classic Firebase Hosting via GitHub Action; `web/` → Firebase App Hosting
  (root dir `web`). Both on project `strongbox-app`. See `README.md`.
- **Secrets are gitignored.** `app/lib/core/firebase_options.dart`,
  `app/android/app/google-services.json`, `app/ios/Runner/GoogleService-Info.plist`
  are NOT in git — only their `*.example` twins are. On a fresh clone, copy the
  examples (or run `flutterfire configure`). CI writes `firebase_options.dart`
  from a GitHub secret. Full checklist: `docs/SECURITY.md`. Never re-commit these.

---

## What This App Is

**StrongBox Logistics** is a Flutter web app (responsive: desktop + mobile) for a storage-and-transport business. Clients hand over belongings in boxes. Staff pick them up, store them at a secure facility, and deliver them back on demand — without the client leaving home.

**Billing model (matches the website):** storage is charged per unit per month — each
`StorageUnit` has a `priceKey` (box size or loose item) and a `monthlyRateZar` recorded when it is
registered. Units in `inTransit` / `inStorage` / `pendingDelivery` are billable. Billing is monthly
with no contract, no minimum term and **no term/prepay discounts**. Pickup is a once-off fee by
vehicle. There are no subscription plans. `StorageBill` does the arithmetic.

Three user roles share one Firebase backend:
- **Admin/Staff** — operations dashboard, inventory, QR management, job dispatch
- **Driver** — daily job list, QR scanning, photo capture, client sign-off
- **Client** — view stored items, request deliveries, manage subscription

---

## Full Specification Docs (read before building any feature)

All 25 specification documents live at `docs/` in this project folder.

| Doc | Purpose |
|---|---|
| `01_PRODUCT_VISION.md` | What we're building, subscription plans, roadmap |
| `02_BUSINESS_RULES.md` | Non-negotiable business logic |
| `03_DOMAIN_MODEL.md` | All entities and their properties |
| `04_ENUMS.md` | All enums — never use raw strings |
| `05_FIRESTORE_SCHEMA.md` | Exact Firestore structure + indexes |
| `06_FIREBASE_STORAGE.md` | Storage folder structure + security rules |
| `07_FLUTTER_ARCHITECTURE.md` | Repository pattern, freezed, folder structure, pubspec |
| `08_STATE_MANAGEMENT.md` | All providers for every screen |
| `09_REPOSITORIES.md` | All repository interfaces — use these |
| `10_DESIGN_SYSTEM.md` | AppColors, AppSpacing, AppRadius, typography |
| `11_COMPONENT_LIBRARY.md` | All shared widgets — check before building new ones |
| `12_NAVIGATION.md` | All routes, shell setup, deep linking |
| `13_AUTH.md` | Auth screens and flows |
| `14_ONBOARDING.md` | Registration, invites, first-run |
| `15_CLIENT_PORTAL.md` | All client screens, providers, permissions |
| `16_DRIVER_PORTAL.md` | All driver screens, shift, scan, sign-off |
| `17_ADMIN_PORTAL.md` | Admin dashboard, inventory, jobs, fleet |
| `18_QR_SYSTEM.md` | QR generation, linking, scanner widget |
| `19_INVENTORY.md` | Inventory grid, unit detail, add unit |
| `20_PICKUPS.md` | Pickup job lifecycle end-to-end |
| `21_DELIVERIES.md` | Delivery job lifecycle end-to-end |
| `22_NOTIFICATIONS.md` | FCM push, email, in-app bell |
| `23_BILLING.md` | Stripe extension, checkout, portal |
| `24_ANALYTICS.md` | Reports, charts, KPI cards |
| `25_AI_DEVELOPMENT_RULES.md` | **READ THIS FIRST** — 37 mandatory rules |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Flutter (web + mobile) | UI framework |
| Riverpod 2 + riverpod_annotation + riverpod_generator | State management |
| go_router | Navigation / deep linking |
| **freezed + json_serializable** | Immutable data models (mandatory) |
| Firebase Auth | Authentication (email + Google SSO) |
| Cloud Firestore | All app data (real-time) |
| Firebase Storage | Photos (units, items, driver captures, signatures) |
| Cloud Functions (Node.js) | Stripe webhooks, email triggers, status automation |
| Stripe via Firebase Extension | Monthly subscription billing + customer portal |
| qr_flutter | QR code rendering |
| mobile_scanner | Camera-based QR scanning |
| pdf + printing | Printable QR label sheets |
| signature | Client sign-off pad |
| fl_chart | Analytics charts |
| google_fonts | Inter typeface |
| image | Photo compression before upload |

---

## Folder Structure

```
app/
  lib/
  core/
    theme/
      tokens.g.dart          ← GENERATED from packages/tokens/tokens.json — do not edit
      app_colors.dart        ← AppColors — delegates to DesignTokens (USE THESE, never hardcode hex)
      app_spacing.dart       ← AppSpacing — delegates to DesignTokens
      app_radius.dart        ← AppRadius — delegates to DesignTokens
      app_theme.dart         ← ThemeData, component themes
    widgets/                 ← Shared reusable widgets (StatusChip, SummaryCard, etc.)
    constants/
      firestore_collections.dart
    utils/
    exceptions/
      app_exception.dart
  features/
    auth/
      screens/               ← LoginScreen, RegisterScreen
      providers/             ← authStateProvider, currentUserProvider, authNotifierProvider
      models/                ← AppUser (freezed)
    admin/
      screens/               ← Dashboard, Inventory, UnitDetail, QRManagement, Jobs, Fleet, etc.
      providers/
      repositories/          ← implementations of abstract interfaces from core/repositories/
      widgets/               ← AdminShell (sidebar + top bar)
    driver/
      screens/               ← Jobs, JobDetail, Scanner, PhotoCapture, SignOff, Profile, Shift
      providers/
      widgets/               ← DriverShell (bottom nav)
    client/
      screens/               ← Dashboard, MyStorage, UnitDetail, DeliveryRequest, Billing, Account
      providers/
      widgets/               ← ClientShell (top nav desktop / bottom nav mobile)
  repositories/
    abstract/                ← StorageUnitRepository, JobRepository, etc. (interfaces)
    firestore/               ← FirestoreStorageUnitRepository, etc. (implementations)
  routing/
    app_router.dart          ← All routes defined here with role-based redirects
  main.dart
  functions/
    index.js                 ← Firebase Cloud Functions
web/                         ← Next.js marketing site (own stack: React, Tailwind, App Hosting)
packages/
  tokens/                    ← tokens.json + build.mjs (shared design tokens)
  schema/                    ← shared domain-model contract (not built yet)
docs/                        ← 25 spec docs (shared)
```

---

## Architecture: Critical Rules

### Repository Pattern — mandatory
**Never call `FirebaseFirestore.instance` or `FirebaseStorage.instance` from a widget or provider.** Always go through a repository.

```dart
// WRONG — direct Firestore in provider
final unitsProvider = StreamProvider((ref) =>
    FirebaseFirestore.instance.collection('storageUnits').snapshots()...);

// CORRECT — via repository
final unitsProvider = StreamProvider((ref) {
  final repo = ref.watch(storageUnitRepositoryProvider);
  return repo.watchAll(tenantId: Collections.tenantId);
});
```

### freezed Models — mandatory
All domain models use `@freezed`. No plain Dart classes for domain objects.

### tenantId on every query
In v1: `tenantId = 'strongbox-default'` (constant in `Collections`). Every Firestore query must filter by tenantId.

### isDeleted filter on every query
All `watchAll` / `getAll` queries include `where('isDeleted', isEqualTo: false)`.

### Soft delete only
Never call `.delete()` on Firestore documents. Always set `isDeleted: true, deletedAt: serverTimestamp()`.

### Status changes = transaction + AuditEvent
Every status change writes the entity update AND an `AuditEvent` in the same Firestore transaction.

---

## Terminology (Updated)

| Old (avoid) | New (use) |
|---|---|
| `Box` / `BoxModel` | `StorageUnit` |
| `boxes` collection | `storageUnits` collection |
| `boxId` | `unitId` |
| `BoxCard` | `StorageUnitCard` |
| `box_model.dart` | `storage_unit.dart` |

---

## Design System

### Colours — always use AppColors constants, never raw hex

The palette mirrors the marketing site (`web/tailwind.config.ts`). Values live in
`packages/tokens/tokens.json` — when the web palette changes, update both together.

```dart
// lib/core/theme/app_colors.dart
navyDeep       #0A1A33   ← admin sidebar, dark panels, headings (Display/Headline/Title)
navy           #0F2A52   ← dark cards / summary panels
navySoft       #1B3E6F   ← borders + hover on dark grounds
accent         #1D6FE0   ← primary CTA fill, FAB, active fills, progress (ColorScheme.primary)
accentDeep     #1557B5   ← links, emphasis text, selected borders/icons on light grounds
onAccent       #FFFFFF   ← text/icons ON an accent fill (never accentDeep on accent)
sky            #5EA6F5   ← accent for icons/labels on navy or camera backgrounds
skyTint        #E8F1FD   ← chips, icon wells, nav indicator, selected-card fill
scaffold       #F4F8FD   ← page background + input fill (web "mist")
surface        #FFFFFF   ← cards, modals
surfaceContainer #E3ECF7 ← table rows, progress track
textPrimary    #10203A
textSecondary  #4A5A72
textHint       #6B7F9C
border         #C3D2E6
```

Buttons and cards use 12px radius (`AppRadius.md`), inputs 8px (`AppRadius.sm`).
Shadows are navy-tinted: use `AppShadow.card` / `AppTheme.cardShadow`.

### Status Chip Colours
```
completed / active / delivered / inStorage  → bg #E8F5F0  text #00A858
inProgress / inTransit / pendingDelivery    → bg #FFF3E0  text #E67E22
scheduled / pending / pendingPickup         → bg #F0F0F0  text #44474E
cancelled / critical                        → bg #FFEBEB  text #BA1A1A
pastDue / unpaid                            → bg #FFF0D4  text #835500
```

### Typography — Inter via google_fonts
```
Display   28px Bold     ← page headlines
Headline  22px Bold     ← card titles
Title     16px SemiBold ← section headers
Label     14px Medium   ← table headers, chips
Body      14px Regular  ← table rows, body text
Caption   12px Regular  ← timestamps, hints
```

### Spacing & Shape (AppSpacing / AppRadius constants)
- Card border radius: **12px** (`AppRadius.md`)
- Button border radius: **12px** (`AppRadius.md`); input radius: **8px** (`AppRadius.sm`)
- Status chips: **full pill** (`AppRadius.pill`)
- Card shadow: `AppShadow.card` (blur 20, 4% navyDeep, offset 0,4 — web `shadow-tactile`)
- Page padding: **24px** desktop (`AppSpacing.lg`), **16px** mobile (`AppSpacing.md`)

---

## Shared Widgets (lib/core/widgets/)

Always use these — do not rebuild them inline. See `docs/11_COMPONENT_LIBRARY.md` for full props.

| Widget | Key Props | Notes |
|---|---|---|
| `StatusChip` | `status: String` | Auto-selects colour from status string |
| `SummaryCard` | `icon, value, label, trend?` | Dashboard stat cards |
| `AppSearchBar` | `hint, onChanged, onFilter?` | Debounced search bar |
| `PrimaryButton` | `label, onPressed, loading?` | Accent-blue full-width button |
| `SecondaryButton` | `label, onPressed` | Navy outline button |
| `DestructiveButton` | `label, onPressed` | Red button for dangerous actions |
| `StorageUnitCard` | `unit: StorageUnit, onTap` | Inventory grid card with photo |
| `QRDisplayCard` | `qrData, label` | QR image + print/copy actions |
| `PhotoGallery` | `photoUrls, onAddPhoto?` | Scrollable gallery + lightbox |
| `PhotoUploadZone` | `onPhotosSelected, existingPhotos` | Dashed upload zone |
| `StepIndicator` | `steps, currentStep` | Multi-step form stepper |
| `SectionHeader` | `title, action?` | Section heading row |
| `LoadingSkeleton` | `.card()`, `.listTile()` | Shimmer loading placeholders |
| `EmptyState` | `icon, title, subtitle, action?` | Empty screen state |
| `AppDataTable` | `columns, rows, onSort` | Sortable data table |
| `PaginationRow` | `currentPage, totalPages, onPageChange` | Table pagination |
| `ConfirmDialog` | `title, message, isDestructive, onConfirm` | Confirmation modal |
| `ConnectivityBanner` | — | Offline warning auto-shown |

---

## Data Models (all freezed)

### AppUser
```dart
uid, name, email, phone, tenantId
role: UserRole (admin | driver | client)
clientId?, fcmToken?, stripeCustomerId?, subscriptionStatus?
isDeleted, deletedAt?
```

### StorageUnit (was BoxModel)
```dart
id, tenantId, clientId
type: UnitType (closed | open)
priceKey?: String (box size / loose-item id from the price list), monthlyRateZar: int
qrCodeId: String (unique SBX-XXXX-XX format)
photoIds: List<String> (Photo doc IDs, not Storage URLs)
label, notes?
status: StorageStatus (pendingPickup|inTransit|inStorage|pendingDelivery|delivered)
jobId?, createdAt, updatedAt, isDeleted, deletedAt?
```

### Item
```dart
id, tenantId, boxId (= StorageUnit id), clientId, qrCodeId
photoIds: List<String>, description, status, createdAt, isDeleted
```

### Job
```dart
id, tenantId, type: JobType (pickup|delivery)
clientId, driverId?
status: JobStatus (scheduled|assigned|inProgress|completed|cancelled)
scheduledDate, timeWindow: TimeWindow
unitIds: List<String>, scannedUnitIds: List<String>
notes?, driverPhotoIds: List<String>
clientSignatureUrl?, completedAt?
createdAt, updatedAt, isDeleted
```

### QRCode
```dart
id, tenantId, code, codeType, isLinked
linkedEntityId?, batchId?, createdAt, linkedAt?, isDeleted
```

---

## Firestore Collections

```
users/{uid}
clients/{clientId}
storageUnits/{unitId}      ← was 'boxes'
items/{itemId}
jobs/{jobId}
qrCodes/{codeId}
qrBatches/{batchId}
auditEvents/{eventId}      ← append-only
notifications/{notifId}
issueReports/{reportId}
customers/{uid}            ← managed by Stripe Firebase Extension
```

---

## Routing (go_router)

```
/login, /register

/admin/dashboard         ← redirect here if role == admin
/admin/inventory
/admin/inventory/:unitId  ← was :boxId
/admin/qr
/admin/jobs
/admin/jobs/new
/admin/jobs/:jobId
/admin/clients
/admin/clients/:clientId
/admin/fleet
/admin/fleet/:driverId
/admin/reports
/admin/notifications
/admin/settings

/driver/jobs             ← redirect here if role == driver
/driver/jobs/:jobId
/driver/jobs/:jobId/capture
/driver/jobs/:jobId/signoff
/driver/scan
/driver/shift
/driver/account
/driver/report-issue

/client/dashboard        ← redirect here if role == client
/client/storage
/client/storage/:unitId   ← was :boxId
/client/requests/new
/client/subscription
/client/account
/client/notifications
```

Root `/` redirects based on role. Unauthenticated → `/login`. `/quote` (legacy website link) → `/register`.

---

## Shell Layouts

### Admin Shell
- **Desktop (>900px):** Fixed 240px navy sidebar + scrollable main content
- **Mobile:** Bottom NavigationBar (5 tabs) + Drawer for overflow items
- Sidebar nav items: Dashboard, Inventory, Job Tracking, Fleet, Clients, Reports, Settings, Support
- Bottom of sidebar: accent "Quick Scan" button, then Settings, Support, Logout

### Driver Shell
- **Mobile-first** (all driver screens are mobile-sized)
- Bottom NavigationBar: Jobs, Scan, Shift, Account

### Client Shell
- **Desktop:** Top nav bar — Logo + nav links + notification bell + avatar
- **Mobile:** Bottom NavigationBar: Home, Storage, Requests, Account

---

## Designs Reference

All screen designs are PNG images at:
```
/Users/Bunny/Documents/stitch_strongbox_ui_logistics_kit/{screen_name}/screen.png
```

Screen index:
```
Admin:   admin_portal_dashboard, admin_clients_list, admin_client_detail,
         admin_all_inventory, admin_box_detail, admin_qr_management,
         admin_jobs_list, admin_create_new_job_step_1/_2/_3_schedule/_4_confirm,
         admin_drivers_fleet, admin_driver_detail_view,
         admin_notifications_alerts_center, admin_reports_analytics_dashboard

Driver:  driver_portal_jobs, driver_job_detail, driver_qr_scanner,
         driver_photo_capture, driver_client_sign_off, driver_profile_stats,
         driver_shift_management_id, driver_report_issue_maintenance

Client:  client_portal_home, client_portal_dashboard_overview,
         client_portal_my_storage, client_box_detail_view,
         client_request_delivery_step_1, client_subscription_billing,
         client_account_settings, client_team_notification_settings

Auth:    strongbox_login, strongbox_login_mobile, strongbox_registration_payment
```

Always read the PNG first with the Read tool before implementing any screen.

---

## Key Patterns

### Riverpod
- Use `@riverpod` annotation + `riverpod_generator` for all providers
- Real-time Firestore data → `StreamProvider`
- One-time reads → `FutureProvider`
- Mutable state (forms, filters) → `Notifier` / `AsyncNotifier`
- Never call Firestore directly from widgets — always go through a repository

### Responsive Layout
```dart
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth > 900) return DesktopLayout();
  return MobileLayout();
})
```

### Firestore Writes — always server timestamps
```dart
'createdAt': FieldValue.serverTimestamp(),
'updatedAt': FieldValue.serverTimestamp(),
```

### QR Code Formats
- Storage unit: `SBX-{4digits}-{letter}{digit}` e.g. `SBX-9942-A1`
- Item: `ITM-{4digits}-{letter}{digit}` e.g. `ITM-1234-B2`
- Driver E-ID: `DRV-{first 8 chars of uid}`

### Photo Storage Paths
```
{tenantId}/storageUnits/{unitId}/exterior/{timestamp}-{8charUUID}.jpg
{tenantId}/jobs/{jobId}/driver-photos/{timestamp}-{8charUUID}.jpg
{tenantId}/jobs/{jobId}/signature.png
{tenantId}/drivers/{uid}/profile.jpg
```

---

## Build Stages

See `strongbox_claude_code_prompts.md` for the full prompt for each stage. **Current stage: Stage 7** (Stripe wiring, Cloud Functions, FCM, deployment).

| Stage | Content | Status |
|---|---|---|
| 1 | Project setup, design system, shared widgets, auth screens | Done |
| 2 | Admin shell, dashboard, client directory, client detail | Done |
| 3 | Inventory grid, unit detail, QR batch + linking | Done |
| 4 | Jobs list, 4-step job creation, fleet, notifications, reports | Done |
| 5 | Driver portal — all screens | Done |
| 6 | Architecture audit + client portal — all screens | Done |
| 7 | **Stripe wiring, Cloud Functions, FCM, deployment** | **Current** |

---

## Do Not

- Do not hardcode hex colours — always use `AppColors.*`
- Do not hardcode spacing — always use `AppSpacing.*`
- Do not put business logic in widgets — use providers
- Do not call `FirebaseFirestore` or `FirebaseStorage` directly from UI or providers
- Do not use plain Dart classes for domain models — use `@freezed`
- Do not use raw strings for statuses — use enums
- Do not call `.delete()` on Firestore documents — use soft delete
- Do not write two Firestore documents in separate `.set()` calls — use transactions
- Do not create new shared widgets without checking `lib/core/widgets/` first
- Do not use `setState` for anything that spans multiple screens
- Do not skip reading the screen PNG before implementing a screen
- Do not query Firestore without filtering `tenantId` and `isDeleted == false`
