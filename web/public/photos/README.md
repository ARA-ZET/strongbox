# Site photographs

Everything in this folder is generated. Do not edit or add files here by hand.

`npm run photos` (`scripts/process-photos.mjs`) reads each source in
`assets/photos-src/{id}.jpg` and writes `{id}-{640,1280,1920}.avif` and `.jpg`
here, with the site's shared colour grade applied (slightly desaturated, with a
soft navy wash). The grade is what makes photographs from different sources
read as one set.

`lib/photos.ts` lists every photo: its alt text, focal point, credit and,
where needed, a caption.

## Where they come from

The current set is licensed stock from Pexels (free for commercial use, no
attribution required; each photographer is credited in `lib/photos.ts`). Each
photo was checked before use:

- no other company's logo, livery, uniform or printed box branding;
- no readable faces;
- nothing presented as our own van, team or facility. The warehouse photo is
  captioned "Representative image" on the page.

## Swapping one for your own

1. Save your photograph as `assets/photos-src/{id}.jpg`, overwriting the stock
   one. Use 2000px wide or more, landscape.
2. Run `npm run photos`. Only changed sources are reprocessed.
3. In `lib/photos.ts`, update that photo's `alt` and `credit`, and its `focus`
   if the subject sits somewhere else in the frame. Remove `caption` once the
   photo is genuinely of our facility.

Hero photos sit behind text on the left, so frame them with the subject on the
right (or set `focus` to move the crop).

To change the grade for every photo, edit `GRADE` in the script and run
`npm run photos -- --force`.
