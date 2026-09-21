# @strongbox/pricing — shared price list

`pricing.json` is the **single source of truth** for what StrongBox charges.
The marketing site and the Flutter app both read it, so the prices on
strongboxstorage.co.za and in the client portal can't disagree.

| Section | Charged |
|---|---|
| `boxes` | per box, per month |
| `looseItems` | per item, per month |
| `vehicles` | once-off pickup fee per collection |

Storage is billed monthly with no contract and no term or prepay discounts.

Key names (`price`, `desc`, …) match what the website's components already use.

## Regenerate

```sh
node packages/pricing/build.mjs
```

Writes (both committed to git):

| Output | Consumed by |
|---|---|
| `web/lib/pricing.g.ts` | re-exported from `web/lib/constants.ts` (`BOX_TYPES`, `LOOSE_ITEMS`, `VEHICLES`) |
| `app/lib/core/constants/price_list.g.dart` — `PriceList` | `Pricing` / `StorageBill` in `app/lib/core/constants/pricing.dart` |

The Dart output is `price_list.g.dart`, not `pricing.g.dart`: build_runner treats
`X.g.dart` next to an `X.dart` as its own output and deletes it.

## Guard

- `app/test/core/pricing_test.dart` fails if the Dart output drifted from `pricing.json`.
- CI (`.github/workflows/deploy-app.yml`) runs the generator before building.
- A new loose-item `icon` is picked up by `web/scripts/collect-icons.mjs` — run it, or the
  web build's icon check fails.

## Changing a price

Existing storage units keep the rate recorded when they were registered
(`StorageUnit.monthlyRateZar`); only units registered afterwards get the new price.
