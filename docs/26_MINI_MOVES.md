# 26 — Mini Moves

> **Status (Nov 2026):** live on the website as an enquiry-led service (`/mini-moves`). **Not yet
> bookable in the app** — every call to action goes to a person (WhatsApp, phone, contact form).
> This doc is the strategy, what the website now does, and the phased plan for the app.

## What we offer

A **mini move** is a small, local move that fits in **one trip of one of our vehicles** (today up
to 8 m³, the largest vehicle in the price list): a few pieces of furniture, a room, a student or
bachelor flat. Within the City of Cape Town only — the same suburbs we collect from for storage.

Three ways a move can end:

| Type | From → to | Notes |
|---|---|---|
| **Home to home** | address A → address B | House ↔ flat, a few streets over |
| **Into your own storage** | address A → a storage place the client chooses | Their self-storage unit, a garage, a relative's spare room |
| **Split** | address A → address B **and** → StrongBox facility | What fits goes to the new home; the rest becomes ordinary StrongBox storage. **The extra stop costs extra.** |

The split move is the one only a storage company can offer, and it is the reason to choose us over
a man with a bakkie or a removal company. Every surface leads with it as the differentiator.

What a mini move is **not**: a full-house move (send them to a removal company — we say so
honestly, as `/compare` already does) or a move to another city.

---

## Positioning and SEO strategy

**One primary intent per page.** The homepage keeps ranking for *storage Cape Town*; its title and
hero are unchanged. Moves get their own page and are woven into the rest of the site by internal
links, never by diluting storage pages.

**Search terms** (South African usage — "removals", not "movers"):

| Intent | Terms | Where it lands |
|---|---|---|
| Primary | furniture removals Cape Town, mini moves Cape Town, small moves / small removals Cape Town | `/mini-moves` (title + H1) |
| Differentiator | moving and storage Cape Town, move and store | `/mini-moves` split-move band; future guide |
| Local | "{suburb} removals" | Region pages link "Mini moves {region}" → `/mini-moves` |
| Avoid | bakkie hire, man with a bakkie | Different intent (cheap, self-load). Address in a comparison guide, not the page title |

**Do not** create per-suburb moves pages ("Mini moves in Sea Point", ×120). Thin doorway pages are
what gets a site demoted; the nine region pages already carry the local signal and now link to moves.

### What the website does now

| Surface | Change |
|---|---|
| `web/app/mini-moves/page.tsx` | The page. Title "Mini Moves & Furniture Removals in Cape Town", one H1, three move types (anchored), size guide from the live vehicle list, 4-step process, split-move band with the live box price, preparation checklist, links to the two moving guides, 9-question FAQ, closing CTA |
| `web/lib/moves.ts` | All moves copy in one place (types, steps, prep, FAQ, prefilled WhatsApp link). Page, homepage band and structured data read from it |
| Structured data | `Service` (serviceType *Furniture removals*, three offers, metro `areaServed`) + `BreadcrumbList` + `FAQPage` built from the same list the page renders. Business description now names mini moves (it was already typed `MovingCompany`) |
| Social card | `app/mini-moves/opengraph-image.tsx` — a shared `/mini-moves` link unfurls with its own card, not the storage pitch. Layout shared via `lib/social-card.tsx` |
| Navbar | "Mini moves" in the desktop bar (took "Free tools"' slot — six is the bar's limit; tools stay in the drawer, footer and Pricing) |
| Footer | "Mini Moves" under Service; brand line mentions moves |
| Homepage | One panel after "Most people come to us for one of these reasons" |
| General FAQ | "Do you also do moves?" (homepage + How it works, with markup) |
| Pricing | Callout under the collection fees: moves are quoted per move |
| Region pages | "Mini moves {region}" link in the collection-day column |
| Contact | Subject "Mini Move Quote", preselected by `/contact?subject=move`, with a moves-specific placeholder |
| Sitemap | `/mini-moves` at 0.9 |

