# Deploying the StrongBox marketing site

The site runs on **Firebase App Hosting** in the `strongbox-app` project
(project number `572626633127`, Blaze billing enabled).

App Hosting builds from a **connected GitHub repository** — it does not
deploy from your local disk. Every rollout is triggered by a commit on the
tracked branch (`main`).

## Configuration

| File | Role |
|---|---|
| `.firebaserc` | Pins the default project to `strongbox-app` |
| Firebase web app | `StrongBox Marketing Site` — `1:572626633127:web:f89e9508ccc60ee5527682` |
| `firebase.json` | Declares the `strongbox-web` App Hosting backend, root dir `.` |
| `apphosting.yaml` | Runtime: Node 20, 1 CPU, 512 MiB, autoscale 0–10 |
| `next.config.ts` | `output: "standalone"` — required by App Hosting |

## One-time setup

```sh
# 1. Authenticate the GitHub CLI (interactive browser flow)
gh auth login

# 2. Create the remote repo and push this branch
gh repo create strongbox-web --private --source=. --remote=origin --push

# 3. Create the App Hosting backend (interactive: authorises the Firebase
#    GitHub app, then asks for repo, branch and region — pick `main`)
firebase apphosting:backends:create \
  --project strongbox-app \
  --app 1:572626633127:web:f89e9508ccc60ee5527682
```

`--app` associates the backend with the **StrongBox Marketing Site** web app
already registered in `strongbox-app` — distinct from the four `strong_box`
apps used by the Flutter client.

Choose a region close to the audience — `europe-west1` is the nearest
App Hosting region to South Africa.

Creating the backend triggers the first build and rollout automatically.

## Subsequent deploys

Push to `main`. App Hosting builds and rolls out on its own.

To force a rollout without a new commit:

```sh
firebase apphosting:rollouts:create strongbox-web --git-branch main
```

## Useful checks

```sh
firebase apphosting:backends:list                  # backend + live URL
firebase apphosting:backends:get strongbox-web     # detail
npx next build                                     # reproduce the build locally
```

## Custom domain

The backend gets a `*.web.app` URL on creation. Attach
`www.strongboxstorage.co.za` under **App Hosting → your backend → Custom
domains** in the Firebase Console.

Note `app.strongboxstorage.co.za` is intended for the **Flutter app**, which
deploys separately to classic Firebase Hosting from the repo root
(`firebase.json` → `build/web`). Two products, one project — they coexist.
