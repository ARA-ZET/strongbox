# Site photographs

Every slot the site expects is declared in `lib/photos.ts`.

## ⚠ These are temporary stock comps

The ten `.jpg` files here are **Unsplash stock images**, dropped in so the
layout can be reviewed with real photography in it while the commissioned
shoot is outstanding. They are not our facility, our van, our staff or our
customers.

Each is marked in `lib/photos.ts` with a `stock: { … }` field recording the
Unsplash photo id it came from, and `TEMPORARY_STOCK` in that file lists
every slot still standing on one. Replace them all before the site is
treated as finished.

Two reasons this matters beyond looking generic:

- Several show identifiable people. The Unsplash Licence permits commercial
  use but does **not** grant a model release, so these people must not appear
  to endorse StrongBox on a live marketing site.
- A storage company illustrated with someone else's warehouse is the kind of
  detail a customer notices, and it undercuts the "photo inventory of your
  actual boxes" promise made beside it.

## Adding the real photograph

1. Export at the `size` given for that slot (or larger, same aspect ratio)
   as a `.jpg`.
2. Drop it in this folder, named after the slot id — e.g.
   `hero-collection.jpg`, overwriting the stock file.
3. In `lib/photos.ts`, **delete that slot's `stock: { … }` line.** Leave
   `src` as it is.

The frame does not change, so nothing else on the page moves. Slots can be
done one at a time.

Alt text is already written for every slot — edit it in `lib/photos.ts` if
the photograph you shoot differs from the brief.
