# 13 — Auth Feature

## Purpose
Handle all authentication flows: login, registration, password reset, and role-based routing.

## Screens
- `LoginScreen` — `/login` — design: `strongbox_login/screen.png` (desktop) + `strongbox_login_mobile/screen.png`
- `RegisterScreen` — `/register` — design: `strongbox_registration_payment/screen.png`

## Flows

### Login
1. User enters email + password → call `authNotifierProvider.signInWithEmail()`
2. On success → `currentUserProvider` resolves → router redirects based on role
3. On failure → show inline error below input field (not a dialog)
4. "Forgot password?" → call `authNotifierProvider.resetPassword()` → show success toast

### Google Sign-In
1. Tap "Continue with Google" → `authNotifierProvider.signInWithGoogle()`
2. If new user → check if a `users` document exists → if not, create with role:'client'
3. On success → role-based redirect

### Registration (Client self-service)
- 3-step flow: **Profile → Billing → Review**
- Step 1: name, email, password, phone, address
- Step 2: plan selection (Starter/Professional/Enterprise) → `subscriptionProvider.createCheckoutSession()`
- Step 3: Stripe checkout redirect → on return, show success and redirect to `/client/dashboard`
- On registration: create Firebase Auth user + Firestore `users` doc + `clients` doc

## Providers
- `authStateProvider` — Stream<User?>
- `currentUserProvider` — Future<AppUser?>
- `authNotifierProvider` — signIn, signInWithGoogle, signOut, resetPassword, register

## Validation
- Email: valid format
- Password: min 8 chars, at least one number
- Phone: not empty
- All Step 1 fields required before advancing to Step 2

## Permissions
- Login page: public (no auth required)
- All other routes: requires auth + correct role

## Error Codes
- `wrong-password` → "Incorrect password"
- `user-not-found` → "No account with that email"
- `too-many-requests` → "Too many attempts. Try again in a few minutes"
- `network-request-failed` → "No internet connection"
