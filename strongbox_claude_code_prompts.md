# StrongBox — Claude Code Build Prompts
### How to use this file
Each **Stage** below is a self-contained prompt. Copy the entire block between the `--- STAGE X START ---` and `--- STAGE X END ---` markers and paste it into Claude Code in VS Code. Complete and test each stage before moving to the next. Your Stitch designs live at:
`/Users/Bunny/Documents/stitch_strongbox_ui_logistics_kit/<screen_name>/screen.png`

---

## DESIGN SYSTEM REFERENCE (read before all stages)

**Font:** Inter (Google Fonts)  
**Icons:** Material Symbols Outlined  

**Colours (exact hex):**
| Token | Hex | Use |
|---|---|---|
| Navy / Primary | `#1A2B4A` | Sidebar bg, nav bg, dark buttons |
| Amber / Action | `#FEAE2C` | Primary CTA buttons, active nav items, highlights |
| Amber Dark | `#6B4500` | Text on amber buttons |
| Background | `#F5F2FF` | Scaffold / page background |
| Surface | `#FFFFFF` | Cards, modals |
| Surface Container | `#EFECFF` | Table rows, input bg, secondary cards |
| Text Primary | `#1A1A2E` | Headlines, body |
| Text Secondary | `#44474E` | Subtitles, captions |
| Border | `#C5C6CF` | Dividers, input borders |
| Success Green | `#00A858` | Completed / Active status |
| Warning Amber | `#E67E22` | In Transit / Processing status |
| Error Red | `#BA1A1A` | Cancelled / Critical |
| Pending Grey | `#75777E` | Pending / Unassigned status |

**Border radius:** Cards = 12px · Inputs/buttons = 8px · Status chips = full pill  
**Elevation:** Cards: `BoxShadow(blurRadius: 8, color: Color(0x14000000), offset: Offset(0,2))`  
**Typography scale (Inter):**
- Display: 28px Bold
- Headline: 22px Bold  
- Title: 16px SemiBold  
- Label: 14px Medium  
- Body: 14px Regular  
- Caption: 12px Regular  

**Status chip colours:**
- `Completed` / `Active` / `Delivered` → bg `#E8F5F0`, text `#00A858`
- `In Progress` / `In Transit` → bg `#FFF3E0`, text `#E67E22`
- `Scheduled` / `Pending` → bg `#F0F0F0`, text `#44474E`
- `Cancelled` / `Critical` → bg `#FFEBEB`, text `#BA1A1A`
- `Past Due` → bg `#FFF0D4`, text `#835500`

---

## --- STAGE 1 START ---

## Stage 1 — Project Foundation, Design System & Auth Screens

You are building **StrongBox Logistics** — a Flutter web app (also responsive on mobile) for a storage and transport business. There are three user roles: **admin**, **driver**, and **client**. The entire project uses Flutter + Riverpod for state management + Firebase (Auth, Firestore, Storage) + go_router for navigation.

### 1.1 — Create the Flutter project

```
flutter create strongbox --org com.strongboxlogistics --platforms web,android,ios
```

Set up the folder structure:
```
lib/
  core/
    theme/
      app_theme.dart        # All colours, typography, component themes
      app_colors.dart       # Colour constants
    widgets/                # Shared reusable widgets
    utils/
    constants/
  features/
    auth/
      screens/
      providers/
      models/
    admin/
      screens/
      providers/
      widgets/
    driver/
      screens/
      providers/
      widgets/
    client/
      screens/
      providers/
      widgets/
  routing/
    app_router.dart
  main.dart
```

### 1.2 — pubspec.yaml dependencies