**No move price appears anywhere** — CLAUDE.md forbids hardcoded prices and moves have no price
list entry yet. The page shows vehicle *sizes* from the live list but deliberately not the
collection fees, which would read as a move price.

### Off-site follow-ups (owner)

1. **Search Console** → URL inspection → request indexing of `/mini-moves`; resubmit the sitemap.
2. **Google Business Profile** → add services "Mini moves" and "Furniture removals"; consider
   "Moving and storage service" as an additional category. This is the biggest local-SEO lever.
3. Ask the first move customers for a review that mentions the move.
4. **Photography:** the page reuses two licensed stock photos (`hero-loose`, `collect`). A real
   photo of our own van or team on a move would beat both (see `web/public/photos/README.md`).
   Pexels candidates checked so far all had readable faces or branded boxes.
5. **Content:** two guides would build the topic cluster —
   *"Bakkie hire, a mini move or a removal company? What a small move costs in Cape Town"* and
   *"Moving house and storing the rest: how a split move works"*. Add them to `lib/resources.ts`.

### Measuring it

- Search Console queries containing *removals*, *mini move*, *small move*, *moving and storage*.
- WhatsApp enquiries starting "Hi StrongBox, I'd like a quote for a mini move" (the prefilled
  first line makes them countable), and contact-form emails with subject "Mini Move Quote".

---

## Open decisions (owner)

These change copy, Terms and the app design. The site currently takes the conservative position
in each case, matching the published Terms.

1. **Dismantling / reassembly.** Site says *we don't* (Terms: "will not dismantle furniture").
   Offering it — even as a paid add-on — is a real selling point for moves. If yes, update
   `MOVE_PREP`, the FAQ in `lib/moves.ts` and the Terms together.
2. **Pricing model.** Options: (a) quote every job by hand (today); (b) fixed price per vehicle ×
   distance band (same region / neighbouring / across the metro — `lib/areas.ts` regions make this
   easy) + extra-stop fee + optional helper hours; (c) hourly. **Recommend (b)**: publishable, so
   the site can say "from R…" and the app can quote instantly.
3. **Payment timing.** Today once-off charges go on the next monthly invoice. A move-only
   customer would then pay up to a month after the move. Options: EFT before moving day, or an
   invoice issued on completion. Decide before Phase 2.
4. **Items we won't move** (pianos, safes, pool tables, gas bottles, fuel?) — needed for the Terms.
5. **Crew size** per vehicle, and whether the client is expected to help carry.
6. **Start date.** Is the moves service open now, or from the 1 December 2026 storage launch?

---

## Terms of Service — moves section (draft for review)

Must be published **before taking paid moves**. The current Terms cover collection to storage
only ("These terms apply when you book a collection"). Points to cover, for legal review:

- Scope: local moves within the City of Cape Town, between addresses the client nominates.
- Quote basis and what changes it (undisclosed items, access not as described, waiting time).
- Someone 18+ at each address; failed-trip / waiting-time charge if nobody is present.
- Carry only; no dismantling, reassembly, door removal or unsafe carries (or the add-on, per
  decision 1).
- Items we will not move (decision 4); valuables at own risk.
- Insurance: not an insurer; goods in transit at the client's risk; household policy.
- Liability for damage in transit and the claim window (mirror the 7-day storage rule).
- Cancellation and rescheduling.
- Split moves: the stored part falls under the storage terms from the moment it is collected.

---

## App plan

### Phase 0 — now (no code)

- Enquiries arrive by WhatsApp / phone / email; an admin quotes by hand.
- **Split move:** the storage part runs as an ordinary pickup — admin creates it at
  `/admin/jobs/new` for the same date and window, so it is scanned, photographed, signed for and
  billed exactly as today. The home-to-home part is handled and invoiced outside the app.

### Phase 1 — surface moves in the app (small)

