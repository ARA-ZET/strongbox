# 25 — AI Development Rules

Every AI prompt for this project begins by reading the documents listed at the bottom of this file. These rules are non-negotiable.

---

## Architecture Rules

1. **Never access Firestore or Firebase Storage directly from a widget or provider.** Always use a repository.
2. **Always use Riverpod** for state. No `setState`, no `ChangeNotifier`, no `InheritedWidget`.
3. **Every provider reads `tenantId`** from `currentTenantIdProvider` before making any query.
4. **Every Firestore query filters `isDeleted == false`** unless explicitly fetching archived records.
5. **Every Firestore query filters by `tenantId`** — no exceptions.
6. **Multi-document writes use transactions or batch writes.** Never write to two documents in separate `set()` calls.
7. **Status changes always create an AuditEvent** in the same transaction.
8. **Use `freezed` for all data models.** No mutable plain Dart classes for domain objects.
9. **Use `json_serializable` for all Firestore serialisation.** No manual `Map` parsing in repositories.
10. **Never use `context.read` inside business logic** — only inside widget callbacks.

---

## UI Rules

11. **Never hardcode hex colours.** Always use `AppColors.*` constants.
12. **Never hardcode spacing values.** Always use `AppSpacing.*` or consistent multiples of 4.
13. **Every screen uses `LayoutBuilder`** to switch between desktop (>900px) and mobile layouts.
14. **Never rebuild a shared widget inline.** Check `lib/core/widgets/` first; use what's there.
15. **Before implementing any screen, read its design PNG** using the Read tool from `/Users/Bunny/Documents/stitch_strongbox_ui_logistics_kit/{screen_name}/screen.png`.
16. **Status chips always use `StatusChip` widget** — never custom containers.
17. **Tables always use `AppDataTable` widget** with horizontal scroll on mobile.
18. **Loading states always show `LoadingSkeleton`** — never an empty screen.
19. **Error states always show a consistent error widget** with a retry button.

---

## Data Rules

20. **QR codes never change once linked.** Never reassign a QR code to a different storage unit.
21. **Storage unit status must follow the state machine** defined in `02_BUSINESS_RULES.md`. Never skip states.
22. **Soft delete only** — never call Firestore `.delete()` on any document.
23. **Audit events are append-only** — never update or delete an audit event.
24. **Photos are stored in Firebase Storage** — only the URL is stored in Firestore.
25. **Subscription state comes from Stripe via webhook** — never write subscription status manually.

---

## Code Quality Rules

26. **Every public method has a doc comment** (`///`).
27. **Every repository method has error handling** — wraps `FirebaseException` in `AppException`.
28. **Run `build_runner` after every model or provider change** before writing UI code.
29. **Never duplicate logic** — extract to a utility function or repository method.
30. **Write widget tests for every shared widget** in `lib/core/widgets/`.

---

## Naming Conventions

31. Screens: `*Screen` suffix (`InventoryScreen`, not `Inventory`)
32. Providers: `*Provider` or `*Notifier` suffix
33. Repositories: `*Repository` suffix
34. Models: No suffix, PascalCase (`StorageUnit`, `Job`, `Client`)
35. Enums: PascalCase enum, camelCase values (`StorageStatus.inStorage`)
36. Files: `snake_case.dart` always
37. Firestore collections: `camelCase` plural (`storageUnits`, `auditEvents`)

---

## Before Writing Any Code

Read these documents in order:
```
01_PRODUCT_VISION.md      — what we're building and why
02_BUSINESS_RULES.md      — non-negotiable logic rules
03_DOMAIN_MODEL.md        — all entities and their properties
04_ENUMS.md               — all enums (never use raw strings)
05_FIRESTORE_SCHEMA.md    — exact Firestore structure
07_FLUTTER_ARCHITECTURE.md — patterns and folder structure
09_REPOSITORIES.md        — how data is accessed
10_DESIGN_SYSTEM.md       — colours, spacing, typography
11_COMPONENT_LIBRARY.md   — reusable widgets (check before building new ones)
12_NAVIGATION.md          — routes and flow
```

Then read the specific feature spec for what you're building:
```
13_AUTH.md, 14_ONBOARDING.md, 15_CLIENT_PORTAL.md,
16_DRIVER_PORTAL.md, 17_ADMIN_PORTAL.md, 18_QR_SYSTEM.md,
19_INVENTORY.md, 20_PICKUPS.md, 21_DELIVERIES.md,
22_NOTIFICATIONS.md, 23_BILLING.md, 24_ANALYTICS.md
```

Then read the design PNG for each screen you're implementing.

---

## Prompt Template

Use this at the start of every Claude Code session:

```
Read the following docs before writing any code:
- CLAUDE.md
- docs/01_PRODUCT_VISION.md
- docs/02_BUSINESS_RULES.md
- docs/03_DOMAIN_MODEL.md
- docs/04_ENUMS.md
- docs/07_FLUTTER_ARCHITECTURE.md
- docs/09_REPOSITORIES.md
- docs/10_DESIGN_SYSTEM.md
- docs/11_COMPONENT_LIBRARY.md
- docs/25_AI_DEVELOPMENT_RULES.md
- docs/[RELEVANT_FEATURE_SPEC].md

Then read the design PNG at:
/Users/Bunny/Documents/stitch_strongbox_ui_logistics_kit/[screen_name]/screen.png

Follow all rules in 25_AI_DEVELOPMENT_RULES.md before generating any code.
```
