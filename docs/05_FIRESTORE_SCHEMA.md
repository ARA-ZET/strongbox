# 05 — Firestore Schema

---

## Collection Structure

```
tenants/{tenantId}
users/{userId}
clients/{clientId}
  members/{userId}            ← subcollection: team member refs
storageUnits/{unitId}
  photos/{photoId}            ← subcollection (or top-level, see below)
items/{itemId}                ← individual items inside open units
qrCodes/{codeId}
qrBatches/{batchId}
jobs/{jobId}
  events/{eventId}            ← subcollection: job timeline events
photos/{photoId}              ← top-level (all photos across entities)
auditEvents/{eventId}
notifications/{notificationId}
issueReports/{reportId}
driverShifts/{shiftId}
subscriptions/{subId}         ← managed by Stripe Firebase Extension
invoices/{invoiceId}          ← managed by Stripe Firebase Extension
customers/{userId}            ← managed by Stripe Firebase Extension
```

---

## Document Schemas

### `tenants/{tenantId}`
```json
{
  "id": "strongbox-default",
  "name": "StrongBox Logistics",
  "slug": "strongbox",
  "logoUrl": null,
  "primaryColour": "#FEAE2C",
  "contactEmail": "ops@strongbox.com",
  "contactPhone": "+1-555-000-0000",
  "address": { "line1": "", "city": "", "postCode": "", "country": "US" },
  "plan": "professional",
  "isActive": true,
  "createdAt": "Timestamp"
}
```

### `users/{userId}`
```json
{
  "id": "firebase-auth-uid",
  "tenantId": "strongbox-default",
  "name": "Alex Thompson",
  "email": "alex@example.com",
  "phone": "+1-555-123-4567",
  "role": "admin",
  "avatarUrl": null,
  "clientId": null,
  "fcmTokens": ["token1"],
  "notificationPrefs": {
    "pickupStartedEmail": true,
    "deliveryCompletedEmail": true,
    "invoiceReadyEmail": true
  },
  "isActive": true,
  "isDeleted": false,
  "deletedAt": null,
  "createdAt": "Timestamp",
  "lastLoginAt": "Timestamp"
}
```

### `clients/{clientId}`
```json
{
  "id": "client-uuid",
  "tenantId": "strongbox-default",
  "primaryUserId": "firebase-auth-uid",
  "displayName": "Jenkins Family",
  "email": "sarah.j@example.com",
  "phone": "+1-555-987-6543",
  "address": { "line1": "123 Main St", "city": "Chicago", "postCode": "60601", "country": "US" },
  "type": "personal",
  "stripeCustomerId": "cus_xxxx",
  "subscriptionId": "sub_xxxx",
  "subscriptionStatus": "active",
  "subscriptionPlan": "professional",
  "memberIds": [],
  "storageUnitCount": 156,
  "notes": "Prefers afternoon deliveries",
  "isActive": true,
  "isDeleted": false,
  "deletedAt": null,
  "createdAt": "Timestamp"
}
```

