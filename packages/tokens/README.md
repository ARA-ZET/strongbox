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

## Note — the marketing site has its own palette

`web/lib/palette.ts` / `web/tailwind.config.ts` currently use a **blue** identity
(`#1d6fe0`, `#0a1a33`), distinct from the app's navy/amber. The generator emits
`web/lib/tokens.g.ts` but the site does **not** adopt it yet. Decide one of:

1. **Converge** — point `palette.ts` and the Tailwind `colors` block at
   `tokens.g.ts` so the site matches the app.
2. **Split the token set** — add a `brand.web.*` group to `tokens.json` for the
   marketing palette, keep `brand.app.*` for the product, one file still owns both.

Until then, treat the site palette as intentionally separate.
