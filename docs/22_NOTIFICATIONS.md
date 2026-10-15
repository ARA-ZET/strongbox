# 22 — Notifications Feature Spec

## Purpose
Deliver timely, role-appropriate notifications to admin, drivers, and clients via in-app (real-time bell), push (FCM), and email (Cloud Functions). Users control their own preferences. Notifications are never deleted — they accumulate as a log.

> **As built (Stage 7)** — where this spec and the code differ, the code wins:
> - Docs use `userId` (not `recipientId`); `userId: null` is an alert to **all admins**.
>   Functions also write `route` (where a tap goes) and `isDeleted`.
> - Types: `NotificationType` in `app_enums.dart` (mirrored in `functions/src/constants.js`).
>   Unknown types parse as `systemAlert`.
> - Tokens live in `users/{uid}.fcmTokens` (a list — one per device), added on sign-in and
>   removed on sign-out (`PushNotifications` provider). Web needs `FCM_VAPID_KEY`.
> - One function, `onNotificationCreated`, does push **and** email. Email preferences are the
>   existing `NotificationPrefs` booleans (`pickupStartedEmail`, `deliveryCompletedEmail`,
>   `invoiceReadyEmail`, `storageThresholdEmail`); SMS toggles are stored but not sent yet.
> - Email is queued in `mail/{id}` for the Trigger Email extension.
> - Only admins may address a notification to a person; anyone signed in may raise a
>   `systemAlert` to admins. Recipients may only change `isRead` / `readAt`.
> - Inboxes: drivers `/driver/notifications`, clients `/client/notifications` (inbox above
>   preferences), admins *System alerts* atop `/admin/notifications`.

---

## Designs

| Screen | Route | Design File |
|---|---|---|
| Admin Notifications | `/admin/notifications` | `admin_notifications_alerts_center` |
| Client Notifications | `/client/notifications` | `client_team_notification_settings` |

---

## Notification Types (all defined as `NotificationType` enum)

| Type | Triggers | Recipients |
|---|---|---|
| `jobCreated` | New job created | Assigned driver, admin |
| `jobAssigned` | Driver assigned to job | Driver |
| `jobStarted` | Driver starts job | Client |
| `jobCompleted` | Job sign-off done | Client, admin |
| `jobCancelled` | Job cancelled | Client, driver, admin |
| `unitStatusChanged` | Unit status changes | Admin |
| `deliveryRequested` | Client submits delivery request | Admin |
| `driverEnRoute` | Driver starts transit to client | Client |
| `paymentDue` | Subscription renewal 3 days out | Client |
| `paymentFailed` | Stripe webhook: payment failed | Client, admin |
| `paymentSuccess` | Stripe webhook: invoice paid | Client |
| `issueReported` | Driver submits issue report | Admin |
| `subscriptionExpiring` | 7 days to trial/plan end | Client |
| `qrBatchGenerated` | New QR batch created | Admin (audit only) |
| `systemAlert` | Manual admin broadcast | All |

---

## Firestore Documents

```
notifications/{notificationId}
  tenantId: String
  recipientId: String           // uid of user who receives it
  type: NotificationType
  title: String                 // short title
  body: String                  // full message
  entityType: 'job' | 'unit' | 'subscription' | 'system'
  entityId: String?             // related job/unit/etc id
  isRead: Boolean
  createdAt: Timestamp
  readAt: Timestamp?
  channels: List<String>        // ['inApp', 'push', 'email']
  isDeleted: Boolean

notificationPrefs/{uid}
  push: {
    jobCreated: Boolean, jobCompleted: Boolean, ...
  }
  email: {
    jobCompleted: Boolean, paymentFailed: Boolean, ...
  }
```

---

## In-App Notifications (Bell)

### Bell Widget (all shells)
- Badge count: unread notifications
- `unreadCountProvider(uid)` → `StreamProvider<int>`
  - query: `where('recipientId', uid), where('isRead', false)`
- Tap bell → opens `NotificationsPanel` (admin: `/admin/notifications` full page; client: slide-over drawer)

### Notification List
- Grouped by date: Today / Yesterday / Earlier
- Each item:
  - Icon (type-based) with coloured background
  - Title (14px SemiBold)
  - Body preview (12px grey, 2 lines)
  - Timestamp (12px grey, relative: "2m ago")
  - Unread = `AppColors.surfaceContainer` background
  - Read = white background
- Tap → mark as read + navigate to related entity (if `entityId` provided)
- "Mark all read" action in header
- Read all: `notificationRepository.markAllRead(uid)`

---

