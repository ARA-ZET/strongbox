# 03 — Domain Model

Every entity in the system is defined here. This is the single source of truth for all data structures.

---

## Tenant
**Purpose:** Represents a storage business using the platform. v1 has one tenant.

| Property | Type | Notes |
|---|---|---|
| id | String | Firestore document ID |
| name | String | Business name e.g. "StrongBox Logistics" |
| slug | String | URL-safe identifier e.g. "strongbox" |
| logoUrl | String? | Firebase Storage URL |
| primaryColour | String | Hex colour for white-label branding |
| contactEmail | String | |
| contactPhone | String | |
| address | Address | Registered business address |
| stripeAccountId | String? | Stripe Connect account (v2+) |
| plan | TenantPlan | 'starter'|'professional'|'enterprise' |
| isActive | bool | |
| createdAt | Timestamp | |

**Relationships:** has many Users, Clients, StorageUnits, Jobs, QRCodes

---

## User
**Purpose:** Any person who authenticates with the system.

| Property | Type | Notes |
|---|---|---|
| id | String | Firebase Auth UID |
| tenantId | String | |
| name | String | Full name |
| email | String | |
| phone | String? | |
| role | UserRole | admin \| driver \| client |
| avatarUrl | String? | |
| clientId | String? | Populated if role == client |
| fcmTokens | List<String> | For push notifications |
| notificationPrefs | NotificationPrefs | |
| isActive | bool | |
| isDeleted | bool | |
| deletedAt | Timestamp? | |
| createdAt | Timestamp | |
| lastLoginAt | Timestamp? | |

**Relationships:** belongs to Tenant; may belong to Client (if role==client)

---

## Client
**Purpose:** A paying customer of the storage business (a household or company).

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| primaryUserId | String | The account owner (User.id) |
| displayName | String | e.g. "Jenkins Family" or "Acme Corp" |
| email | String | Billing contact email |
| phone | String | |
| address | Address | Primary delivery address |
| type | ClientType | 'personal' \| 'business' |
| stripeCustomerId | String? | |
| subscriptionId | String? | |
| subscriptionStatus | SubscriptionStatus | |
| subscriptionPlan | SubscriptionPlan | |
| memberIds | List<String> | User IDs of team members |
| storageUnitCount | int | Denormalised count |
| notes | String? | Admin notes |
| isActive | bool | |
| isDeleted | bool | |
| deletedAt | Timestamp? | |
| createdAt | Timestamp | |

**Relationships:** belongs to Tenant; has many StorageUnits, Jobs; has many Users (as members)

**Lifecycle:**
1. Admin creates client → `isActive: true`, no subscription yet
2. Client registers online → Stripe checkout → subscription created → `subscriptionStatus: active`
3. Payment fails → `subscriptionStatus: past_due` → grace period 7 days
4. Cancel → `subscriptionStatus: cancelled` → 30-day read-only access → `isActive: false`

---

## Address
**Purpose:** Embedded value object used on clients, jobs, and the tenant.

| Property | Type |
|---|---|
| line1 | String |
| line2 | String? |
| city | String |
| state | String? |
| postCode | String |
| country | String |
| lat | double? |
| lng | double? |

---

## StorageUnit
**Purpose:** Any physical container in the storage system — box, suitcase, crate, individual item.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| clientId | String | |
| qrCodeId | String | Linked QR code |
| parentId | String? | If nested inside another unit |
| type | UnitType | closed \| open |
| label | String | Human-readable name |
| description | String? | |
| status | StorageStatus | |
| photoIds | List<String> | Exterior photos |
| tags | List<String> | e.g. "fragile", "heavy" |
| category | String? | e.g. "Documents", "Electronics" |
| weight | double? | kg |
| jobId | String? | Current active job |
| warehouseLocationId | String? | Future: shelf/bin location |
| isDeleted | bool | |
| deletedAt | Timestamp? | |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

**Relationships:** belongs to Client and Tenant; has one QRCode; has many Photos; has many child StorageUnits (if open); belongs to many Jobs

**Lifecycle:** See `StorageStatus` enum for valid transitions.

---

## QRCode
**Purpose:** A unique scannable identifier physically attached to a storage unit.

| Property | Type | Notes |
|---|---|---|
| id | String | The code value e.g. SBX-9942-A1 |
| tenantId | String | |
| batchId | String | Which print batch it came from |
| storageUnitId | String? | Null until linked |
| isLinked | bool | |
| linkedAt | Timestamp? | |
| linkedBy | String? | Admin user ID |
| createdAt | Timestamp | |

**Lifecycle:** Generated (unlinked) → Linked to StorageUnit → Permanent

---

## QRBatch
**Purpose:** A set of QR codes generated together for printing.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| count | int | Total codes in batch |
| codeIds | List<String> | |
| linkedCount | int | How many have been assigned |
| printResolution | String | e.g. "300dpi" |
| createdAt | Timestamp | |
| createdBy | String | Admin user ID |

---