- Client shell "New order" menu: add **Move furniture** → opens the prefilled WhatsApp link (same
  text as `MOVE_WHATSAPP_HREF` in `web/lib/moves.ts`) until Phase 2 replaces it.
- "Get items back" (delivery request): when the delivery address differs from the client's
  address, show "Moving house? We can bring furniture from your old place in the same trip — ask
  us" with the same link. Existing storage clients who are moving are the best split-move leads.
- Wording lives in `lib/features/client/utils/client_orders.dart` (tested), not in widgets.

### Phase 2 — moves as a real order type

**Model** (freezed, enums — rules 1–37 apply):

- `JobType.move` (new). New enum `MoveKind { homeToHome, toOtherStorage, split }`.
- `Job` gains: `moveKind?`, `dropoffAddress?`, `dropoffAccessNotes?`, `moveLines:
  List<MoveLine>` (description, qty, optional `priceKey` from the loose-item catalogue),
  `arrivedAtDropoffAt?`, `dropoffSignatureUrl?`, `dropoffRecipientName?`.
- **Reuse existing statuses:** `collected` = loaded and signed for at A; `completed` = unloaded
  and signed for at B. No new `JobStatus` values.
- **Split move = two linked jobs**, reusing the supply-drop → pickup link (`linkedJobId`): a
  `move` job (A → B) and an ordinary `pickup` job (A → facility) on the same date, window,
  driver and vehicle. The pickup keeps its whole existing flow (SBX codes at booking, scan at the
  door → `inTransit`, scan-in at the facility → `inStorage`), so storage logic is untouched.
  The driver's job list shows the pair as one visit at A, as it does for Path A drop-offs.

**Pricing** (per decision 2): add a `moves` block to `packages/pricing/pricing.json` — e.g.
per-vehicle base by distance band, `extraStopZar`, optional helper per hour, `active` — then
`node packages/pricing/build.mjs`. Admin edits it on `/admin/pricing`; `web/lib/prices.ts`
normalises it so `/mini-moves` can show "from R…"; `functions/src/default-rates.g.json` for the
server-side quote. Loose items need a `volumeM3` so a vehicle can be recommended from the list.
`app/test/core/pricing_test.dart` guards drift.

**Booking:** `bookMove` callable beside `bookPickup` (`functions/src/booking.js`) — validates,
prices server-side, creates the move job (and, for a split, the linked pickup job plus its
storage units with SBX codes), status `pendingConfirmation`, notifies admins. `cancelOrder`
(`functions/src/orders.js`) cancels the linked pickup with the move, as a Path A pickup takes its
drop-off with it. Client job writes stay callable-only; Firestore rules unchanged.

**Client app:** `/client/move` flow — what's moving (catalogue + free text + box count), from,
to (address / own storage / split, choosing per line whether it goes to the new home or to
StrongBox), date + window, recommended vehicle, quote → book. Orders list and order detail show
both legs on one timeline (`client_orders.dart` wording + tests).

**Driver app:** move job detail shows both addresses; check-ins "on my way" → "arrived" at A →
load (photos optional) → sign at A (`collected`) → "on my way" → "arrived" at B → unload → sign
at B (`completed`).

**Admin:** Jobs filter "Moves"; dispatch as today; reports split revenue by job type.

**Billing:** `onceOffZar` on the move job; invoiced per decision 3 (existing next-invoice
mechanism, or a new per-job invoice).

**Notifications:** move confirmed, driver on the way (A and B), delivered.

**Docs to update with Phase 2:** 02 Business Rules, 03 Domain Model, 04 Enums, 05 Firestore
Schema, 09 Repositories, 15/16/17 portals, 22 Notifications, 23 Billing, `journey/JOURNEY.md`
(+ drawio), CLAUDE.md, the Terms, and this doc.

### Phase 3 — booking from the website

Once move prices exist: a move estimator on `/mini-moves` (like the storage quote builder) that
hands the quote to `/register` → `/client/move`, as storage quotes do today.
