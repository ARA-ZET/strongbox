# 19 — Inventory Feature Spec

## Purpose
The central hub for managing all physical storage units (boxes, suitcases, bags, pallets). Admin can browse, filter, search, view detail, edit metadata, manage photos, and track the full history of every unit. This is the system of record for the physical facility.

---

## Screens & Designs

| Screen | Route | Design File |
|---|---|---|
| Inventory Grid | `/admin/inventory` | `admin_all_inventory` |
| Unit Detail | `/admin/inventory/:unitId` | `admin_box_detail` |

---

## Storage Unit Types

| Type | Description | QR Codes |
|---|---|---|
| **Closed** | Sealed box/suitcase — exterior photos only, contents unknown to system | 1 QR for the unit |
| **Open** | Catalogued — each item inside has its own photo, description, and `ITM-` QR code | 1 QR per unit + 1 per item |

---

## Screen: Inventory Grid

### Reads
- `adminInventoryProvider` → `StreamProvider<List<StorageUnit>>`
  - Firestore query: `tenantId, isDeleted == false`
  - Pagination: 20 per page, cursor-based

### Filters (managed by `inventoryFilterNotifier`)
- Status: All / Pending Pickup / In Transit / In Storage / Pending Delivery / Delivered
- Type: All / Closed / Open
- Client: dropdown of all clients
- Search: label, QR code, or client name

### UI Layout
- **Desktop:** Filter sidebar (240px) + main grid (3 columns of `StorageUnitCard`)
- **Mobile:** Horizontal filter chips + 2-column grid + search bar above

### StorageUnitCard
- Photo thumbnail (cover, 150px tall)
- Status badge overlay (top-left on photo)
- Type badge (CLOSED grey / OPEN amber — top-right)
- Label (16px SemiBold)
- Client name (12px grey)
- Last updated timestamp (12px grey)
- Tap → `/admin/inventory/:unitId`

### Actions (header)
- "Add Unit" button → opens AddUnitDrawer (see below)
- Export CSV button (downloads current filter result)

### Pagination
- `PaginationRow` at bottom: "Showing 1–20 of 847"
- Load-more on scroll (infinite scroll on mobile)

---

## Screen: Unit Detail

### Reads
- `adminUnitDetailProvider(unitId)` → `StreamProvider<StorageUnit>`
- `unitPhotosProvider(unitId)` → `StreamProvider<List<Photo>>`
- `unitItemsProvider(unitId)` → `StreamProvider<List<Item>>` (Open units only)
- `unitAuditProvider(unitId)` → `StreamProvider<List<AuditEvent>>` (last 20)

### UI Sections

**Hero**
- Full-width photo gallery (`PhotoGallery` widget, editable for admin)
- Status chip (large, top-right)
- Edit button (top-right)

**Unit Info Card**
- Label (editable inline)
- QR code display (`QRDisplayCard` widget)
- Type: Closed / Open
- Client name (links to `/admin/clients/:clientId`)
- Date added
- Current job (if any) — links to `/admin/jobs/:jobId`
- Notes field

**Items Section** (Open units only)
- Section header: "Items (12)"
- Grid of item cards: thumbnail + description + status + `ITM-` QR code
- "Add Item" button → opens AddItemDrawer

**Photo Management**
- `PhotoUploadZone` for adding more photos
- Existing photos shown in `PhotoGallery` with delete option (soft delete)

**Status Timeline**
- Visual horizontal stepper showing all status changes:
  `Pending Pickup → In Transit → In Storage → Pending Delivery → In Transit → Delivered`
- Each step shows actor name + timestamp

**Activity Log**
- List of `AuditEvent`s for this unit
- Icon + description + actor + timestamp
- Paginated (load more)

**Danger Zone**
- "Archive Unit" → soft delete with confirm dialog
- Only available when unit is `delivered` or `inStorage` and no active job

---

## Add Unit Drawer (AdminUnitForm)

