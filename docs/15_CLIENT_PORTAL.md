# 15 — Client Portal Feature Spec

## Purpose
Give clients a self-service portal to view all their stored items, track active pickups and deliveries in real time, request new deliveries, manage their subscription, and update account settings — all without contacting staff.

---

## Screens & Designs

| Screen | Route | Design File |
|---|---|---|
| Home / Overview | `/client/dashboard` | `client_portal_home`, `client_portal_dashboard_overview` |
| My Storage | `/client/storage` | `client_portal_my_storage` |
| Unit Detail | `/client/storage/:unitId` | `client_box_detail_view` |
| Request Delivery | `/client/requests/new` | `client_request_delivery_step_1` |
| Subscription & Billing | `/client/subscription` | `client_subscription_billing` |
| Account Settings | `/client/account` | `client_account_settings` |
| Notifications | `/client/notifications` | `client_team_notification_settings` |

---

## Shell Layout

### Desktop (>900px)
- Top navigation bar: StrongBox logo left → nav links (Home, My Storage, Deliveries, Billing) → notification bell → user avatar
- Content area below with `AppColors.scaffold` background

### Mobile
- Bottom NavigationBar: Home | Storage | Requests | Account
- Notification bell in top-right AppBar

---

## Screen: Home / Dashboard

### Reads
- `clientDashboardProvider` → `StreamProvider<ClientDashboard>`
  - `unitsInStorage: int`
  - `pendingDeliveries: int`
  - `activeJob: Job?` (in-transit now)
  - `recentActivity: List<AuditEvent>` (last 5)
  - `subscriptionStatus: SubscriptionStatus`

### UI
- Greeting: "Good morning, [name]!"
- Summary row (3 cards): Units in Storage / Active Jobs / Pending Requests
- **Active Job banner** (if `activeJob != null`): amber full-width card — "Your driver is on the way" + driver name + estimated arrival + "Track" button
- **Recent Activity** list: last 5 events with icon, description, timestamp
- **Quick actions**: "Request Delivery" button + "View All Storage" button
- **Subscription warning banner** (if `subscriptionStatus == pastDue`): red banner with "Update Payment" CTA

---

## Screen: My Storage

### Reads
- `clientStorageProvider` → `StreamProvider<List<StorageUnit>>`
  - filtered by `clientId`, `isDeleted == false`
  - sorted by `updatedAt` descending

### UI
- Search bar (filter by label or QR code)
- Filter chips: All / In Storage / In Transit / Pending Pickup / Delivered
- Grid of `StorageUnitCard` widgets (2 cols mobile, 3 cols desktop)
- Each card: photo thumbnail, label, status chip, QR code, last updated
- Tap → `/client/storage/:unitId`
- Empty state: "You have no items in storage yet. Contact us to arrange your first pickup."

---

## Screen: Unit Detail (Client View)

### Reads
- `clientUnitDetailProvider(unitId)` → `StreamProvider<StorageUnit>`
- `unitPhotosProvider(unitId)` → `StreamProvider<List<Photo>>`
- `unitAuditProvider(unitId)` → last 10 audit events for this unit

### UI
- Photo gallery (read-only, `PhotoGallery` widget in read mode)
- Unit info: Label, QR code, Type (Closed/Open), Status chip, Date added
- **For Open units:** item list with individual photos + descriptions
- **Status timeline**: horizontal stepper showing the unit's journey (pickup → storage → delivered)
- **Activity log**: list of audit events with icon + label + timestamp
- "Request Delivery" button (disabled if unit is already in transit or pending delivery)

### Permissions
- Client can view their own units only
- Client cannot edit any unit data
- Client cannot see other clients' units

---

## Screen: Request Delivery (Multi-step)

### Step 1 — Select Items
- Grid of client's stored units (status == `inStorage`)
- Multi-select with checkboxes
- Running count: "3 items selected"
- Validation: must select at least 1 item

### Step 2 — Choose Date & Time Window
- Date picker (min: tomorrow, max: 30 days out)
- Time window selector: Morning (8am–12pm) / Afternoon (12pm–5pm) / Evening (5pm–8pm)
- Special instructions text area

### Step 3 — Confirm Address
- Show saved address from client profile
- Option to "Use a different address for this delivery"
- Address form: line 1, line 2, city, postcode

