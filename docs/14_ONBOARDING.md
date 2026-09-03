# 14 — Onboarding Feature Spec

## Purpose
Guide new users (admin, driver, client) through initial setup so they arrive at their first meaningful action with no confusion. Onboarding covers: email/Google signup, role-based first-run experience, and the admin's initial workspace configuration (first client, first QR batch).

---

## Screens & Designs

| Screen | Route | Design File |
|---|---|---|
| Login | `/login` | `strongbox_login`, `strongbox_login_mobile` |
| Register | `/register` | `strongbox_registration_payment` |
| Post-login redirect | `/` | — (handled by router) |

No dedicated "onboarding wizard" screen exists in v1 — onboarding is woven into the empty states and first-run prompts within each role's portal.

---

## Registration Flow

### Step 1 — Account Details
- Full name (required)
- Email address (required, validated)
- Password (min 8 chars, 1 uppercase, 1 number)
- Confirm password

### Step 2 — Role Selection
- "I'm a business owner / admin" → `role: admin`
- "I'm a driver" → `role: driver` (requires invite code from admin in v1)
- "I'm a client / customer" → `role: client` (requires invite link from admin in v1)

> **v1 constraint:** Only admin self-registers. Drivers and clients are invited by admin.

### Step 3 — Subscription (Admin only)
- Show plan cards: Starter R899/mo, Professional R3,499/mo, Enterprise (contact)
- Pre-select Starter
- Stripe Checkout iframe or redirect (Firebase Stripe Extension)
- On payment success → webhook sets `subscriptionStatus: active` on user doc
- On skip → `subscriptionStatus: trialing` (14-day trial)

### Post-Register
- `UserRepository.createUser(AppUser)` writes to `users/{uid}`
- Router redirect → role-appropriate portal
- First-run banner shown on dashboard

---

## First-Run Experiences by Role

### Admin First Run
Shown when `dashboardStats.totalClients == 0 && dashboardStats.totalUnits == 0`:

1. **Welcome banner** on `/admin/dashboard`
   - "Welcome to StrongBox, [name]! Let's set up your workspace."
   - Step checklist: Add first client → Generate QR batch → Create first job
   - Each step links to the relevant screen

2. **Empty state on `/admin/inventory`**
   - Illustration + "No storage units yet"
   - CTA: "Generate QR labels" → `/admin/qr`

3. **Empty state on `/admin/clients`**
   - CTA: "Add your first client" → opens Add Client drawer

### Driver First Run
- App shows onboarding checklist card at top of `/driver/jobs`:
  - "Start your shift to begin" → shift button
  - "Scan your first QR code" → `/driver/scan`
- Checklist dismisses after first job completed

### Client First Run
- Banner on `/client/dashboard`:
  - "Your items are being set up. You'll receive a notification when your first pickup is scheduled."
- `/client/storage` shows empty state with illustration until first unit assigned

---

## Admin Invites Drivers & Clients

### Invite Driver
- Admin → `/admin/fleet` → "Add Driver" button
- Enter name + email → Firebase Cloud Function sends invite email
- Email contains a magic link `?inviteToken={token}&role=driver`
- Driver clicks link → pre-fills registration form with email + role locked to `driver`
- On register → `users/{uid}` created with `role: driver`, `tenantId: 'strongbox-default'`

### Invite Client
- Admin → `/admin/clients` → "Add Client" button
- Enter client name + email → Cloud Function sends invite email
- Client clicks link → pre-fills registration form with role locked to `client`
- On register → `users/{uid}` + `clients/{clientId}` both created

---

## Providers

```dart
// Tracks whether current user has completed onboarding
onboardingStatusProvider → FutureProvider<OnboardingStatus>
  // OnboardingStatus { isComplete, hasAddedClient, hasGeneratedQR, hasCreatedJob }

// Invitation token handling
inviteTokenProvider → StateProvider<String?>
```

---

## Validation

| Field | Rule |
|---|---|
| Email | Valid email format, not already registered |
| Password | Min 8 chars, 1 uppercase, 1 number |
| Invite token | Must exist in Firestore `inviteTokens` collection, not expired (24h TTL) |
| Role | Cannot self-register as driver or client without valid invite token |

---

## Firestore

```
inviteTokens/{token}
  tenantId: String
  email: String
  role: 'driver' | 'client'
  expiresAt: Timestamp    // 24 hours from creation
  usedAt: Timestamp?
  createdBy: String       // admin uid
  isUsed: Boolean
```

---

## Error States

| Error | Handling |
|---|---|
| Email already in use | "An account with this email already exists. Sign in instead." |
| Invalid invite token | "This invite link is invalid or has expired. Contact your admin." |
| Expired invite token | Same as invalid |
| Payment failed | Stripe error message shown; retry or skip to trial |
| Network error on register | Show retry toast; preserve form data |

---

## Acceptance Criteria

- [ ] Admin can self-register with email + password or Google SSO
- [ ] Admin is redirected to subscription step after account creation
- [ ] Trial mode works for 14 days without payment
- [ ] Admin can invite a driver via email; driver receives link and registers with role locked
- [ ] Admin can invite a client via email; client registers and client record is created
- [ ] Invite tokens expire after 24 hours
- [ ] First-run checklists appear when portal is empty and dismiss on completion
- [ ] All three roles land on the correct portal after registration
