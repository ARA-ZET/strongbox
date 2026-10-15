# Security — secrets & keys

## What is kept out of git

| File | Why | Where the real value lives |
|---|---|---|
| `app/lib/core/firebase_options.dart` | Firebase web/android/ios API keys | local disk + `FIREBASE_OPTIONS_DART` GitHub secret |
| `app/android/app/google-services.json` | Android Firebase config | local disk (+ CI secret if Android is built in CI) |
| `app/ios/Runner/GoogleService-Info.plist` | iOS Firebase config | local disk (+ CI secret if iOS is built in CI) |
| `app/.claude/settings.local.json` | personal machine paths / dev commands | local disk only |
| `**/.env`, `*.keystore`, `*.jks`, `*service-account*.json` | assorted secrets | never committed |

Each config file has a committed `*.example` twin showing the shape. Copy it and
fill in real values, or run `flutterfire configure`.

> **Firebase API keys are not passwords.** They ship inside every client build and
> identify the project; they do not grant privileged access. They are kept out of
> the public repo so it does not advertise the project or invite quota abuse.
> Real protection = API-key restrictions + App Check + Firestore/Storage rules.

## First-time / new-machine setup

```bash
cp app/lib/core/firebase_options.dart.example        app/lib/core/firebase_options.dart
cp app/android/app/google-services.json.example      app/android/app/google-services.json
cp app/ios/Runner/GoogleService-Info.plist.example   app/ios/Runner/GoogleService-Info.plist
# then paste real values, or:  cd app && flutterfire configure --project strongbox-app
```

## CI (GitHub Actions)

`deploy-app.yml` writes `app/lib/core/firebase_options.dart` from the
**`FIREBASE_OPTIONS_DART`** repo secret before `flutter build web`.

Set it once:

```bash
gh secret set FIREBASE_OPTIONS_DART < app/lib/core/firebase_options.dart
```

Existing secret `FIREBASE_SERVICE_ACCOUNT` (Hosting deploy) is unchanged.

Web push uses the GitHub **variable** (not a secret) `FCM_VAPID_KEY` — the
*public* half of the Web Push key pair, which ships in the web bundle anyway.
The build passes it as `--dart-define=FCM_VAPID_KEY=…`; without it push is
simply off on web. Never commit or share the private half.

## Console hardening checklist (do this in Google Cloud / Firebase)

- [ ] **Restrict every API key** — Google Cloud Console → APIs & Services → Credentials:
  - Web key → *HTTP referrers*: `strongbox.co.za/*`, `*.strongbox.co.za/*`, `*.web.app/*`, `*.firebaseapp.com/*`, `localhost:*`
  - Android key → *Android apps*: package name + release SHA-1
  - iOS key → *iOS apps*: bundle id
  - Each key → *API restrictions*: only the APIs actually used (Identity Toolkit, Cloud Firestore, Firebase Installations, FCM, Token Service).
- [ ] **Enable Firebase App Check** (reCAPTCHA Enterprise for web, Play Integrity / DeviceCheck for mobile) and set Firestore + Storage + Auth to **enforce**.
- [ ] **Review Firestore & Storage rules** — assume `projectId` is public. Every rule must check `request.auth` and tenant/role.
- [ ] **Auth providers** — if only Google SSO is used, disable Email/Password so the Identity Toolkit `signUp` REST endpoint cannot mint accounts.
- [ ] **Rotate the exposed keys** (optional, only worthwhile *with* restrictions): create new keys, swap them into the config files + `FIREBASE_OPTIONS_DART`, delete the old keys. Exposed values: `AIzaSyAj0C…pvOow` (web), `AIzaSyBf_B…GdLMw` (android), `AIzaSyApYH…3uaFE` (ios).
- [ ] **Delete the test account** `testclient@strongbox.dev` in Firebase Auth (password `Test1234!` was in the repo history).
- [ ] **Budgets & quotas** — set a billing budget alert; cap Identity Toolkit / Maps quotas.

## If a real secret leaks again

1. Rotate it at the provider immediately (assume it is compromised).
2. Remove it from the working tree; make sure it is gitignored.
3. Purge history: `git filter-repo --path <file> --invert-paths` (or BFG), then force-push.
4. Rotate anything that shared a blast radius.
