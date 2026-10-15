# StrongBox

Monorepo for the StrongBox Logistics product. Open **`strongbox.code-workspace`**
in VS Code to get all folders as one workspace.

```
strongbox/
├─ app/         Flutter web+mobile app (admin / driver / client portals)
├─ web/         Next.js marketing site (strongboxstorage.co.za)
├─ functions/   Cloud Functions — invoices, notifications, push, email (see functions/README.md)
├─ packages/
│  ├─ tokens/   design tokens — one JSON → app + web  (see packages/tokens/README.md)
│  ├─ pricing/  default price list — one JSON → app + web + functions
│  ├─ brand/    logo + app icon generator
│  └─ schema/   shared domain-model contract (not built yet)
├─ docs/        product specification (25 docs) — shared by both apps
├─ firestore.rules
├─ firebase.json      declares BOTH hosting targets (see below)
└─ .firebaserc        → project `strongbox-app`
```

Both apps run on the **one** Firebase project `strongbox-app`
(owner: `richardatclm@gmail.com`, Blaze billing on).

## Deployment

| App | Engine | Trigger | URL |
|---|---|---|---|
| `app/` | classic **Firebase Hosting** (`firebase.json` → `app/build/web`) | GitHub Action `.github/workflows/deploy-app.yml` on push to `main` touching `app/**` or `packages/**` | `app.strongbox.co.za` |
| `web/` | **Firebase App Hosting** backend `strongbox` (`us-east4`), root dir `/web` | App Hosting's native GitHub connection, any push to `main` | `www.strongboxstorage.co.za` |
| `functions/` | **Cloud Functions** (Node 22, `us-central1`) | Manual: `firebase deploy --only functions` (tested in CI) | — |

### Deploying without CI

If the GitHub Action can't run (e.g. the account is billing-locked), deploy
from the repo root after running the checks it would have run:

```sh
cd app && flutter analyze && flutter test && flutter build web --release && cd ..
(cd functions && npm test && npm run test:emulator)   # emulators need Java 21+
firebase deploy --only firestore:rules,firestore:indexes,hosting,functions --project strongbox-app
```

### One-time setup

**Flutter Action secret** — generate a service account with Hosting deploy rights:

```sh
firebase login:use richardatclm@gmail.com
# create key: Firebase console → Project settings → Service accounts → Generate key
gh secret set FIREBASE_SERVICE_ACCOUNT --repo ARA-ZET/strongbox < path/to/key.json
```

**App Hosting backend** (Firebase Console → Build → App Hosting):
- Connect repo `ARA-ZET/strongbox`, branch `main`, **root directory `web`**
- Region `europe-west1` (closest to ZA)
- It reads `web/apphosting.yaml` for runtime config
- First rollout starts on creation; every later push to `main` rolls out automatically

To force a web rollout without a commit:

```sh
firebase apphosting:rollouts:create strongbox --git-branch main
```

## Local development

```sh
# Flutter app
cd app && flutter pub get && flutter run -d chrome

# Marketing site
cd web && npm install && npm run dev

# Regenerate shared tokens after editing packages/tokens/tokens.json
node packages/tokens/build.mjs
```

## Firestore rules

Deployed from the repo root: `firebase deploy --only firestore:rules` (CI does
this on every push to `main`). They are tested with the functions on the
emulators — `cd functions && npm run test:emulator` (needs Java 21+).