### `storageUnits/{unitId}`
```json
{
  "id": "unit-uuid",
  "tenantId": "strongbox-default",
  "clientId": "client-uuid",
  "qrCodeId": "SBX-9942-A1",
  "parentId": null,
  "type": "closed",
  "label": "Kitchen Hardware",
  "description": "Fragile glassware and utensils",
  "status": "inStorage",
  "photoIds": ["photo-uuid-1", "photo-uuid-2"],
  "tags": ["fragile"],
  "category": "Kitchen",
  "weight": 12.5,
  "jobId": null,
  "warehouseLocationId": null,
  "isDeleted": false,
  "deletedAt": null,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `items/{itemId}` (individual items inside open units)
```json
{
  "id": "item-uuid",
  "tenantId": "strongbox-default",
  "storageUnitId": "unit-uuid",
  "clientId": "client-uuid",
  "qrCodeId": "ITM-1234-B2",
  "label": "RF-Scanner Z10",
  "description": "Qty: 2 • Serial: #88921",
  "photoIds": ["photo-uuid"],
  "tags": ["functional", "electronic"],
  "status": "inStorage",
  "isDeleted": false,
  "deletedAt": null,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `qrCodes/{codeId}`
```json
{
  "id": "SBX-9942-A1",
  "tenantId": "strongbox-default",
  "batchId": "batch-uuid",
  "storageUnitId": null,
  "isLinked": false,
  "linkedAt": null,
  "linkedBy": null,
  "createdAt": "Timestamp"
}
```

### `qrBatches/{batchId}`
```json
{
  "id": "batch-uuid",
  "tenantId": "strongbox-default",
  "count": 12,
  "codeIds": ["SBX-1115-B7", "SBX-4968-C9"],
  "linkedCount": 3,
  "printResolution": "300dpi",
  "createdAt": "Timestamp",
  "createdBy": "admin-uid"
}
```

### `jobs/{jobId}`
```json
{
  "id": "JB-9042",
  "tenantId": "strongbox-default",
  "type": "delivery",
  "clientId": "client-uuid",
  "driverId": "driver-uid",
  "status": "inProgress",
  "scheduledDate": "Timestamp",
  "timeWindow": "afternoon",
  "address": { "line1": "123 Main St", "city": "Chicago", "postCode": "60601", "country": "US" },
  "storageUnitIds": ["unit-uuid-1", "unit-uuid-2"],
  "itemIds": [],
  "notes": "Gate code: 1234",
  "driverNotes": null,
  "photoIds": [],
  "clientSignatureUrl": null,
  "clientConfirmMethod": null,
  "estimatedFee": 45.00,
  "isRushJob": false,
  "completedAt": null,
  "cancelledAt": null,
  "cancelReason": null,
  "isDeleted": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `jobs/{jobId}/events/{eventId}` (subcollection)
```json
{
  "id": "event-uuid",
  "type": "statusChanged",
  "description": "Loaded onto Fleet #402",
  "actorId": "driver-uid",
  "actorName": "Marcus Rivera",
  "metadata": { "fromStatus": "assigned", "toStatus": "inProgress" },
  "timestamp": "Timestamp"
}
```

### `photos/{photoId}`
```json
{
  "id": "photo-uuid",
  "tenantId": "strongbox-default",
  "storageUrl": "https://firebasestorage.googleapis.com/...",
  "storagePath": "storageUnits/unit-uuid/photos/1234567890.jpg",
  "type": "exterior",
  "entityType": "storageUnit",
  "entityId": "unit-uuid",
  "jobId": null,
  "uploadedBy": "admin-uid",
  "isDeleted": false,
  "deletedAt": null,
  "createdAt": "Timestamp"
}
```

### `auditEvents/{eventId}`
```json
{
  "id": "audit-uuid",
  "tenantId": "strongbox-default",
  "actorId": "user-uid",
  "actorRole": "driver",
  "action": "qrScanned",
  "entityType": "storageUnit",
  "entityId": "unit-uuid",
  "metadata": { "scanType": "pickup", "jobId": "JB-9042", "location": "Warehouse A" },
  "timestamp": "Timestamp"
}
```

### `driverShifts/{shiftId}`
```json
{
  "id": "shift-uuid",
  "tenantId": "strongbox-default",
  "driverId": "driver-uid",
  "startedAt": "Timestamp",
  "endedAt": null,
  "breakPeriods": [{ "startedAt": "Timestamp", "endedAt": "Timestamp" }],
  "vehicleId": "vehicle-uuid",
  "eIdQrCode": "DRV-A1B2C3D4",
  "jobIds": ["JB-9042"],
  "status": "active"
}
```

### `issueReports/{reportId}`
```json
{
  "id": "issue-uuid",
  "tenantId": "strongbox-default",
  "driverId": "driver-uid",
  "jobId": "JB-9042",
  "issueType": "cargoDamage",
  "description": "Box corner dented on arrival",
  "photoIds": ["photo-uuid"],
  "relatedQrCode": "SBX-9942-A1",
  "isUrgent": false,
  "status": "open",
  "resolvedBy": null,
  "resolvedAt": null,
  "createdAt": "Timestamp"
}
```

---

## Firestore Indexes Required

```
storageUnits: tenantId ASC, clientId ASC, status ASC, updatedAt DESC
storageUnits: tenantId ASC, status ASC, updatedAt DESC
jobs: tenantId ASC, status ASC, scheduledDate ASC
jobs: tenantId ASC, driverId ASC, scheduledDate ASC
jobs: tenantId ASC, clientId ASC, scheduledDate DESC
auditEvents: tenantId ASC, entityId ASC, timestamp DESC
auditEvents: tenantId ASC, actorId ASC, timestamp DESC
qrCodes: tenantId ASC, batchId ASC, isLinked ASC
```

---

## Naming Conventions
- Collection names: **camelCase plural** (`storageUnits`, `auditEvents`)
- Document IDs: auto-generated UUID via Firestore `doc()`, except where human-readable IDs make sense (tenants, qrCodes)
- Field names: **camelCase** (`createdAt`, `tenantId`, `isDeleted`)
- Timestamps: always `Timestamp` (server timestamp on write: `FieldValue.serverTimestamp()`)
- Boolean fields: prefix with `is` or `has` (`isDeleted`, `isActive`, `isLinked`)

---

## Security Rules Summary
See `02_BUSINESS_RULES.md` for full rules. Key principles:
- All queries must match `tenantId` of the authenticated user
- Clients can only read their own data (`clientId` match)
- Drivers can only update jobs assigned to them
- Audit events are read-only after creation (no update/delete)
- Admin role has full read/write within their tenant
