# @strongbox/schema — shared domain models

Placeholder for the shared model contract between `app/` (Dart / freezed) and
`web/` (TypeScript).

## Intended shape

```
packages/schema/
  storage_unit.schema.json
  job.schema.json
  item.schema.json
  client.schema.json
  ...
  build.mjs          → web/lib/models/*.ts  (via quicktype or a hand JSON-Schema→TS pass)
```

- `web/` imports the generated TS types directly.
- `app/` keeps its mandated `@freezed` classes (see `docs/03_DOMAIN_MODEL.md`,
  `docs/25_AI_DEVELOPMENT_RULES.md`) **plus** a parity test that loads each
  `*.schema.json` and asserts the freezed class exposes the same fields — same
  pattern as `app/test/core/design_tokens_test.dart`.

## Not built yet

The Flutter models in `app/lib/core/models/` are the current source of truth.
Extract the schemas from them when the web app first needs to read Firestore
data (today it is a static marketing site).
