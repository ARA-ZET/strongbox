# @strongbox/pricing — default price list

**Admins set live prices in the app** (Admin → Pricing, `/admin/pricing`). Publishing
writes Firestore `priceLists/{tenantId}` (world-readable, admin-write — see
`firestore.rules`), and both apps read that one document:

| Reader | How | Delay |
|---|---|---|
| Flutter app | `priceCatalogProvider` (`app/lib/core/providers/price_catalog_provider.dart`) streams the doc | live |
| Website | `getPrices()` (`web/lib/prices.ts`) reads it over Firestore REST, cached | ≤ 5 min |

`pricing.json` holds the **defaults**, plus the document's shape. Everyone uses the
defaults until an admin first publishes, and the website falls back to them if Firestore
can't be read or returns something malformed.

| Section | Charged |
|---|---|
| `boxes` | per box, per month |
| `looseItems` | per item, per month |
| `vehicles` | once-off pickup fee per collection |
| `itemIcons` | not a price: the Material Symbols an admin may give a loose item |

Storage is billed monthly with no contract and no term or prepay discounts. An entry with
`"active": false` is retired. It is hidden on the website and for new units, but it still
names units already stored under it. Published entries can be retired but not removed,
because units reference them by id.

## Regenerate the defaults

```sh
node packages/pricing/build.mjs
```

| Output | Consumed by |
|---|---|
| `web/lib/pricing.g.ts` — `DEFAULT_PRICES` | fallback in `web/lib/prices.ts` |
| `app/lib/core/constants/price_list.g.dart` — `PriceList.catalog` | fallback in `priceCatalogProvider` |

The Dart output is `price_list.g.dart`, not `pricing.g.dart`: build_runner treats
`X.g.dart` next to an `X.dart` as its own output and deletes it.

## Guard

- `app/test/core/pricing_test.dart` fails if the Dart output drifted from `pricing.json`,
  and covers the admin editor's validation.
- `web/scripts/collect-icons.mjs` bundles every `itemIcons` glyph. Run it after changing
  that list, or the web build's icon check fails.

## Changing a price

Existing storage units keep the rate recorded when they were registered
(`StorageUnit.monthlyRateZar`); only units registered afterwards get the new price.