### Fields
- Client selector (dropdown, required)
- Unit type: Closed / Open (toggle)
- Label (text, required, max 80 chars)
- Notes (text area, optional)
- QR code: "Generate new" OR "Link existing QR" (scan or type)
- Photos (`PhotoUploadZone`, at least 1 required)

### Writes
```dart
storageUnitRepository.create(StorageUnit {
  tenantId, clientId, type, label, notes,
  status: StorageStatus.pendingPickup,
  qrCodeId: linkedOrGenerated,
  photoIds: uploadedPhotoIds,
  createdAt: FieldValue.serverTimestamp(),
  updatedAt: FieldValue.serverTimestamp(),
  isDeleted: false,
}, actorId: currentUser.uid)
```
- Writes `StorageUnit` + optionally `QRCode` in a single batch
- AuditEvent written: `action: unitCreated`

---

## Add Item Drawer (Open Units Only)

### Fields
- Description (text, required)
- Photos (`PhotoUploadZone`, min 1)
- QR code (auto-generated `ITM-` code)

### Writes
```dart
itemRepository.create(Item {
  tenantId, boxId: unitId, clientId,
  description, photoIds, qrCodeId,
  status: ItemStatus.inStorage,
  createdAt: FieldValue.serverTimestamp(),
  isDeleted: false,
})
```

---

## Providers

```dart
adminInventoryProvider              → StreamProvider<List<StorageUnit>>
inventoryFilterNotifier             → Notifier<InventoryFilter>
  // InventoryFilter { status, type, clientId, searchQuery, page }
adminUnitDetailProvider(unitId)     → StreamProvider<StorageUnit>
unitPhotosProvider(unitId)          → StreamProvider<List<Photo>>
unitItemsProvider(unitId)           → StreamProvider<List<Item>>
unitAuditProvider(unitId)           → StreamProvider<List<AuditEvent>>
addUnitNotifier                     → AsyncNotifier<AddUnitState>
addItemNotifier                     → AsyncNotifier<AddItemState>
```

---

## Business Rules

- Every storage unit must have at least 1 photo
- Every storage unit must have exactly 1 QR code (enforced by repository)
- Closed units cannot have items — the `items` subcollection stays empty
- Open units must have items before they can be picked up (validated on job creation)
- Soft delete only — `isDeleted = true`, never Firestore `.delete()`
- Units cannot be archived while they have an active job
- QR codes cannot be changed once linked

---

## Permissions

| Action | Admin | Driver | Client |
|---|---|---|---|
| View all units | ✓ | ✗ | ✗ |
| View own client's units | ✓ | ✓ (on job) | ✓ |
| Create unit | ✓ | ✗ | ✗ |
| Edit label/notes | ✓ | ✗ | ✗ |
| Add photos | ✓ | ✓ (during job) | ✗ |
| Archive unit | ✓ | ✗ | ✗ |
| Add items (open units) | ✓ | ✗ | ✗ |

---

## Error States

| Error | Handling |
|---|---|
| Unit not found | 404 empty state with "Go back to inventory" button |
| Photo upload fails | Toast with retry; photo queued locally |
| Archive attempted on active job | Modal: "Cannot archive — unit is on an active job" |
| No photos added on create | Inline error on upload zone |
| QR already linked | Inline error on QR field |

---

## Acceptance Criteria

- [ ] Inventory grid loads with real-time updates from Firestore
- [ ] Filters combine correctly (AND logic) and persist during the session
- [ ] Each unit card links correctly to its detail screen
- [ ] Admin can create a unit with photos and QR in one drawer action
- [ ] Unit detail shows full status timeline and activity log
- [ ] Open units show item list with individual photos and QR codes
- [ ] Adding a photo uploads to correct Storage path and updates Firestore
- [ ] Soft delete archives the unit and removes it from default grid view
- [ ] Pagination loads next 20 units without losing filter state
