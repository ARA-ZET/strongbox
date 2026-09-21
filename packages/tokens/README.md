# @strongbox/tokens — shared design tokens

`tokens.json` is the **single source of truth** for StrongBox's visual design:
colours, spacing, radii, typography. Both apps consume it — nobody hand-copies
hex values.

## Regenerate

```sh
node packages/tokens/build.mjs
```

Writes (both committed to git):

| Output | Consumed by |
|---|---|
| `app/lib/core/theme/tokens.g.dart` — `DesignTokens` class | `AppColors`, `AppSpacing`, `AppRadius` delegate to it |
| `web/lib/tokens.g.ts` — `tokens` object + `cssVariables` string | *(available; see note below)* |

## Guard

- `app/test/core/design_tokens_test.dart` fails if `tokens.g.dart` drifted from
  `tokens.json` or if an `App*` constant stopped tracking its token.
- CI (`.github/workflows/deploy-app.yml`) runs the generator before building, so
  a stale committed file is caught there too.

## Note — the marketing site's palette

The colour values mirror `web/tailwind.config.ts` (navy + blue accent). The site
styles itself from Tailwind and does not import `tokens.g.ts` yet, so when the
web palette changes, update `tokens.json` to match and regenerate.
