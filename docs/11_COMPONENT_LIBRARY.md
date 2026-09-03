# 11 — Component Library

All reusable widgets live in `lib/core/widgets/`. Never rebuild these inline.

---

## StatusChip
**File:** `status_chip.dart`
```dart
StatusChip(status: 'inStorage')
StatusChip(status: 'inTransit', size: ChipSize.small)
```
- Auto-selects background + text colour from status string
- `size`: `normal` (12px, 6px/12px padding) or `small` (10px, 4px/8px padding)
- Full pill border radius

---

## SummaryCard
**File:** `summary_card.dart`
```dart
SummaryCard(
  icon: Icons.inventory_2,
  value: '1,240',
  label: 'Boxes in Storage',
  trend: '+4%',       // optional — green if positive, red if negative
  subtitle: 'Active', // optional
)
```
- White card with shadow
- Icon in navy or amber circle (32px)
- Large bold value
- Label in grey caption
- Trend badge: green bg `+X%` or red bg `-X%`

---

## AppSearchBar
**File:** `app_search_bar.dart`
```dart
AppSearchBar(
  hint: 'Search clients, box IDs...',
  onChanged: (query) {},
  onFilter: () {},    // optional — shows filter icon on right
)
```
- Rounded (full pill), `AppColors.surfaceContainer` bg
- Search icon left, filter icon right
- Height: 44px
- Debounced `onChanged` (300ms)

---

## PrimaryButton
**File:** `primary_button.dart`
```dart
PrimaryButton(
  label: 'Sign In',
  onPressed: () {},
  loading: false,
  icon: Icons.arrow_forward,  // optional
  fullWidth: true,            // default true
)
```

---

## SecondaryButton
**File:** `secondary_button.dart`
```dart
SecondaryButton(label: 'Cancel', onPressed: () {})
```

---

## DestructiveButton
**File:** `destructive_button.dart`
```dart
DestructiveButton(label: 'Delete Account', onPressed: () {})
```

---

## StorageUnitCard (BoxCard)
**File:** `storage_unit_card.dart`
```dart
StorageUnitCard(
  unit: storageUnit,
  onTap: () => context.go('/admin/inventory/${unit.id}'),
  showClient: true,  // show client name below label
)
```
- Photo thumbnail (150px tall, cover, 12px top radius)
- Status overlay badge top-left on photo
- Type badge: "CLOSED" grey pill or "OPEN" amber pill
- Label bold, client name grey caption
- Last updated timestamp caption

---

## QRDisplayCard
**File:** `qr_display_card.dart`
```dart
QRDisplayCard(
  qrData: 'SBX-9942-A1',
  label: 'Storage Unit #SB-1002',
  onPrint: () {},
  onCopy: () {},
)
```
- White card, QR image centred (160px) using `qr_flutter`
- ID text bold below QR
- Print button (navy, printer icon) + Copy button (outline)

---

## PhotoGallery
**File:** `photo_gallery.dart`
```dart
PhotoGallery(
  photoUrls: unit.photoUrls,
  onAddPhoto: () {},    // null = read-only mode
  maxPhotos: 10,
)
```
- Horizontal scroll of thumbnails (100px × 80px, 8px radius)
- Tap thumbnail → full-screen lightbox with swipe
- "+ Add" dashed tile at end if `onAddPhoto` provided

---

## PhotoUploadZone
**File:** `photo_upload_zone.dart`
```dart
PhotoUploadZone(
  onPhotosSelected: (files) {},
  existingPhotos: [],
  maxPhotos: 5,
)
```
- Dashed border, camera icon, "Tap to photograph or upload"
- Shows thumbnail strip once photos added
- Tapping opens `ImagePicker` (camera or gallery)

---

## StepIndicator
**File:** `step_indicator.dart`
```dart
StepIndicator(
  steps: ['Type', 'Items', 'Schedule', 'Confirm'],
  currentStep: 2,  // 0-indexed
)
```
- Horizontal row of circles connected by lines
- Completed: amber filled circle + white checkmark
- Active: amber outlined circle + step number
- Future: grey outlined circle + step number
- Step label below each circle

---

## SectionHeader
**File:** `section_header.dart`
```dart
SectionHeader(
  title: 'Today\'s Jobs',
  action: TextButton(onPressed: () {}, child: Text('View All')),
)
```
- Row: bold title left, optional action right
- 16px SemiBold title, amber action text

---

## LoadingSkeleton
**File:** `loading_skeleton.dart`
```dart
LoadingSkeleton(width: 200, height: 16, radius: 4)
LoadingSkeleton.card()     // full card shimmer
LoadingSkeleton.listTile() // row shimmer
```
- Shimmer animation: amber → surface → amber, 1.5s loop

---

## EmptyState
**File:** `empty_state.dart`
```dart
EmptyState(
  icon: Icons.inventory_2_outlined,
  title: 'No items in storage',
  subtitle: 'Items you add will appear here',
  action: PrimaryButton(label: 'Add Item', onPressed: () {}),
)
```

---

## AppDataTable
**File:** `app_data_table.dart`
```dart
AppDataTable(
  columns: ['CLIENT', 'TYPE', 'STATUS', 'DATE', 'ACTIONS'],
  rows: jobs.map((j) => JobTableRow(j)).toList(),
  onSort: (column, ascending) {},
  isLoading: false,
)
```
- Header: `AppColors.surfaceContainer` bg, ALL CAPS, 12px Medium
- Rows: white, 56px height, hover effect
- Horizontal scroll wrapper on mobile
- Sortable columns

---

## Pagination
**File:** `pagination_row.dart`
```dart
PaginationRow(
  currentPage: 1,
  totalPages: 12,
  onPageChange: (page) {},
  showingFrom: 1,
  showingTo: 20,
  total: 234,
)
```
- "Showing 1-20 of 234" text left
- Page number buttons right (show up to 3 with ellipsis)

---

## ConfirmDialog
**File:** `confirm_dialog.dart`
```dart
showConfirmDialog(
  context,
  title: 'Archive this unit?',
  message: 'This action cannot be undone.',
  confirmLabel: 'Archive',
  isDestructive: true,
  onConfirm: () {},
)
```

---

## NotificationToast
**File:** `notification_toast.dart`
```dart
showToast(context, message: 'Job created', type: ToastType.success)
showToast(context, message: 'Upload failed', type: ToastType.error)
```
- Slides in from top-right
- Auto-dismiss after 4s
- Types: success (green), error (red), info (navy), warning (amber)

---

## ConnectivityBanner
**File:** `connectivity_banner.dart`
- Shown at top of screen when device is offline
- Amber bg, wifi-off icon, "You're offline — changes will sync when reconnected"
- Auto-hides when back online

---

## DashboardStatCard (MetricCard)
**File:** `metric_card.dart`
```dart
MetricCard(
  value: '142',
  label: 'Total Drivers',
  trend: '+12 this month',
  trendPositive: true,
  borderColour: AppColors.statusSuccess,  // optional coloured left border
)
```
- No icon variant of SummaryCard for fleet/reports screens
- Large value, small label, trend badge