### Step 4 — Review & Submit
- Summary: selected items, date, time window, address
- "Confirm Request" button
- On submit → `jobRepository.create(Job{type: delivery, ...})` + write AuditEvent
- Success → dismiss to `/client/dashboard` with success toast

### Providers
```dart
deliveryRequestNotifier → AsyncNotifier<DeliveryRequestState>
  // state: selectedUnitIds, date, timeWindow, address, step, isSubmitting
```

---

## Screen: Subscription & Billing

### Reads
- `clientSubscriptionProvider` → `StreamProvider<Subscription?>`
- `clientInvoicesProvider` → `StreamProvider<List<Invoice>>`

### UI
- **Current Plan card**: plan name, price, renewal date, status chip
- **Usage bar**: "X of Y units used" with progress bar
- "Upgrade Plan" button (→ Stripe Checkout)
- "Manage Billing" button (→ Stripe Customer Portal link)
- **Invoices table**: Date | Amount | Status | Download
- Status chips: `paid` (green), `unpaid` (red), `void` (grey)

### Stripe Integration
- "Upgrade" → `subscriptionRepository.createCheckoutSession(clientId, priceId)` → open Stripe URL
- "Manage Billing" → `subscriptionRepository.createPortalLink(clientId)` → open Stripe portal URL
- Invoice "Download" → open Stripe-hosted PDF URL in new tab

---

## Screen: Account Settings

### Reads / Writes
- `currentUserProvider` → AppUser
- `clientProfileProvider` → Client record

### UI Sections

**Personal Info**
- Name, email (email change requires re-auth), phone
- "Save Changes" → `userRepository.updateUser(uid, fields)`

**Default Address**
- Full address form
- "Save Address" → `clientRepository.update(clientId, {defaultAddress: ...})`

**Change Password**
- Current password, new password, confirm
- Uses `FirebaseAuth.currentUser.updatePassword()`

**Notification Preferences**
- Toggle list (see 22_NOTIFICATIONS.md)

**Danger Zone**
- "Request Account Deletion" → opens confirmation dialog → creates a support request, does not immediately delete

---

## Screen: Notifications

### UI
- List of notification toggles grouped by category:
  - **Delivery updates**: Driver on the way / Driver arrived / Delivery completed
  - **Storage**: New item checked in / Item flagged
  - **Billing**: Payment due / Payment failed / Invoice ready
- Toggle all / Toggle by category
- "Save Preferences" → `userRepository.updateUser(uid, {notificationPrefs: ...})`

---

## Providers Summary

```dart
clientDashboardProvider          → StreamProvider<ClientDashboard>
clientStorageProvider            → StreamProvider<List<StorageUnit>>
clientUnitDetailProvider(id)     → StreamProvider<StorageUnit>
unitPhotosProvider(id)           → StreamProvider<List<Photo>>
unitAuditProvider(id)            → StreamProvider<List<AuditEvent>>
deliveryRequestNotifier          → AsyncNotifier<DeliveryRequestState>
clientSubscriptionProvider       → StreamProvider<Subscription?>
clientInvoicesProvider           → StreamProvider<List<Invoice>>
clientProfileProvider            → FutureProvider<Client?>
```

---

## Permissions

| Action | Client | Admin |
|---|---|---|
| View own units | ✓ | ✓ |
| View other clients' units | ✗ | ✓ |
| Request delivery | ✓ | ✓ (on behalf of) |
| Edit unit data | ✗ | ✓ |
| View invoices | ✓ (own) | ✓ (all) |
| Manage subscription | ✓ (own) | ✓ |

---

## Error States

| Error | Handling |
|---|---|
| No units in storage | Empty state with illustration |
| Subscription expired | Gate "Request Delivery" with upgrade prompt |
| Delivery request fails | Show error toast, preserve form data |
| Stripe portal link fails | Show "Contact support" message |
| Address save fails | Inline error below address fields |

---

## Acceptance Criteria

- [ ] Client sees real-time unit status updates on dashboard and storage screen
- [ ] Client can request a delivery in 4 steps with validation at each step
- [ ] Active job (in-transit) shows live banner on dashboard
- [ ] Client cannot request delivery for units not in `inStorage` state
- [ ] Subscription screen shows correct plan, usage, and next billing date from Stripe
- [ ] Invoice table lists all past invoices with download links
- [ ] Account settings changes persist immediately with success feedback
- [ ] Client only sees their own data — no other client's units or invoices visible