## Admin: Notifications & Alerts Center

### Screen: `/admin/notifications`
- Full-page notification list
- Filter tabs: All | Unread | Jobs | System | Billing
- Each notification has entity link (e.g. "View Job" button)
- Admin-only: **System Alerts** section at top for critical events:
  - Overdue jobs (scheduled > 4h ago, still `scheduled`)
  - Failed payments (Stripe webhook)
  - Issue reports from drivers
  - Units with unlinked QR codes > 30 days old

### Alert Priority Badges
- Critical (red): payment failed, job overdue > 12h
- Warning (amber): job not assigned > 2h, trial ending
- Info (grey): standard job notifications

---

## Push Notifications (FCM)

### Setup
- `firebase_messaging` package
- Driver + client apps request push permission on first run
- FCM token stored per user: `userRepository.updateFCMToken(uid, token)`
- Token refreshed on app foreground via `FirebaseMessaging.onTokenRefresh`

### Cloud Function: `sendPushNotification`
- Triggered by Firestore `onCreate` on `notifications/{notificationId}`
- Reads recipient's FCM token from `users/{uid}.fcmToken`
- Checks `notificationPrefs/{uid}.push.{type}` — if false, skip push
- Sends via `admin.messaging().send({token, notification, data})`
- `data` includes `entityType` and `entityId` for deep link on tap

### Push Payload
```json
{
  "notification": {
    "title": "Delivery on its way!",
    "body": "Your driver has left the facility with 3 items."
  },
  "data": {
    "entityType": "job",
    "entityId": "job-uuid",
    "route": "/client/storage"
  }
}
```

### On Tap (Flutter)
```dart
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final route = message.data['route'];
  if (route != null) context.go(route);
});
```

---

## Email Notifications (Cloud Functions)

### Trigger
- Firestore `onCreate` on `notifications/{id}` where `channels` contains `'email'`
- Cloud Function: `sendEmailNotification`

### Templates (Nodemailer or SendGrid)
| Type | Subject | Template |
|---|---|---|
| `jobCompleted` (pickup) | "Your items have been collected" | Pickup confirmation with unit list |
| `jobCompleted` (delivery) | "Your delivery is complete" | Delivery confirmation with signature thumbnail |
| `driverEnRoute` | "Your driver is on the way" | Driver name + ETA window |
| `paymentFailed` | "Action required: Payment failed" | Update payment link |
| `paymentSuccess` | "Invoice paid — receipt attached" | Invoice amount + download link |
| `subscriptionExpiring` | "Your StrongBox trial ends in 7 days" | Upgrade CTA |

### Email Check
- Check `notificationPrefs/{uid}.email.{type}` before sending
- Use `users/{uid}.email` as recipient

---

## Notification Preferences UI

### Admin
- No preferences screen — admins receive all system alerts

### Client (`/client/notifications`)
- Toggle groups:
  - **Delivery updates**: Driver on way / Delivery completed
  - **Storage updates**: Item picked up / Status changed
  - **Billing**: Payment due / Payment failed / Invoice ready
- Per-channel (push / email) toggles per group
- "Save" → `userRepository.updateUser(uid, {notificationPrefs: ...})`

### Driver
- In `/driver/account` → Notifications section:
  - New job assigned: push only
  - Job reminders (30 min before): push only

---

## Providers

```dart
notificationsProvider(uid)          → StreamProvider<List<Notification>>
unreadCountProvider(uid)            → StreamProvider<int>
notificationPrefsProvider(uid)      → StreamProvider<NotificationPrefs>
notificationPrefsNotifier           → AsyncNotifier
  // handles save
markNotificationReadNotifier        → AsyncNotifier
```

---

## Business Rules

- Notifications are append-only — never updated or deleted (soft delete only for user "dismiss")
- Push is only sent if FCM token is registered and user has granted permission
- Email is only sent if `notificationPrefs.email.{type} == true`
- Admin always receives job and system notifications regardless of preferences
- Failed push delivery is logged but does not block the Firestore write

---

## Acceptance Criteria

- [ ] Bell badge updates in real time when new notifications arrive
- [ ] Tapping a notification navigates to the related entity
- [ ] "Mark all read" clears the badge and marks all as read in Firestore
- [ ] Driver receives push notification within 5 seconds of job assignment
- [ ] Client receives push when driver starts transit to their address
- [ ] Email is sent for `jobCompleted` and `paymentFailed` events
- [ ] Client can toggle notification preferences and changes persist
- [ ] Admin sees critical alert banner for overdue or failed-payment events
- [ ] No notification is ever permanently deleted
