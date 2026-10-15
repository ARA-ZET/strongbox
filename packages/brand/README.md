# @strongbox/brand — the StrongBox logo

The logo is the **marketing site's navbar logo**: the Material Symbols Outlined
`package_2` glyph, filled (`FILL 1, wght 400, GRAD 0, opsz 24`), beside a bold
"StrongBox" wordmark. Accent-deep glyph + navyDeep text on light grounds; sky
glyph + white text on navy (site footer).

| Where | Drawn by |
|---|---|
| Site navbar / footer | `web/components/Navbar.tsx`, `Footer.tsx` (Material Symbols font) |
| Flutter app headers, login, register | `BrandLogo` / `BrandMark` in `app/lib/core/widgets/brand_logo.dart` (`material_symbols_icons`, same font) |

Never use a different icon (`inventory_2`, etc.) for the logo in the app.
`app/test/core/brand_mark_test.dart` fails if the site's logo or `BrandLogo`
changes on its own — change both together.

## App icons

The site's favicon, `web/app/icon.svg`, is the source for the Flutter app's
favicon, PWA, iOS and Android launcher icons, so the app's browser tab and home
screen icon match the site's:

```sh
(cd web && npm ci)            # once — rasterises with web's `sharp`
node packages/brand/build.mjs
```