Add these packages:
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  firebase_storage: ^12.1.0
  cloud_functions: ^5.0.4
  go_router: ^14.2.0
  google_fonts: ^6.2.1
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.1.1
  pdf: ^3.11.0
  printing: ^5.13.0
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  fl_chart: ^0.68.0
  intl: ^0.19.0
  uuid: ^4.4.2
  equatable: ^2.0.5
  signature: ^5.4.1

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.11
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10
```

### 1.3 — Design System (app_colors.dart + app_theme.dart)

Create `lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const navy = Color(0xFF1A2B4A);
  static const amber = Color(0xFFFEAE2C);
  static const amberDark = Color(0xFF6B4500);

  // Backgrounds
  static const scaffold = Color(0xFFF5F2FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEFECFF);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF44474E);

  // Border
  static const border = Color(0xFFC5C6CF);

  // Status
  static const statusSuccess = Color(0xFF00A858);
  static const statusSuccessBg = Color(0xFFE8F5F0);
  static const statusWarning = Color(0xFFE67E22);
  static const statusWarningBg = Color(0xFFFFF3E0);
  static const statusError = Color(0xFFBA1A1A);
  static const statusErrorBg = Color(0xFFFFEBEB);
  static const statusPending = Color(0xFF75777E);
  static const statusPendingBg = Color(0xFFF0F0F0);
  static const statusPastDue = Color(0xFF835500);
  static const statusPastDueBg = Color(0xFFFFF0D4);
}
```

Create `lib/core/theme/app_theme.dart` with a `ThemeData` that sets:
- `scaffoldBackgroundColor: AppColors.scaffold`
- `colorScheme` using navy as primary, amber as secondary
- `cardTheme`: white surface, 12px border radius, the box shadow
- `inputDecorationTheme`: filled with `AppColors.surfaceContainer`, 8px border radius, `AppColors.border` outline
- `elevatedButtonTheme`: amber background, `AppColors.amberDark` text, 8px radius, height 48px
- `textTheme` using Inter via google_fonts with the type scale defined above

### 1.4 — Shared Widgets

Create these reusable widgets in `lib/core/widgets/`:

**`status_chip.dart`** — Takes a `String status` and returns a pill-shaped Container with the correct bg/text colour from the status colour table. Statuses to handle: `completed`, `active`, `delivered`, `in_progress`, `in_transit`, `in_storage`, `scheduled`, `pending`, `cancelled`, `critical`, `past_due`, `on_job`, `available`.

**`summary_card.dart`** — White card with 12px radius and shadow. Props: `icon`, `IconData`, `value` String, `label` String, `trend` String? (optional, shown as green/red badge). Used in dashboard headers.

**`app_search_bar.dart`** — Rounded search input with a search icon on the left and optional filter icon on the right. Background `AppColors.surfaceContainer`.

**`primary_button.dart`** — Full-width amber button, 48px height, 8px radius, arrow icon on right. Takes `label` and `onPressed`.

**`secondary_button.dart`** — Navy outline button, same size as primary.

**`section_header.dart`** — Row with bold title on left and optional action link on right.

**`photo_upload_zone.dart`** — Dashed border container (1.5px, `AppColors.border`), camera icon centre, label "Tap to photograph or upload". Shows thumbnails when photos added.

**`qr_display_card.dart`** — White card with QR code image centred (using `qr_flutter`), ID text below, Print and Copy buttons. Takes `qrData` String and `label` String.

**`box_card.dart`** — 12px radius card, photo thumbnail top (150px, cover fit), then label, client name, type badge (CLOSED BOX or OPEN BOX in a chip), status chip, last updated text. Tappable.

**`step_indicator.dart`** — Horizontal stepper. Takes `steps` List<String> and `currentStep` int. Completed steps show amber filled circle with checkmark, active step shows amber outlined circle with number, future steps show grey.

### 1.5 — Firebase Setup

Create `lib/core/firebase_options.dart` (use `flutterfire configure` in terminal to generate this).

Create `lib/core/constants/firestore_collections.dart`:
```dart
class Collections {
  static const users = 'users';
  static const clients = 'clients';
  static const boxes = 'boxes';
  static const items = 'items';
  static const jobs = 'jobs';
  static const qrBatches = 'qrBatches';
  static const subscriptions = 'subscriptions';
}
```

Create Firestore data models (plain Dart classes with `fromJson`/`toJson`) in `lib/features/*/models/`:

**`app_user.dart`:**
```dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin' | 'driver' | 'client'
  final String? stripeCustomerId;
  final String? subscriptionStatus;
}
```

**`box_model.dart`:**
```dart
class BoxModel {
  final String id;
  final String clientId;
  final String type; // 'closed' | 'open'
  final String qrCode;
  final List<String> photos;
  final String label;
  final String status; // 'pending_pickup'|'in_transit'|'in_storage'|'pending_delivery'|'delivered'
  final String? jobId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**`item_model.dart`:**
```dart
class ItemModel {
  final String id;
  final String boxId;
  final String clientId;
  final String qrCode;
  final List<String> photos;
  final String description;
  final String status;
  final DateTime createdAt;
}
```

**`job_model.dart`:**
```dart
class JobModel {
  final String id;
  final String type; // 'pickup' | 'delivery'
  final String clientId;
  final String? driverId;
  final String status; // 'scheduled'|'assigned'|'in_progress'|'completed'|'cancelled'
  final DateTime scheduledDate;
  final List<String> boxIds;
  final List<String> itemIds;
  final String? notes;
  final String? clientSignatureUrl;
  final DateTime? completedAt;
}
```

### 1.6 — Auth Provider (Riverpod)

Create `lib/features/auth/providers/auth_provider.dart`:
- `authStateProvider`: StreamProvider listening to `FirebaseAuth.instance.authStateChanges()`
- `currentUserProvider`: FutureProvider that fetches the AppUser doc from Firestore when auth state changes
- `authNotifierProvider`: AsyncNotifier with methods `signInWithEmail`, `signInWithGoogle`, `signOut`, `resetPassword`

### 1.7 — Routing (go_router)

Create `lib/routing/app_router.dart` with a `GoRouter` instance.

Routes:
```
/login                          → LoginScreen
/register                       → RegisterScreen
/admin                          → AdminShell (redirect if not admin)
  /admin/dashboard
  /admin/inventory
  /admin/inventory/:boxId
  /admin/qr
  /admin/jobs
  /admin/jobs/new
  /admin/clients
  /admin/clients/:clientId
  /admin/fleet
  /admin/fleet/:driverId
  /admin/reports
  /admin/notifications
  /admin/settings
/driver                         → DriverShell (redirect if not driver)
  /driver/jobs
  /driver/jobs/:jobId
  /driver/scan
  /driver/shift
  /driver/account
/client                         → ClientShell (redirect if not client)
  /client/dashboard
  /client/storage
  /client/storage/:boxId
  /client/requests/new
  /client/subscription
  /client/account
  /client/notifications
```

Add a redirect on root `/` that reads `currentUserProvider` and sends to the correct portal based on role. Unauthenticated users go to `/login`.

### 1.8 — Auth Screens

**Login Screen** — Reference design: `strongbox_login/screen.png` (desktop) and `strongbox_login_mobile/screen.png` (mobile).

Desktop layout: Full-screen navy `#1A2B4A` background. Centred white card (480px wide, 12px radius). Inside the card:
- StrongBox box icon (navy square with white box icon, 64px, 16px radius)
- "StrongBox Logistics" headline (22px Bold, navy)
- Tagline: "Your stuff. Safe. Tracked. Delivered." (14px, grey)
- "Email Address" label + TextFormField with email icon prefix
- "Password" label + "Forgot password?" link row + TextFormField with lock icon + visibility toggle
- Amber "Sign In →" ElevatedButton (full width)
- "or continue with" divider row
- White outlined "Continue with Google" button with Google logo
- "Don't have an account? Create an account" text with amber link

Below the card: 3 stats chips (2.4M Packages · 99.9% Uptime · 12k+ Fleet) in semi-transparent dark cards.

Mobile layout: Navy background, amber box icon top centre, "StrongBox Logistics" + "Enterprise Fleet Management" subtitle, white card with "Welcome Back" heading, WORK EMAIL + SECURITY KEY fields, "Remember device" checkbox + "Forgot access?" link, SIGN IN button, Google button, "New dispatcher? Contact System Admin" amber link.

Use `LayoutBuilder` to switch between desktop (>768px) and mobile layouts.

**Registration / Subscription Screen** — Reference: `strongbox_registration_payment/screen.png`.

Split layout: Left panel (navy, 35% width) with StrongBox logo, tagline, 3 feature bullet points (Secure Architecture, Global Tracking, Smart Network) each with navy icon box + title + description. Right panel (white): 3-step stepper (Profile · Billing · Review) + form content per step.

Step 2 (Billing shown): "Choose Plan" heading, 3 plan cards side by side (Starter $49/mo, Professional $199/mo with "MOST POPULAR" amber badge, Enterprise Custom). Selected plan has amber border. Below: "Payment Details" card with card number, expiry, CVC, billing zip fields. "Subscribe & Finish Setup →" amber button. SSL/PCI/Secure badges row.

On successful subscription, write user doc to Firestore with role: 'client', then route to `/client/dashboard`.

## --- STAGE 1 END ---

---

## --- STAGE 2 START ---

## Stage 2 — Admin Portal Shell + Dashboard + Clients

You are continuing the StrongBox Flutter app. Stage 1 (auth screens, design system, routing) is complete. Now build the Admin portal shell and its first three screens.

### 2.1 — Admin Shell Layout

Create `lib/features/admin/widgets/admin_shell.dart`.

This is a `StatelessWidget` using `go_router`'s `ShellRoute`. It wraps all admin screens in a persistent layout.

**Desktop (width > 900px):** Row with a fixed 240px left sidebar + Expanded main content area.

**Sidebar design** — Reference: `admin_portal_dashboard/screen.png`.
- Background: `#1A2B4A` (navy)
- Top: StrongBox amber box icon (40px) + "StrongBox" in amber bold text + subtitle in white/60 opacity
- Below: User avatar card — circular avatar, "Admin Portal" label in amber, role subtitle in white/60
- Navigation items (each 48px tall, 12px horizontal padding, 8px radius):
  - Active state: amber `#FEAE2C` background, amber dark `#6B4500` text and icon
  - Inactive: transparent bg, white/70 text
  - Items: Dashboard (grid_view), Inventory (inventory_2), Job Tracking (local_shipping), Fleet (directions_car), Clients (group), Reports (bar_chart), Settings (settings), Support (help_outline)
- Bottom: "Quick Scan" amber full-width button with QR icon, then Settings + Support items, then Logout
- At very bottom when sidebar overflows: scroll

**Mobile (width ≤ 900px):** Standard Scaffold with a bottom NavigationBar (5 tabs: Dashboard, Inventory, Jobs, Fleet, More — "More" opens a drawer for the remaining items). Bottom nav active item uses amber.

**Top app bar (desktop):** White/surface, shows "StrongBox Logistics" title on left, global search bar centre (550px wide), notification bell icon with red dot badge, gear icon, user avatar on right.

### 2.2 — Admin Dashboard Screen

Route: `/admin/dashboard` — Reference: `admin_portal_dashboard/screen.png`.

Layout: Main content area, padding 24px all sides.

**Section 1 — Alert Banner** (conditional, shown when unlinked QR codes exist):
Full-width amber `#FFF3E0` banner, warning icon, text "Attention: X unlinked QR codes detected. Please assign them to boxes to maintain tracking integrity.", amber "Resolve" button on right. Read count from Firestore `qrBatches` collection where `linked < count`.

**Section 2 — Summary Cards Row** (4 cards in a Row, each Expanded):
Using the `SummaryCard` widget from Stage 1:
1. "Boxes in Storage" — icon: inventory_2, value from Firestore count query on boxes where status == 'in_storage', trend badge (+4%)
2. "Active Jobs Today" — count of jobs where scheduledDate is today and status != 'completed'/'cancelled', subtitle "Ongoing"
3. "Pending Pickups" — count of jobs where type=='pickup' and status=='scheduled', subtitle "High Priority" in red if > 3
4. "Pending Deliveries" — count of jobs where type=='delivery' and status=='scheduled', subtitle "Sch. Today"

Use `StreamProvider` with Firestore real-time listeners for all 4 counts.

**Section 3 — Today's Jobs Table + Recent Activity** (Row, 65% + 35% split):

Left: White card titled "Today's Jobs" with Filter button and "+ New Job" amber button.
Table columns: CLIENT, TYPE, DRIVER, TIME, STATUS, (actions).
- TYPE shown as a chip: amber "PICKUP" or navy "DELIVERY"
- DRIVER shown as circular avatar + name, or "--" + "Unassigned" greyed out
- STATUS: use `StatusChip` widget
- Row hover: `AppColors.surfaceContainer` background
- Tap row → navigate to job detail (future stage)
- Pagination: "Load more" or page numbers if > 10 rows

Right: "Recent Activity" white card, scrollable list of activity items. Each item: coloured dot (green/amber/red based on type) + bold event title + description + relative time (e.g. "2 mins ago"). Footer: "View Full Audit Log" outline button. Source: Firestore collection `activityLog` ordered by timestamp desc, limit 10.

**Section 4 — Quick Scan drawer:**
The navy "Quick Scan" sidebar button opens a right-side drawer/panel (400px wide). Panel shows: QR scanner widget (using `mobile_scanner`), scan result card below viewfinder showing box/item info when a QR is scanned. This reuses the scanner you'll build fully in Stage 3.

### 2.3 — Client Directory Screen

Route: `/admin/clients` — Reference: `admin_clients_list/screen.png`.

Page header: "Client Directory" (display headline), subtitle "Manage relationships and storage subscriptions for X clients.", "All Clients" filter dropdown on right, "Export" navy button.

**Clients table** (white card, full width):
Columns: CLIENT (avatar + name + ID), CONTACT INFO (email + phone), BOXES STORED (pill badge with count), STATUS (StatusChip), (3-dot menu).

Client avatar: circular, 40px. ID shown in grey below name (format: SB-XXXX).
Boxes stored: round navy badge with white number.
Status: Active (green), Past Due (amber-orange), Cancelled (red).
3-dot menu: opens popup menu with Edit, View Details, Send Message, Deactivate.

Pagination row: "Showing 1-X of Y clients" + prev/next + page number buttons.

Floating amber "+" FAB in bottom right → navigate to `/admin/clients/new` (simple form: name, email, phone, address, create Firestore doc + Firebase Auth user with role: 'client').

Data: `StreamProvider` on Firestore `clients` collection, join with `users` collection for contact info. Support search (client-side filter on name/email/ID string).

### 2.4 — Client Detail Screen

Route: `/admin/clients/:clientId` — Reference: `admin_client_detail/screen.png`.

**Breadcrumb:** "Inventory / Clients / [Name]" with back arrow.

**Header card:** Client circular avatar (80px, amber ring), name (22px bold), email icon + email, phone icon + phone, location icon + address. Right side: "Edit Profile" outline button + "New Job" amber button.

**Body — 2 column layout (left 35%, right 65%):**

Left column:
- **Subscription card:** "Subscription" heading, "Active" green chip top-right, "CURRENT PLAN" label, plan name bold (e.g. "Enterprise Vault Pro"), Status row ("Billed Monthly" with green dot + "Renewal Date" value), "Storage Capacity" label + progress bar (amber fill, show XX% and "X of Y units used"), "Manage Billing" dark navy button (links to Stripe billing portal URL from user's `stripePortalUrl` field).
- **Logistics Insight card:** Navy dark card, amber gear/insight icon, "Logistics Insight" amber heading, AI-generated or admin-written insight text in white/80.

Right column:
- **Stored Inventory card:** "Stored Inventory" heading, "Active boxes under custody" subtitle, filter search input + filter icon. Grid of box cards (3 columns): each shows photo, box ID (SBX-XXXX-X format), label below, zone badge chip (amber), arrow →. "View All X Boxes" link at bottom.
- Clicking any box card → `/admin/inventory/:boxId`

**Job History section** (below the 2 columns, full width):
"Job History" heading, "Export CSV" link, "View All Jobs" navy button.
Table: REFERENCE, SERVICE TYPE, STATUS, DATE, COST, ACTION (document icon).

All data sourced from Firestore with `clientId` filter.

## --- STAGE 2 END ---

---

## --- STAGE 3 START ---

## Stage 3 — Admin Inventory, Box Detail & QR Management

Stage 2 (Admin shell, dashboard, client screens) is complete. Now build inventory management and the QR system.

### 3.1 — All Inventory Screen

Route: `/admin/inventory` — Reference: `admin_all_inventory/screen.png`.

Page header: "Inventory" (display), subtitle "Managing X active boxes in the ecosystem.", "+ Add Box" amber button top-right.

**Filter row:** "All Clients" dropdown (left), then status toggle pills: "All Status" (active/selected = navy fill white text), "In Storage", "In Transit", "Pending", then "Type" dropdown (All / Closed Box / Open Box).

**Grid** (4 columns desktop, 2 tablet, 1 mobile): Use `BoxCard` widget from Stage 1.
Each card:
- Photo thumbnail (160px tall, cover fit, 12px top radius)
- Status badge overlay on photo top-left: pill chip on navy bg ("IN STORAGE" / "IN TRANSIT" / "PENDING")
- QR icon or truck icon overlay on photo bottom-right (small navy circle)
- Box ID in bold (SBX-XXXX-X format), 14px
- Client name in grey, 12px
- Type badge: "CLOSED BOX" (grey pill) or "OPEN BOX" (amber pill), + last-updated timestamp
- Tap → `/admin/inventory/:boxId`

Last card in grid: Dashed border "Add New Box" card with `+` amber circle icon, "Add New Box" label, subtitle "Quickly register a new container into the system." Tap → opens Add Box bottom sheet/dialog.

**Add Box dialog:** Modal with fields: Client (dropdown), Box Type (Closed/Open toggle), Label (text), Photo upload zone. On save: generate UUID as qrCode, write to Firestore `boxes`, navigate to the new box detail.

**Load More** button at bottom (grey pill) — loads next 20 boxes (Firestore pagination with `startAfterDocument`).

Data: `StreamProvider` with real-time Firestore query. Filter state managed by a `StateProvider` (selected client, status, type).

### 3.2 — Box Detail Screen

Route: `/admin/inventory/:boxId` — Reference: `admin_box_detail/screen.png`.

**Top bar:** "Inventory > Box #[ID]" breadcrumb. Page title "Storage Unit #[ID]". Three action buttons: "Edit Label" (outline), "Print QR" (navy with printer icon), "Archive" (red outline with archive icon).

**Body — 2 column (65% left, 35% right):**

Left column:
- **Inspection Photos card:** "Inspection Photos" heading, "+ Add New" amber text button. Horizontal scrollable row of photo thumbnails (150px × 120px, 8px radius, cover fit). Tap to open full-screen lightbox. First photo is main.
- **Items Inside section** (only shown if type == 'open'): "Items Inside" heading. 2-column grid of item cards. Each item card: photo thumbnail (80px square), item name bold, Qty + Serial/description, status chip (FUNCTIONAL / STOCKED etc). "+ Add Item" ghost button card at end.

Right column:
- **QR Code card:** White card, QR code image centred (using `qr_flutter`, 160px, navy dots). Box ID text below in bold. Status chip (e.g. "In Transit: Route 44"). Fields: Unique ID, Created Date, Owner (for now shows "Warehouse"), Security Seal (Verified chip in green).
- **"Need an Update?" navy card:** QR icon, "Need an Update?" heading, subtitle, "Open Mobile Scanner" amber button.

**Job History section** (full width below): Timeline list. Each entry: amber circle dot (for current/latest) or navy dot, event title bold, subtitle (operator + location), timestamp right-aligned. Events: "Loaded onto Fleet", "Quality Inspection Passed", "Box Sealed and Registered", etc from Firestore `jobs` where this boxId appears.

**Print QR action:** Opens a print preview dialog using the `pdf` + `printing` packages. Print template: white label card (85mm × 54mm), QR code centred, "StrongBox" logo top, box ID below QR, label text at bottom.

### 3.3 — QR Management Screen

Route: `/admin/qr` — Reference: `admin_qr_management/screen.png`.

Page title: "QR Codes Management", subtitle "Streamline asset tracking by generating batch labels or linking hardware to specific logistics containers."

**Two tabs:** "Generate Batch" (active, amber underline) | "Link QR to Box"

**Tab 1 — Generate Batch:**

Left panel (white card, 40% width):
- "Batch Settings" heading
- "Number of Labels" label + stepper input (minus button, number, plus button) — range 1–100
- "Print Resolution" dropdown: "High (300 DPI)", "Standard (150 DPI)"
- "Generate & Print PDF" dark navy button with printer icon

Right panel (white card, 60% width):
- "Preview Grid" heading, "Ready for Export" green badge top-right
- 4×3 grid of QR label previews (each ~120px square): QR code image + ID text below (format: SBX-XXXX-XX)
- QR codes generated using `qr_flutter`, IDs generated as UUIDs shortened to SBX-format

On "Generate & Print PDF":
1. Generate N UUIDs formatted as SBX-XXXX-XX
2. Build a PDF using the `pdf` package: A4 page, 4-column grid of label boxes, each with QR code image + ID text
3. Write a `qrBatches` document to Firestore: `{count: N, codes: [...], createdAt, createdBy, linked: 0}`
4. Open print dialog using `printing` package's `Printing.layoutPdf()`

**Tab 2 — Link QR to Box:**

Full-width scanner section: camera viewfinder rectangle (amber corner brackets) with "Scanning..." animated text, OR text input "Enter QR code ID manually" below.

When QR/ID entered:
- Check if ID exists in `boxes` (already linked) → show error
- If unlinked: show "Client" dropdown + "Assign to" radio (New box / Existing box)
  - New box: show box type + label fields
  - Existing box: show box search/dropdown
- "Confirm Link" amber button → update Firestore box doc with the qrCode value, increment `linked` count in the qrBatch doc

## --- STAGE 3 END ---

---

## --- STAGE 4 START ---

## Stage 4 — Admin Jobs, Fleet & Supporting Admin Screens

Stage 3 (Inventory + QR) is complete. Now build the Jobs workflow, Fleet management, Reports, and Notifications screens.

### 4.1 — Jobs List Screen

Route: `/admin/jobs` — Reference: `admin_jobs_list/screen.png`.

Header: "Jobs List" + global search (pre-filled from query param). "+ New Job" amber button top-right.

**Filter bar** (white card row): Job Type toggle (All / Pickup / Delivery — styled as outlined pill buttons, active fills navy), Status dropdown, Date Range picker (shows "Oct 24 - Oct 31, 2023" format), Driver dropdown, filter icon button.

**Jobs table** (white card):
Columns: JOB ID, CLIENT, TYPE, SCHEDULED DATE, DRIVER (avatar + name), STATUS (StatusChip), ACTIONS.
- JOB ID: bold, e.g. `#JB-9042`
- TYPE chip: amber bg "DELIVERY" or grey bg "PICKUP"
- DRIVER: circular avatar (32px) + name, or "--" Unassigned greyed
- ACTIONS: "View" outline button
- Row tap → job detail (build in a later sub-stage or show a bottom sheet)
- Pagination: "Showing 1-X of Y jobs" + page controls

Data: Firestore `jobs` collection, StreamProvider with composite filters. Use Firestore indexes as needed.

### 4.2 — Create New Job — 4-Step Flow

Route: `/admin/jobs/new` — References: steps 1–4 screens.

Use `StepIndicator` widget (from Stage 1) at top showing: 1 Type → 2 Items → 3 Schedule → 4 Confirm. Steps connected by a line; completed steps = amber filled circle + checkmark, active = amber outlined circle + number.

Manage state with a Riverpod `StateNotifier` (`NewJobNotifier`) holding: `{type, clientId, selectedBoxIds, selectedItemIds, scheduledDate, timeWindow, driverId, notes}`.

**Step 1 — Type** (Reference: `admin_create_new_job_step_1/screen.png`):
Two large selection cards side by side:
- "Pickup Request" — forklift icon on navy circle, description + 2 feature bullets. Unselected: white card with grey border.
- "Delivery Request" — truck icon on amber circle, description + 2 feature bullets. Selected state: amber border + amber checkmark top-right.
Below: "Estimated Efficiency" info card (image + text + "OPTIMAL FLOW" green chip) + "Rush Processing" amber card (lightning icon).
Bottom bar: "× Cancel Job" text button (left) + "Next Step →" amber button (right, disabled until type selected).

**Step 2 — Items** (Reference: `admin_create_new_job_step_2/screen.png`):
"Client Account" dropdown (full width) with "Active Contract" green badge on right when client selected.
"Select All Items" checkbox + "Showing X items" count.
Grid of box/item cards (2 columns): photo, label, category, zone badge top-right, status chip (READY/IDLE). Checkbox overlay top-left — tap to select. Selected cards: amber border.
Right sidebar (fixed, 280px): "Job Summary" dark navy card. "Selected Items" count in amber, bullet list of selected item names + categories. "Requirement Note" info box (if any fragile items). "Next Step: Logistics →" amber button + "Back to Details" navy outline button.

**Step 3 — Schedule** (Reference: `admin_create_new_job_step_3_schedule/screen.png`):
White card, title "Job Schedule & Assignment".
- "Scheduled Date" label + date picker input (calendar icon, formatted MM/DD/YYYY)
- "Time Window" dropdown (Morning 08:00–12:00, Afternoon 12:00–16:00, Evening 16:00–20:00)
- Lead time hint text below date
- "Driver Assignment" dropdown (loads available drivers from Firestore) + "DRIVER STATUS" green badge "Fully Certified"
- "Dispatch Notes & Special Instructions" multiline TextFormField (placeholder: "Enter gate codes, special handling instructions...")
- Bottom: "← Back to Items" text button, "Save as Draft" outline button, "Review & Confirm →" amber button
- Below form: "ROUTE OPTIMIZATION" info card + driver capacity card

**Step 4 — Confirm** (Reference: `admin_create_new_job_step_4_confirm/screen.png`):
Left (main): "Job Overview" white card with "Edit All" amber link. Job type + icon, Origin & Destination. "Cargo & Items" section with table: ITEM DESCRIPTION, WEIGHT, HAZARDOUS, with total badge.
Right sidebar: "Assignment" dark navy card — SCHEDULED PICKUP date/time, ASSIGNED DRIVER with avatar + ID. "ESTIMATED SERVICE FEE" card with total + breakdown (Base Route Fee, Fuel Surcharge, Weight Premium) + discount badge.
Bottom: "Submit Job →" amber button + "Save as Draft" outline button.

On Submit: Write `jobs` document to Firestore, update box statuses to `pending_pickup` or `pending_delivery`, navigate back to `/admin/jobs`.

### 4.3 — Fleet / Drivers Screen

Route: `/admin/fleet` — Reference: `admin_drivers_fleet/screen.png`.

**Summary row** (4 cards, no icons): TOTAL DRIVERS (large number + "+12 this month" green badge), AVAILABLE (green border card), ON JOB (amber number), AVG. RATING (gold star + number).

**Active Fleet Registry table** (white card):
"Filter" outline button + "Export" outline button top-right.
Columns: AVATAR, NAME, PHONE, STATUS (Available green chip / On Job amber chip), ACTIVE JOB ID (amber link or "--"), LOCATION, ACTIONS (View + Edit buttons).
Pagination.
Amber `+` FAB bottom-right → Add Driver dialog (name, email, phone → create Firebase Auth user with role:'driver', write Firestore user doc).

### 4.4 — Driver Detail Screen

Route: `/admin/fleet/:driverId` — Reference: `admin_driver_detail_view/screen.png`.

Header card: Driver avatar (80px, green "Available" status chip overlay), name, role + tenure, email, phone. "Edit Profile" navy outline button + "Assign to Job" amber button + "Send Message" outline button. Right: "ASSIGNED VEHICLE" card with vehicle name + ID + "Maintenance Status: Healthy" + "View Logs" link.

3 stats cards: Average Rating (⭐ 4.92), On-time Rate (98.5%), Jobs Completed (1,248).

"Active Assignment" navy card: if assigned shows job info; if not shows "Waiting for Assignment" empty state with "Open Dispatch Board" amber button.

"Compliance" card: List of certifications (CDL License, Hazmat Endorsement, Medical Certificate, D.O.T. Physical) each with green checkmark or amber warning icon + expiry date.

"Recent History" table: JOB ID, DATE, CLIENT, ROUTE, RATING (stars), STATUS chip. "View All →" link.

### 4.5 — Notifications Screen

Route: `/admin/notifications` — Reference: `admin_notifications_alerts_center/screen.png`.

3-column layout:

Left (250px, navy): "Notifications" heading. Category list: "All Notifications" (with unread count badge), "Critical Alerts" (red badge), "Operational" (amber badge), "System". Divider. "RECENTS" section with 2 latest items (coloured dot + text). Bottom: "Fleet Sync Active" dark info card.

Centre (scrollable): "Inbox" heading + count + Latest/Oldest toggle + "Mark all as read" + Filter.
Notification cards — each has: coloured left border (red=critical, amber=operational, grey=system), icon, bold title, description text, timestamp + unread red dot. Action buttons per card (e.g. "View Job" + "Contact Driver" + delete icon, or "Review Documents" + "Assign Manager" + checkmark).

Right (280px): "Operational Health" card with stat bars (Active Fleet %, Avg Latency, Jobs Today). "Need Assistance?" dark navy card with "Call Dispatch" amber button.

### 4.6 — Reports Screen

Route: `/admin/reports` — Reference: `admin_reports_analytics_dashboard/screen.png`.

Header: "Reports & Analytics", "Last 30 Days" date-range dropdown. "Export CSV" outline button + "Generate PDF" amber button.

**Monthly Job Volume** chart (white card, ~60% width): Bar chart using `fl_chart`. Bars in amber, target bars in light amber/cream. Legend: "● Current ● Target". X-axis: month labels.

**Revenue Growth** card (dark navy, ~38% width): "+14.2%" green badge, large revenue number, subtitle "Total Revenue (Q2)", mini bar chart in white/grey.

**Fleet Efficiency** (white card, ~35%): Circular progress chart (85% utilisation, amber arc, navy remaining). Stats below: Active Vehicles X/Y, On-Time % XX.X.

**Top Clients by Volume** table (white card, ~63%): CLIENT NAME (avatar letter + name), STORAGE VOLUME, JOBS MTD, REVENUE, ACTION (3-dot). "View All" amber link.

## --- STAGE 4 END ---

---

## --- STAGE 5 START ---

## Stage 5 — Driver Portal (Mobile-First)

Stage 4 (all Admin screens) is complete. Now build the complete Driver portal. The driver app is designed mobile-first — all screens reference mobile designs from the Stitch folder.

### 5.1 — Driver Shell

Create `lib/features/driver/widgets/driver_shell.dart`.

Bottom navigation bar (always visible): 4 tabs: Home/Jobs (receipt_long icon), Scan (qr_code_scanner), Inventory (inventory_2), Account (person). Active tab: amber filled pill background around icon + amber label. Inactive: navy icon + grey label. Background: white. Shadow above.

Some screens also show a "Shift" tab — make this 5 tabs when driver has an active shift: Home, Jobs, Scan, Shift, Account.

Top bar: "StrongBox" text left (navy bold), notification bell right, user avatar right. No sidebar.

Scaffold background: `#F5F2FF`.

### 5.2 — Driver Jobs List

Route: `/driver/jobs` — Reference: `driver_portal_jobs/screen.png`.

"Active Jobs" heading, "Route: Sector 7G • Truck 402" subtitle in grey.

**Today / Upcoming** toggle tabs (segmented button, full width, white background, navy active).

**Job cards** (stacked, each in a white card with 12px radius and shadow):
- Top row: Type chip (amber "Pickup" or green "Delivery") left, time bold right + "Stop #X" grey below
- Client name (18px Bold, navy)
- Location row: pin icon + address
- Divider
- Box count (box icon + "X Boxes") left, status chip right ("In Transit" amber dot / "Pending" grey)
- For the active/in-progress card: "Start Navigation" dark navy full-width button with diamond nav icon

Between cards: Navy promo card: amber QR icon, "Ready to scan? Sync with warehouse in one tap."

Floating amber QR scanner FAB (bottom right, 56px circle with QR icon).

Data: Firestore `jobs` where `driverId == currentUser.uid` and `scheduledDate` is today, ordered by scheduledDate.

### 5.3 — Driver Job Detail

Route: `/driver/jobs/:jobId` — Reference: `driver_job_detail/screen.png`.

Back arrow + "Job Details" title. Bell + gear icons right.

**Header:** Client/destination name (22px Bold), "EXPRESS DELIVERY" or job-type chip (green pill). Full address (2 lines). "Open in Maps" amber text + map icon link (opens platform maps URL).

**"MANIFEST ITEMS (X)" section header** with Filter button.

**Item rows** (white cards, stacked):
Each: photo thumbnail (80px square, 8px radius), box ID bold + description + weight, QR ID amber chip below. Status chip right: "Loaded" (green with checkmark), "Pending" (grey clock), "Delivered" (green strikethrough on ID).

Delivered items: box ID has strikethrough styling.

**"Start Job" amber button** (full width, 56px, arrow play icon) — pinned at bottom. When tapped: update job status to `in_progress` in Firestore, button changes to "Confirm Each Box" mode — each item row gets a [Scan QR] button that opens the scanner.

**Per-box actions** (shown after job starts): Each item row gets two icon buttons: QR scan icon (opens scanner for this box) + camera icon (opens photo capture).

Bottom nav remains visible.

### 5.4 — QR Scanner Screen

Route: `/driver/scan` (also navigated to from job flow) — Reference: `driver_qr_scanner/screen.png`.

Full-screen dark background. Top bar: X close button (left), lightning bolt flash toggle (centre-right), ? help button (right) — all in dark circle buttons.

**Viewfinder:** Centred rectangle (260px × 200px). Four corner brackets in amber (L-shaped, 3px stroke). "SCANNING..." amber pulsing text below brackets. "Align the QR code within the frame" grey hint.

**"Enter Tracking Number Manually"** white underlined link below the viewfinder.

On successful scan: slide-up bottom sheet (white, 20px top radius):
- "VERIFIED" green chip + box ID bold
- Item name (18px Bold), "Client: [Name]"
- Two stat chips side by side: Weight (value), Route/Zone (value)
- "Confirm Pickup" OR "Confirm Delivery" amber full-width button (context-aware based on current job type)

On tap Confirm:
- If in a job flow: update that box's status in Firestore, mark as loaded/delivered on the job
- Standalone scan: show box detail info, allow status update

Use `mobile_scanner` package with `MobileScannerController`. Handle permissions.

### 5.5 — Photo Capture Screen

Navigated from job detail — Reference: `driver_photo_capture/screen.png`.

Title bar: "JOB #XXXX-X" bold + "Cargo Verification" subtitle. X close + ? help.

**Camera preview** (full screen, dark bg). Amber focus rectangle overlay centred ("FOCUS" label top and bottom of rectangle). "Center cargo inside the frame" instruction text.

Camera controls at bottom: flash button (lightning) + capture button (large white circle, 64px) + flip camera button.

**Photo strip:** Horizontal row of thumbnails (60px square each) showing captured photos. "X / 4 Photos" count. Empty slots shown as dashed grey squares.

**"Confirm Capture" bottom sheet** (after taking photo):
"Confirm Capture" heading, "Ensure the label and cargo condition are clearly visible before proceeding."
Preview of last captured photo (full width, 200px tall, 8px radius).
"Retake" navy outline button + "Use Photo" amber button (with checkmark).

On "Use Photo": upload image to Firebase Storage at `jobs/{jobId}/photos/{boxId}/{timestamp}.jpg`, store URL in Firestore job doc.

Use `image_picker` for camera + gallery access. Handle web vs mobile differences (on web, use file picker).

### 5.6 — Client Sign-Off Screen

Route: from job completion flow — Reference: `driver_client_sign_off/screen.png`.

"← Job complete — get client confirmation" heading (large, 24px Bold, navy).

**"Confirmation Method" section:** Two selection cards side by side:
- "Digital Signature" (pen icon, "Sign on screen") — selected state: amber border
- "Send OTP" (message icon, "Verify via mobile") — unselected

**Signature pad** (shown when Digital Signature selected):
White area (full width, 200px tall, light purple-grey bg `#EFECFF`, 12px radius). "Client Signature" label + "Clear" button with clock icon top-right. Pencil icon + "Signature required here" greyed placeholder. Use `signature` package for drawing. On first touch, placeholder disappears.

**Order summary card:** Box icon, "Order #SB-XXXX" + item name.

**"Confirm Signature ✓" amber button** (full width).

On confirm:
1. Convert signature to PNG bytes, upload to Firebase Storage
2. Update job doc: `clientSignatureUrl`, `status: 'completed'`, `completedAt: now()`
3. Update all box statuses in the job to 'delivered' (for delivery jobs) or 'in_storage' (for pickup jobs)
4. Show success animation, navigate back to driver jobs list

### 5.7 — Driver Profile & Account

Route: `/driver/account` — Reference: `driver_profile_stats/screen.png`.

Light gradient header (top 40% of screen, light peach/amber gradient bg). Centred avatar (100px, amber ring border). Name (20px Bold), phone below.

**"TODAY'S PERFORMANCE" section:**
Two stat cards side by side (white, 8px radius):
- "Jobs Completed" — large number, "+12% " green badge top-right, label below
- "Boxes Handled" — large number, "Target" amber badge top-right, label below

**Settings list** (white card, stacked rows with dividers):
- Shift History (schedule icon, navy icon bg)
- Vehicle Inspection (truck icon)
- E-Identification (badge icon)
Each row: icon (navy bg, white icon, 8px radius) + label + ">" chevron.

**"Log Out" navy full-width button** (48px, arrow-right icon).

### 5.8 — Shift Management & E-ID Screen

Route: `/driver/shift` — Reference: `driver_shift_management_id/screen.png`.

**"Shift Status" heading** + "● Active Now" green text right.

**Elapsed time card** (dark navy, 12px radius): "ELAPSED TIME" label, large monospaced timer (HH:MM:SS) — use `Timer.periodic` for live update. "End Shift" red button + "Break" grey outline button.

**E-Identification card** (white, 12px radius): Driver photo (80px square) + name + "Employee ID: SB-XXXX-X" + "Clearance: Level X" amber chip. Dashed amber-bordered QR code card below (the driver's personal QR code for facility gate access). "Present this code at Gate Sensors or Security Terminals for facility access." instruction.

**Vehicle card** (white): truck icon (navy bg) + vehicle name + VIN + fuel/battery % with green progress bar.

**"Emergency Contact" amber button** (full width, asterisk/star icon).

### 5.9 — Report Issue Screen

Route: from driver account — Reference: `driver_report_issue_maintenance/screen.png`.

"← Report Issue" title bar.

"MAINTENANCE & SUPPORT" label, subtitle.

Form fields:
- "Issue Type" dropdown: "Select an issue category..." (options: Vehicle Breakdown, Cargo Damage, Delivery Failed, Safety Concern, Other)
- "Description of Issue" multiline TextFormField (placeholder: "Describe the situation in detail...")
- "Attach Evidence" section: dashed "Add Photo" zone + captured photo thumbnails + "Scan Asset Tag" amber box (opens QR scanner)
- "Urgent Assistance Required" toggle row: label + subtitle + Switch

"Submit Report → " amber full-width button.

Footer text: "All reports are logged with your GPS location and timestamp for safety auditing."

On submit: Write to Firestore `issueReports` collection with all data + userId + timestamp.

## --- STAGE 5 END ---

---

## --- STAGE 6 START ---

## Stage 6 — Architecture Audit + Client Portal + Quotation Flow

> **IMPORTANT: Read these docs before writing a single line of code:**
> - `CLAUDE.md` — project overview and "Do Not" rules
> - `docs/07_FLUTTER_ARCHITECTURE.md` — repository pattern, freezed, folder structure
> - `docs/09_REPOSITORIES.md` — all repository interfaces
> - `docs/10_DESIGN_SYSTEM.md` — AppColors, AppSpacing, AppRadius
> - `docs/11_COMPONENT_LIBRARY.md` — all shared widgets (check before building new ones)
> - `docs/15_CLIENT_PORTAL.md` — full client portal feature spec
> - `docs/23_BILLING.md` — Stripe billing spec
> - `docs/25_AI_DEVELOPMENT_RULES.md` — all 37 non-negotiable rules
>
> **All client design PNGs live at:**
> `/Users/Bunny/Tools/strong_box/designs/client_designs/{screen_name}/screen.png`
>
> **Full screen index (read each PNG before implementing its screen):**
> ```
> Quote flow:        quick_storage_calculator, add_loose_item_modal,
>                    quote_select_boxes, quote_loose_items,
>                    quote_packing_pickup, quote_summary, quote_confirmation
>
> Dashboard:         client_dashboard, dashboard_overview
> Storage:           my_storage_inventory, unit_details_sbx_9942_a1,
>                    unit_details_confirm_delivery_request, unit_details_out_for_delivery
> Requests:          request_delivery_step_1
> Billing:           subscription_billing
> Account:           account_settings, notification_preferences
>
> Mobile variants:   mobile_dashboard_home, mobile_my_storage, mobile_unit_details,
>                    mobile_request_delivery, mobile_request_step_1,
>                    mobile_confirm_delivery, mobile_out_for_delivery,
>                    mobile_account_settings, mobile_notification_preferences,
>                    mobile_subscription_billing
> ```

---

### 6.0 — Architecture Audit (Run This First)

Before building anything new, audit all code from Stages 1–5. Fix every violation before proceeding.

**Run these greps and fix every result:**
```bash
# 1. No direct Firestore access outside repositories
grep -r "FirebaseFirestore.instance" lib/features/ lib/routing/

# 2. No raw hex colours
grep -r "Color(0x" lib/features/ lib/core/widgets/

# 3. No plain Dart model classes (should all be @freezed)
grep -r "class BoxModel\|class JobModel\|class AppUser" lib/ --include="*.dart" | grep -v "freezed\|part"

# 4. No .delete() on Firestore docs
grep -r "\.delete()" lib/
```

**Fix list:**
1. Convert every plain model to `@freezed` + `json_serializable`. Run `dart run build_runner build --delete-conflicting-outputs` after.
2. Rename `BoxModel → StorageUnit`, `boxes collection → storageUnits`, `boxId → unitId`, `BoxCard → StorageUnitCard`, route param `:boxId → :unitId` everywhere.
3. Every Firestore query must include `where('tenantId', isEqualTo: 'strongbox-default')` and `where('isDeleted', isEqualTo: false)`.
4. Replace `.delete()` with `{isDeleted: true, deletedAt: serverTimestamp()}` updates.
5. Every status change must write an `AuditEvent` in the same Firestore transaction.

**Update `pubspec.yaml`** — add if missing:
```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  image: ^4.1.7

dev_dependencies:
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

**Update `lib/core/constants/firestore_collections.dart`:**
```dart
class Collections {
  static const tenantId    = 'strongbox-default';
  static const users       = 'users';
  static const clients     = 'clients';
  static const storageUnits = 'storageUnits';  // renamed from 'boxes'
  static const items       = 'items';
  static const jobs        = 'jobs';
  static const qrCodes     = 'qrCodes';
  static const qrBatches   = 'qrBatches';
  static const auditEvents = 'auditEvents';
  static const notifications = 'notifications';
  static const boxTypes    = 'boxTypes';       // NEW — admin-configured
  static const looseItemTemplates = 'looseItemTemplates'; // NEW — catalogue
  static const vehicles    = 'vehicles';       // NEW — admin-configured
  static const quotes      = 'quotes';         // NEW — quotation flow
}
```

Verify `flutter run -d chrome` compiles cleanly before proceeding.

---

### 6.1 — New Freezed Models for Quotation System

Create these in `lib/features/quote/models/`:

**`box_type.dart`** — admin-configured box sizes (never hardcoded):
```dart
@freezed
class BoxType with _$BoxType {
  const factory BoxType({
    required String id,
    required String tenantId,
    required String name,          // 'Small', 'Medium', 'Large', 'XL'
    required String description,
    required double lengthCm,
    required double widthCm,
    required double heightCm,
    required double maxWeightKg,
    required double monthlyPriceRand,
    required String? iconUrl,
    @Default(true) bool isActive,
    @Default(false) bool isDeleted,
  }) = _BoxType;
  factory BoxType.fromJson(Map<String, dynamic> json) => _$BoxTypeFromJson(json);

  // Computed
  double get volumeM3 => (lengthCm * widthCm * heightCm) / 1000000;
}
```

**`loose_item_template.dart`** — the item catalogue:
```dart
@freezed
class LooseItemTemplate with _$LooseItemTemplate {
  const factory LooseItemTemplate({
    required String id,
    required String tenantId,
    required String name,          // 'Dining Table', 'Bicycle', etc.
    required String category,      // 'Beds', 'Tables', 'Office', 'Appliances', 'Outdoor', 'Other'
    required String emoji,         // '🪑', '🛏', etc.
    required double defaultLengthCm,
    required double defaultWidthCm,
    required double defaultHeightCm,
    @Default(false) bool isDeleted,
  }) = _LooseItemTemplate;
  factory LooseItemTemplate.fromJson(Map<String, dynamic> json) => _$LooseItemTemplateFromJson(json);

  double get defaultVolumeM3 => (defaultLengthCm * defaultWidthCm * defaultHeightCm) / 1000000;
}
```

**`vehicle.dart`** — admin-configured pickup vehicles:
```dart
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    required String tenantId,
    required String name,          // 'Small Van', 'Medium Van', 'Large Truck'
    required String capacityLabel, // 'Up to 1 m³'
    required double maxVolumeM3,
    required double pickupFeeRand,
    required String emoji,
    @Default(false) bool isDeleted,
  }) = _Vehicle;
  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
```

**`quote.dart`** — the full quote:
```dart
@freezed
class Quote with _$Quote {
  const factory Quote({
    required String id,
    required String tenantId,
    String? clientId,              // null = anonymous/pre-login quote
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    required List<QuoteBoxLine> boxes,
    required List<QuoteLooseItemLine> looseItems,
    String? vehicleId,
    required double vehicleFeeRand,
    @Default(false) bool needsPacking,
    @Default(2) int packingHelpers,
    @Default(3) int packingHours,
    required double packingHourlyRateRand,
    required QuoteStatus status,  // draft | sent | accepted | expired
    String? referenceNumber,      // 'SBQ-2024-0847'
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? expiresAt,
    @Default(false) bool isDeleted,
  }) = _Quote;
  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  // Computed totals
  double get monthlyStorageTotal => boxes.fold(0, (s, b) => s + b.lineTotal);
  double get packingTotal => needsPacking ? packingHelpers * packingHours * packingHourlyRateRand : 0;
  double get dueTodayTotal => vehicleFeeRand + packingTotal;
  double get estimatedVolumeM3 => boxes.fold(0, (s, b) => s + b.volumeM3) +
      looseItems.fold(0, (s, i) => s + i.volumeM3);
}

@freezed
class QuoteBoxLine with _$QuoteBoxLine {
  const factory QuoteBoxLine({
    required String boxTypeId,
    required String boxTypeName,
    required int quantity,
    required double unitPriceRand,
    required double volumeM3Each,
  }) = _QuoteBoxLine;
  factory QuoteBoxLine.fromJson(Map<String, dynamic> json) => _$QuoteBoxLineFromJson(json);

  double get lineTotal => quantity * unitPriceRand;
  double get volumeM3 => quantity * volumeM3Each;
}

@freezed
class QuoteLooseItemLine with _$QuoteLooseItemLine {
  const factory QuoteLooseItemLine({
    required String name,
    required String category,
    required String emoji,
    required double lengthCm,
    required double widthCm,
    required double heightCm,
    required int quantity,
    @Default(true) bool isFromCatalogue,
    String? customDescription,
  }) = _QuoteLooseItemLine;
  factory QuoteLooseItemLine.fromJson(Map<String, dynamic> json) => _$QuoteLooseItemLineFromJson(json);

  double get volumeM3 => (lengthCm * widthCm * heightCm * quantity) / 1000000;
}
```

After creating all models, run `dart run build_runner build --delete-conflicting-outputs`.

---

### 6.2 — New Routes

Add to `lib/routing/app_router.dart`:
```dart
// Public routes — no auth required
GoRoute(path: '/calculator', builder: (_, __) => const QuickCalculatorScreen()),

// Quote flow — accessible before login; auth required to accept
GoRoute(
  path: '/quote',
  builder: (_, __) => const QuoteFlowScreen(),
  routes: [
    GoRoute(path: ':quoteId/confirmation', builder: (_, state) =>
        QuoteConfirmationScreen(quoteId: state.pathParameters['quoteId']!)),
  ],
),

// Client portal — auth required
// Update existing /client/storage/:boxId → /client/storage/:unitId
```

---

### 6.3 — Client Shell

**Read designs:** `client_dashboard/screen.png` and `mobile_dashboard_home/screen.png`

Create `lib/features/client/widgets/client_shell.dart`:

```dart
class ClientShell extends StatelessWidget {
  final Widget child;
  const ClientShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900) return _DesktopClientShell(child: child);
      return _MobileClientShell(child: child);
    });
  }
}
```

**Desktop (>900px):** White top nav, 64px, `AppColors.border` bottom border.
- Left: amber box icon 32px + "StrongBox" 18px Bold navy
- Centre: nav links 16px SemiBold — Dashboard · My Storage · Deliveries · Billing. Active = 3px amber bottom underline.
- Right: notification bell (red badge from `unreadCountProvider`) + avatar 36px circle
- Page content on `AppColors.scaffold`

**Mobile:** White `AppBar` ("StrongBox" navy bold + bell icon) + `BottomNavigationBar` (Home · Storage · Requests · Account). Active tab: amber icon + amber label.

---

### 6.4 — Quick Calculator (Public — No Login)

**Read design:** `quick_storage_calculator/screen.png`

Route: `/calculator` — accessible to anyone, no auth guard.

**Pricing engine provider (data-driven from Firestore):**
```dart
@riverpod
Stream<List<BoxType>> activeBoxTypes(ActiveBoxTypesRef ref) {
  return FirebaseFirestore.instance
      .collection(Collections.boxTypes)
      .where('tenantId', isEqualTo: Collections.tenantId)
      .where('isActive', isEqualTo: true)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.map((d) => BoxType.fromJson(d.data())).toList());
}

@riverpod
Stream<List<Vehicle>> activeVehicles(ActiveVehiclesRef ref) { ... }

@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  CalculatorState build() => CalculatorState(
    boxQuantities: {},   // Map<boxTypeId, int>
    looseItems: [],
    selectedVehicleId: null,
    needsPacking: false,
    packingHelpers: 2,
    packingHours: 3,
  );

  void incrementBox(String typeId) { ... }
  void decrementBox(String typeId) { ... }
  void addLooseItem(QuoteLooseItemLine item) { ... }
  void removeLooseItem(int index) { ... }
  void selectVehicle(String vehicleId) { ... }
  void togglePacking(bool value) { ... }
  void setPackingHelpers(int n) { ... }
  void setPackingHours(int n) { ... }

  // Computed — reads from boxTypes + vehicles providers
  double get monthlyTotal { ... }
  double get dueTodayTotal { ... }
  double get estimatedVolumeM3 { ... }
}
```

**Layout:** `LayoutBuilder` — desktop is side-by-side (left 60% controls + right 40% sticky navy summary panel). Mobile is single column with summary card at bottom.

**Left panel — "Quick Storage Calculator":**

Section "Storage Boxes":
- One row per active `BoxType` (loaded from `activeBoxTypesProvider`)
- Row: amber icon circle + box name bold + "R{price}/month" caption + `[-][qty][+]` stepper right
- Prices and names come entirely from Firestore — never hardcoded

Section "Loose Items":
- If empty: "No items added yet" grey italic
- Each added item: emoji + name + volume caption + trash icon
- "+ Add Loose Item" amber ghost button → opens `AddLooseItemModal`

Section "Pickup Vehicle":
- Load from `activeVehiclesProvider`
- 3 radio cards in a row: selected = amber 2px border + amber radio dot
- Each: emoji + name + price + capacity label

Section "Packing Service":
- Two radio options: "No, I'll pack myself" / "Yes, I need help"
- If Yes: packers stepper + hours stepper. Show "Min 3 hours" amber caption. Show live "Est. R{total}" calculation.

**Right panel (navy, sticky, desktop only):**
- "Price Estimate" white bold
- Line items: box lines + loose items + vehicle + packing (all computed live)
- "Monthly Storage" white/70 label + large white value
- "Due Today" white/70 + amber bold value (vehicle + packing)
- Volume bar: amber progress on dark track + "X m³ estimated"
- Volume grid: 4×2 squares (amber filled = used, white outline = empty), scale to `estimatedVolumeM3`
- "Continue to Full Quote →" amber PrimaryButton

**Mobile summary card** (white, 12px radius, shadow — pinned at bottom of scroll):
- Monthly: "R{monthly}" navy bold + "Due Today: R{today}" caption
- "Continue to Full Quote →" amber button full-width

All values update instantly using `ref.watch(calculatorNotifier)` — no submit button needed for the calculation.

---

### 6.5 — Add Loose Item Modal

**Read design:** `add_loose_item_modal/screen.png`

Opened from the Quick Calculator and from the Quote loose items step.

Create `lib/features/quote/widgets/add_loose_item_modal.dart`:

```dart
Future<QuoteLooseItemLine?> showAddLooseItemModal(BuildContext context) {
  return showModalBottomSheet<QuoteLooseItemLine>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => const AddLooseItemModal(),
  );
}
```

**Modal content (480px max width, centred on desktop as dialog):**
- "Add Loose Item" 18px Bold + X close button
- `AppSearchBar` — searches `looseItemTemplatesProvider` in real time
- "Popular Items" caption + 3×3 chip grid (pill, `#C5C6CF` border): loads from Firestore `looseItemTemplates`
- "or" divider
- "Custom Item" amber-border card — expands on tap:
  - Description `TextFormField`
  - Length / Width / Height cm fields (numeric keyboard)
  - Quantity stepper
  - "Estimated volume: X m³" amber caption — live calculation
- Tapping a catalogue chip pre-fills dimensions from the template; user can adjust
- "Add to Quote" amber PrimaryButton — returns `QuoteLooseItemLine` to caller

---

### 6.6 — Client Dashboard

**Read designs:** `client_dashboard/screen.png`, `dashboard_overview/screen.png`, `mobile_dashboard_home/screen.png`

Route: `/client/dashboard`

**Provider:**
```dart
@freezed
class ClientDashboard with _$ClientDashboard {
  const factory ClientDashboard({
    required int unitsInStorage,
    required int boxCount,
    required int looseItemCount,
    required double monthlyFeeRand,
    required DateTime? nextBillingDate,
    required DateTime? nextFreeRetrieval,
    required double currentBalanceRand,
    required Job? activeJob,
    required List<AuditEvent> recentActivity,
  }) = _ClientDashboard;
}

@riverpod
Stream<ClientDashboard> clientDashboard(ClientDashboardRef ref) { ... }
```

**Desktop layout (LayoutBuilder > 900px):**

5 stat cards row (white, 12px radius, shadow):
1. Monthly Storage: "R{fee}/month" amber bold + "Active" green chip
2. Items in Storage: total count + "{boxes} boxes + {loose} loose items" caption
3. Next Billing: date + calendar icon amber
4. Next Free Retrieval: date + gift icon green
5. Balance: "R{amount}" + "Paid" green chip or "Overdue" red chip

4 action buttons row (48px, 8px radius, equal width):
- "Get New Quote" amber filled (→ `/calculator`)
- "Request Retrieval" navy filled (→ `/client/requests/new`)
- "View My Storage" outline (→ `/client/storage`)
- "Invoices" outline (→ `/client/subscription`)

Left 65%:
- "Your Storage" `SectionHeader` + "View All →" amber
- Category grid 2-col (white 12px radius 16px pad): emoji + category label bold (📦 Kitchen · 📚 Books · 🧥 Winter Clothes · 🧸 Baby Clothes · 🔧 Garage · 💼 Office) + "X boxes" amber chip right
- "Loose Items" `SectionHeader`. Horizontal scroll item cards (180px wide): large emoji + name bold + status chip + "R—/mo" caption
- Active job banner (if job `inProgress`): full-width `#FFF3E0` card, truck icon, "Your driver is on the way — [driver name] · Est. [window]", "Track" amber button

Right 35%:
- Active retrieval white card amber-left-border: truck icon + units being delivered + scheduled date + "Track" amber button
- "Storage Snapshot" white card: amber progress bar "X / Y m³" or unit count + 5×2 grid squares (amber=used, outline=empty)
- "Recent Activity" SectionHeader + 4 rows: coloured dot + event + time

**Mobile layout:** Single scrolling column. AppBar greeting. Stat cards scroll horizontally. Category grid 2-col. Loose items scroll. Active job banner full-width.

---

### 6.7 — My Storage / Inventory

**Read designs:** `my_storage_inventory/screen.png`, `mobile_my_storage/screen.png`

Route: `/client/storage`

**Provider:**
```dart
@riverpod
Stream<List<StorageUnit>> clientStorage(ClientStorageRef ref) {
  final repo = ref.watch(storageUnitRepositoryProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return repo.watchAll(tenantId: Collections.tenantId, clientId: user.clientId);
}
```

**UI:**
- `AppSearchBar` (search by label or QR code)
- Filter chips (horizontal scroll): All · In Storage · In Transit · Pending Pickup · Delivered
- Grid: 3 cols desktop, 2 cols mobile — `StorageUnitCard` widgets
- Each card: photo 150px cover (12px top radius) + status chip overlay top-left + type badge top-right (CLOSED grey / OPEN amber) + label bold + QR code caption + "Updated X ago" caption
- Tap → `/client/storage/:unitId`
- Empty state: `EmptyState` widget with inventory icon + CTA button

---

### 6.8 — Unit Detail (3 States)

**Read designs:**
- Standard: `unit_details_sbx_9942_a1/screen.png`, `mobile_unit_details/screen.png`
- Delivery request: `unit_details_confirm_delivery_request/screen.png`, `mobile_confirm_delivery/screen.png`
- Out for delivery: `unit_details_out_for_delivery/screen.png`, `mobile_out_for_delivery/screen.png`

Route: `/client/storage/:unitId`

The UI adapts based on `unit.status`:

**All states — shared:**
- Breadcrumb "My Storage / [label]" + back arrow
- `PhotoGallery` — read-only. Left large photo 55%, right 2 stacked. "+X Photos" overlay on last.
- Unit info card: QR code · Type (Closed/Open) · Date added · Tamper seal number (if closed)
- Status timeline stepper: Pending Pickup → In Transit → In Storage → Pending Delivery → In Transit → Delivered. Current step highlighted amber.

**State 1 — `inStorage`:**
- Info bar: "Secure Facility, Zone D-14" + "Last scanned: [time]"
- "Request Delivery" amber button full-width. On tap → navigate to `/client/requests/new?unitId={id}`
- Items section (Open units): 4-col photo grid with description + ITM QR code

**State 2 — `pendingDelivery` (confirm delivery request):**
- `#FFF3E0` info banner: "Delivery scheduled for [date] [window]"
- "Cancel Request" red outline button + "Change Date" outline button
- Timeline shows "Pending Delivery" step active

**State 3 — `inTransit` / out for delivery:**
- `#FFF3E0` banner: "Your item is on the way — Driver: [name] · Est. [window]"
- Live driver status card (navy): driver avatar + name + "En Route" amber chip
- No action buttons — read-only while in transit

**Activity log (all states):** SectionHeader + list of `AuditEvent`s for this unit. Icon + description + actor + timestamp.

---

### 6.9 — Request Delivery

**Read designs:** `request_delivery_step_1/screen.png`, `mobile_request_delivery/screen.png`, `mobile_request_step_1/screen.png`

Route: `/client/requests/new` (optional query param `?unitId=` to pre-select)

4-step flow with `StepIndicator(steps: ['Items', 'Date', 'Address', 'Confirm'], currentStep: step)`.

**Step 0 — Select Items:**
- Grid of `StorageUnitCard`s filtered to `status == inStorage`
- Multi-select with amber border overlay + amber checkmark badge when selected
- Running counter: "X items selected"
- Pre-select `unitId` from query param if provided
- "Next →" disabled if nothing selected

**Step 1 — Date & Time:**
- `CalendarDatePicker` (min: tomorrow, max: +30 days)
- Time window chips: Morning (8am–12pm) · Afternoon (12pm–5pm) · Evening (5pm–8pm)
- Special instructions `TextFormField`

**Step 2 — Address:**
- Pre-populate from `client.defaultAddress`
- Editable address fields (line 1, line 2, city, postcode)
- "Use saved address" toggle

**Step 3 — Review & Submit:**
- Summary: selected units list + date + time window + address
- Free retrieval notice (if within quota): "✓ This counts as your free retrieval this quarter"
- Or: "⚠ Additional retrieval fee: R350 applies"
- "Confirm Request" amber button → `deliveryRequestNotifier.submit()`
- On success → `context.go('/client/dashboard')` + success toast

---

### 6.10 — Subscription & Billing

**Read designs:** `subscription_billing/screen.png`, `mobile_subscription_billing/screen.png`

Route: `/client/subscription`

**UI:**
- Plan card left (white): capacity progress bar + "X of Y boxes used" + upgrade warning if >80%
- Active plan card right (navy): plan name bold white + price + renewal date + "Manage Billing" amber button
- 3 plan comparison cards: Starter / Professional / Enterprise with current plan highlighted
- Payment history `AppDataTable`: DATE · DESCRIPTION · AMOUNT · STATUS · INVOICE
- Status chips: `paid` green · `failed` red · `pending` amber
- Invoice "Download" → open Stripe PDF URL in new tab

---

### 6.11 — Account Settings & Notifications

**Read designs:** `account_settings/screen.png`, `notification_preferences/screen.png`, `mobile_account_settings/screen.png`, `mobile_notification_preferences/screen.png`

Route: `/client/account`

Desktop: left nav panel 260px + right content flex.
Mobile: sectioned single column.

**Left nav:** avatar 80px amber ring + name + email + Client ID · Personal Info · Security · Notifications · Sign Out

**Personal Info:** Full Name · Email (read-only) · Phone · Default Address · "Save Changes" amber

**Security:** Change password fields + "Update" button. 2FA toggle row (disabled, "Coming soon").

**Notifications:** Toggle table rows (56px each, dividers):
- Section labels (amber ALL CAPS, no toggle): DELIVERY UPDATES · STORAGE UPDATES · BILLING
- Each data row: label bold + description caption + EMAIL toggle + PUSH toggle
- Toggles: amber fill ON, grey OFF
- "Save Preferences" amber button

**Danger Zone:** red dashed-border card + "Request Account Deletion" destructive button

---

### 6.12 — Quotation Flow (5 Screens)

The full 9-step quote flow. State is managed by `QuoteFlowNotifier`. The first two steps (Customer Details + Confirm Address) are simple forms — build them from the `Quote` model fields. Steps 3–7 below have designs.

**Quote flow route:** `/quote` — renders `QuoteFlowScreen` which shows the correct step based on `quoteFlowNotifier.currentStep`.

**Provider:**
```dart
@riverpod
class QuoteFlowNotifier extends _$QuoteFlowNotifier {
  @override
  QuoteFlowState build() => QuoteFlowState(
    currentStep: 0,
    draft: Quote(
      id: const Uuid().v4(),
      tenantId: Collections.tenantId,
      boxes: [], looseItems: [],
      vehicleFeeRand: 0, packingHourlyRateRand: 0,
      status: QuoteStatus.draft,
      createdAt: DateTime.now(),
    ),
  );

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void updateDraft(Quote draft) => state = state.copyWith(draft: draft);

  Future<String> submitQuote() async {
    // Write quote to Firestore, get reference number
    final ref = await ref.read(quoteRepositoryProvider).create(state.draft);
    return ref.referenceNumber!;
  }
}
```

#### 6.12.1 — Step 2: Select Boxes

**Read design:** `quote_select_boxes/screen.png`

Step indicator: 9 circles — ✓ Customer Details · ✓ Address · **Boxes** (active amber) · Loose Items · Packing · Pickup · Review · Accept · Schedule

Grid 2×2 box type cards (white 12px radius 16px pad, hover = amber border). Cards loaded from `activeBoxTypesProvider`.
Each card:
- Amber circle icon 56px
- Box name 18px SemiBold
- Dimensions: "{L} × {W} × {H} cm"
- Max weight: "Up to {kg} kg"
- Typical contents: 3 bullet captions (e.g. "📚 Books", "🥘 Kitchenware", "👟 Shoes") — stored in BoxType
- "R{price} / month" amber bold
- Stepper `[-][0][+]` at bottom

Amber info banner: "💡 Not sure which size? Our team can advise during collection."

Sticky bottom bar: "← Back" ghost · "X boxes · R{total}/month" navy bold centred · "Next: Loose Items →" amber button.

#### 6.12.2 — Step 3: Loose Items

**Read design:** `quote_loose_items/screen.png`

Category chips (horizontal scroll, amber active = navy fill): All · Beds · Tables · Office · Appliances · Outdoor · Other

Item grid 3-col (loaded from `looseItemTemplatesProvider` filtered by selected category):
Each item card: large emoji centred 48px + name 14px SemiBold + "Add" amber ghost button

"Custom Item" dashed amber-border card: "+" amber icon + "Custom Item" label + "Specify dimensions" caption → opens `AddLooseItemModal`

Added items section (if any): list rows (emoji + name + dimensions + R—/mo + edit + trash)

Sticky bottom bar: total + "Next: Packing →" amber.

#### 6.12.3 — Steps 4+5: Packing + Pickup

**Read design:** `quote_packing_pickup/screen.png`

Two cards side by side on desktop, stacked on mobile:

**Packing card:**
- Two large radio option cards (selected = amber 2px border + amber radio dot):
  - "No, I'll pack myself" + "Self-service" caption
  - "Yes, I need help" + "Professional packers" caption
- If Yes selected: `#FFF3E0` expansion with packers stepper + hours stepper + "Min 3 hours" caption + "Estimated: R{total}" amber bold (live)

**Pickup Vehicle card:**
- 3 vehicle option rows (loaded from `activeVehiclesProvider`, selected = amber border + dot):
  - Each: emoji + name + fee + capacity label + "Recommended" amber badge on suggested vehicle

Sticky bottom bar: services total + "Next: Review →" amber.

#### 6.12.4 — Quote Summary (Step 6: Review)

**Read design:** `quote_summary/screen.png`

Left 65% white card:
- "Storage" SectionHeader. Table rows (56px, hover `#EFECFF`): item · qty · R/month right. Box lines then loose item lines.
- "Services" SectionHeader: vehicle line (once) + packing line (once) if selected.
- Volume card (`#EFECFF` bg 12px radius): "Estimated Volume" · amber progress bar · "X m³" · 3×4 grid squares (amber=used, outline=empty) · "Roughly a large walk-in wardrobe" grey caption.

Right 35% sticky navy card:
- "Quote Breakdown" amber underline
- "Monthly Storage: R{monthly}" amber 22px Bold
- Collection (once): R{vehicle}. Packing (once): R{packing} if applicable. Divider.
- "Due Today" white/70 · "R{total}" amber 28px Bold
- "Monthly from Month 2" white/70 · "R{monthly}" white 20px
- "★ 1 free retrieval every 3 months included" amber caption
- "Accept Quote" amber PrimaryButton full-width
- "Save Quote" white outline button
- "Share via WhatsApp" ghost text + WhatsApp icon

#### 6.12.5 — Quote Confirmation

**Read design:** `quote_confirmation/screen.png`

Centred white card 12px radius 32px pad on `#F5F2FF`, max 640px.

- Green check circle 80px (`#E8F5F0` bg + `#00A858` icon 40px)
- "Quote Accepted!" Display centred navy
- "Reference: {referenceNumber}" amber pill chip centred
- "We'll contact you within 24 hours to confirm your collection date." grey body centred
- Summary card (`#EFECFF` bg): Monthly R{m} · Due Today R{t} · Collection: To be scheduled
- "Schedule Collection →" amber button
- "View Dashboard" navy button
- "Download Quote PDF" outline button
- "Share" row: WhatsApp icon button + Email icon button (ghost pill)

On "Schedule Collection" → navigate to collection scheduling flow (Step 8 of quote: date + time window picker, same UI as delivery request step 1).

---

### 6.13 — Post-Build Verification

```bash
# No direct Firestore access outside repositories
grep -r "FirebaseFirestore.instance" lib/features/client/ lib/features/quote/
# → must be empty

# No raw hex in new screens
grep -r "Color(0x" lib/features/client/ lib/features/quote/
# → must be empty

# Pricing engine reads from DB (no hardcoded prices)
grep -r "R195\|R295\|R395\|R550\|R850" lib/
# → must be empty (all prices come from boxTypes/vehicles Firestore docs)
```

Manual checks:
1. `flutter build web` — zero errors
2. Quick Calculator at `/calculator` accessible without login
3. Box type rows in calculator appear/disappear based on Firestore `isActive` field
4. Adding/removing boxes and items updates all price totals instantly
5. Volume grid fills proportionally to estimated m³
6. Quote accepted → reference number written to Firestore → confirmation screen shown
7. All 7 client portal screens work at 390px mobile and 1440px desktop with no overflow
8. Unit detail shows correct UI for all 3 status states (inStorage / pendingDelivery / inTransit)
9. Free retrieval notice on delivery request step 3 shows correct copy based on retrieval quota
10. `LoadingSkeleton` shown during async loads; `EmptyState` shown on empty lists

## --- STAGE 6 END ---

---

## --- STAGE 7 START ---

## Stage 7 — Polish, Firebase Functions, Stripe & Deployment

Stage 6 (Client portal) is complete. This final stage wires up payments, notifications, and prepares for production.

> **Status: built (2026-10-15).** Differences from the prompt below:
> - **7.1** — no Stripe. Billing is per unit per month with no plans, so the Stripe Extension
>   (fixed-price subscriptions) does not fit. v1 is **invoices + EFT**: `monthlyInvoices`
>   issues invoices, admins mark them paid/void. See `docs/23_BILLING.md`.
> - **7.2** — functions live in `functions/` at the repo root; see `functions/README.md`.
>   Unit statuses are settled by the app's job transactions, so functions only notify.
> - **7.3** — `NotificationToast` never existed; foreground pushes show as a snackbar
>   (`PushListener`). Shared inbox: `NotificationInbox`.
> - **7.7** — flows run through the real repositories on an in-memory Firestore
>   (`app/test/flows/`); triggers + rules run on the emulators (`functions/test-emulator/`).

### 7.1 — Stripe Subscription (Firebase Extension)

Install the **"Run Payments with Stripe"** Firebase Extension in the Firebase Console. Configure with your Stripe secret key.

The extension creates:
- `customers/{uid}` collection
- Cloud Functions: `createCheckoutSession`, `createPortalLink`

In the Registration screen (Stage 1): On plan selection, call the `createCheckoutSession` Firebase Function:
```dart
final callable = FirebaseFunctions.instance.httpsCallable('ext-firestore-stripe-payments-createCheckoutSession');
final result = await callable.call({
  'price': selectedPlanPriceId, // Stripe Price ID
  'success_url': 'https://yourapp.web.app/client/dashboard',
  'cancel_url': 'https://yourapp.web.app/register',
});
// Redirect to result.data['url']
```

In the Subscription screen (Stage 6), "Manage Billing" button calls `createPortalLink` and redirects to the returned URL.

Set up Stripe webhook → Firebase Function to sync subscription status to Firestore `users/{uid}.subscriptionStatus`.

### 7.2 — Firebase Cloud Functions (Node.js)

Create `functions/index.js` with these functions:

**`onJobStatusChange`** — Firestore trigger on `jobs/{jobId}` updates. When status changes:
- `in_progress` → send FCM push to driver, send email to client (job started)
- `completed` → update all referenced box statuses, send completion email/push to client
- `scheduled` → send FCM push to assigned driver

**`onNewClient`** — Firestore trigger on `clients/{clientId}` create. Sends welcome email via SendGrid or Firebase Email Extension.

**`cleanupUnlinkedQR`** — Scheduled function (runs daily) that checks `qrBatches` and logs any codes unlinked for > 30 days.

### 7.3 — FCM Push Notifications

In the Flutter app, set up `firebase_messaging`:
```dart
// In main.dart or a notification provider
FirebaseMessaging messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
String? token = await messaging.getToken();
// Save token to Firestore users/{uid}/fcmToken
```

Handle foreground messages with a toast notification overlay (use the `NotificationToast` shared widget from Stage 1).

### 7.4 — Responsive Layout Audit

Go through every screen and verify:
- Admin screens: desktop sidebar (≥900px) + mobile bottom nav (<900px)
- Driver screens: mobile-first, but usable on tablet
- Client screens: desktop top-nav (≥900px) + mobile bottom nav
- All grids use `LayoutBuilder` to adjust column count: desktop=4, tablet=2-3, mobile=1-2
- All tables have horizontal scroll on mobile (`SingleChildScrollView` with `scrollDirection: Axis.horizontal`)
- Text never overflows — use `TextOverflow.ellipsis` with `maxLines`

### 7.5 — QR Label Print Template

Create `lib/features/admin/utils/qr_pdf_generator.dart`.

Using the `pdf` package, build a function `generateQRLabelPDF(List<String> codes, List<String> labels)`:

A4 page, 4-column × 3-row grid (12 labels per page, paginate if more).

Each label cell (52mm × 35mm):
- Top: "StrongBox" text small grey
- Centre: QR code image (20mm × 20mm, generated from code string)
- Bottom: Code ID text (bold, 8pt)
- Below ID: label text if provided (grey, 7pt)
- Thin grey border around each cell

Use `Printing.layoutPdf(onLayout: (format) => generateQRLabelPDF(...).save())` to trigger the print dialog.

### 7.6 — Firebase Hosting Deployment

In `firebase.json`:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}]
  }
}
```

Build and deploy:
```bash
flutter build web --release --web-renderer canvaskit
firebase deploy --only hosting
```

Set up CI/CD with GitHub Actions if needed.

### 7.7 — Final Integration Tests

Write integration tests for the 3 critical user flows:

1. **Admin creates a job:** Login as admin → Dashboard → + New Job → select Delivery → select client + items → set date + driver → confirm + submit → verify job appears in Jobs List.

2. **Driver completes a pickup:** Login as driver → Jobs → tap today's job → Start Job → scan each box QR → capture photo → client sign-off → verify job status = completed in Firestore.

3. **Client requests a delivery:** Login as client → My Storage → select box → Request This Back → select date → confirm address → submit → verify job appears in admin Jobs List.

## --- STAGE 7 END ---

---

## QUICK REFERENCE — Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helpers
    function isAdmin() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'; }
    function isDriver() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'driver'; }
    function isClient() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'client'; }
    function isOwner(uid) { return request.auth.uid == uid; }

    match /users/{uid} {
      allow read: if isOwner(uid) || isAdmin();
      allow write: if isOwner(uid) || isAdmin();
    }
    match /clients/{clientId} {
      allow read: if isAdmin() || (isClient() && resource.data.userId == request.auth.uid);
      allow write: if isAdmin();
    }
    match /boxes/{boxId} {
      allow read: if isAdmin() || isDriver() || (isClient() && resource.data.clientId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clientId);
      allow write: if isAdmin() || isDriver();
    }
    match /items/{itemId} {
      allow read: if isAdmin() || isDriver() || (isClient() && resource.data.clientId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clientId);
      allow write: if isAdmin() || isDriver();
    }
    match /jobs/{jobId} {
      allow read: if isAdmin() || (isDriver() && resource.data.driverId == request.auth.uid) || (isClient() && resource.data.clientId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.clientId);
      allow create: if isAdmin();
      allow update: if isAdmin() || (isDriver() && resource.data.driverId == request.auth.uid);
    }
    match /qrBatches/{batchId} {
      allow read, write: if isAdmin();
    }
  }
}
```