## Photo
**Purpose:** A photo associated with a storage unit, job, or driver capture.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| storageUrl | String | Firebase Storage download URL |
| storagePath | String | Firebase Storage path |
| type | PhotoType | exterior \| interior \| driver_capture \| signature |
| entityType | String | 'storageUnit' \| 'job' \| 'driver' |
| entityId | String | |
| jobId | String? | If taken during a job |
| uploadedBy | String | User ID |
| isDeleted | bool | |
| deletedAt | Timestamp? | |
| createdAt | Timestamp | |

---

## Job
**Purpose:** A scheduled pickup or delivery task.

| Property | Type | Notes |
|---|---|---|
| id | String | e.g. JB-9042 |
| tenantId | String | |
| type | JobType | pickup \| delivery |
| clientId | String | |
| driverId | String? | Assigned driver |
| status | JobStatus | |
| scheduledDate | Timestamp | |
| timeWindow | TimeWindow | morning \| afternoon \| evening |
| address | Address | Pickup or delivery address |
| storageUnitIds | List<String> | |
| itemIds | List<String> | For individual item deliveries |
| notes | String? | Dispatch notes |
| driverNotes | String? | Added by driver during job |
| photoIds | List<String> | Driver capture photos |
| clientSignatureUrl | String? | Firebase Storage URL |
| clientConfirmMethod | String? | 'signature' \| 'otp' |
| estimatedFee | double? | |
| isRushJob | bool | |
| completedAt | Timestamp? | |
| cancelledAt | Timestamp? | |
| cancelReason | String? | |
| isDeleted | bool | |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

**Relationships:** belongs to Client, Tenant; may belong to Driver; has many StorageUnits; has many Photos

---

## AuditEvent
**Purpose:** An immutable log entry for every significant system action.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| actorId | String | User who performed the action |
| actorRole | UserRole | |
| action | AuditAction | |
| entityType | String | 'storageUnit'\|'job'\|'client'\|'qrCode' etc |
| entityId | String | |
| metadata | Map<String,dynamic> | Any relevant context |
| timestamp | Timestamp | Server timestamp |

**Rules:** Never updated. Never deleted. Append-only.

---

## Subscription
**Purpose:** Mirrors the Stripe subscription for a client. Managed by Stripe webhook.

| Property | Type | Notes |
|---|---|---|
| id | String | Stripe subscription ID |
| tenantId | String | |
| clientId | String | |
| plan | SubscriptionPlan | starter \| professional \| enterprise |
| status | SubscriptionStatus | |
| currentPeriodStart | Timestamp | |
| currentPeriodEnd | Timestamp | |
| cancelAtPeriodEnd | bool | |
| priceId | String | Stripe price ID |
| createdAt | Timestamp | |
| updatedAt | Timestamp | |

---

## Invoice
**Purpose:** A billing record. Populated by Stripe webhook.

| Property | Type | Notes |
|---|---|---|
| id | String | Stripe invoice ID |
| tenantId | String | |
| clientId | String | |
| amount | double | In local currency |
| currency | String | e.g. "usd" |
| status | PaymentStatus | paid \| open \| void \| uncollectible |
| pdfUrl | String? | Stripe-hosted PDF URL |
| periodStart | Timestamp | |
| periodEnd | Timestamp | |
| createdAt | Timestamp | |

---

## NotificationPrefs
**Purpose:** Embedded object in User — controls notification delivery.

| Property | Type | Default |
|---|---|---|
| pickupStartedEmail | bool | true |
| pickupStartedSms | bool | false |
| deliveryCompletedEmail | bool | true |
| deliveryCompletedSms | bool | true |
| invoiceReadyEmail | bool | true |
| invoiceReadySms | bool | false |
| storageThresholdEmail | bool | true |
| storageThresholdSms | bool | false |

---

## IssueReport
**Purpose:** A problem report submitted by a driver during a job.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| driverId | String | |
| jobId | String? | |
| issueType | IssueType | |
| description | String | |
| photoIds | List<String> | |
| relatedQrCode | String? | |
| isUrgent | bool | |
| status | IssueStatus | open \| in_review \| resolved |
| resolvedBy | String? | Admin user ID |
| resolvedAt | Timestamp? | |
| createdAt | Timestamp | |

---

## DriverShift
**Purpose:** Tracks a driver's active work session.

| Property | Type | Notes |
|---|---|---|
| id | String | |
| tenantId | String | |
| driverId | String | |
| startedAt | Timestamp | |
| endedAt | Timestamp? | |
| breakPeriods | List<BreakPeriod> | |
| vehicleId | String? | |
| eIdQrCode | String | Unique per-shift driver ID QR |
| jobIds | List<String> | Jobs completed this shift |
| status | ShiftStatus | active \| on_break \| ended |

---

## Tag / Category
**Purpose:** User-defined labels for organising storage units.

| Property | Type |
|---|---|
| id | String |
| tenantId | String |
| name | String |
| colour | String |
| type | 'tag' \| 'category' |
