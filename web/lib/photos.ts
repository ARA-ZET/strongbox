/**
 * Every photograph on the site, declared in one place.
 *
 * The files are produced by `npm run photos` (scripts/process-photos.mjs) from
 * the sources in `assets/photos-src/{id}.jpg`, which writes
 * `public/photos/{id}-{width}.{avif,jpg}` at each of PHOTO_WIDTHS with the
 * site's shared colour grade applied.
 *
 * These are licensed stock photographs (Pexels licence: free for commercial
 * use, no attribution required — credited here anyway). Each was checked for
 * other companies' logos and readable faces before it went in. Two rules
 * follow from them being stock:
 *
 *  - `alt` describes what is in the frame and nothing more. Never "our van",
 *    "our team" or "our facility": none of these are ours.
 *  - A photo that could be read as our own premises carries `caption`, which
 *    is rendered on the image.
 *
 * ── To replace one with your own photograph ──
 *  1. Save it as `assets/photos-src/{id}.jpg` (2000px wide or more).
 *  2. Run `npm run photos`.
 *  3. Update `alt` (and `credit`, `focus`) below; drop `caption` if it is now
 *     genuinely yours.
 */

/** Widths written by scripts/process-photos.mjs. Keep the two in step. */
export const PHOTO_WIDTHS = [640, 1280, 1920] as const;

export type Photo = {
  /** What is in the picture. Read by screen readers and image search. */
  alt: string;
  /** Source pixel size, so the browser can reserve the frame before load. */
  size: [number, number];
  /**
   * `object-position` for the subject. Heroes put their text on the left, so
   * hero photos are framed with the subject towards the right.
   */
  focus?: string;
  /** Shown on the photo itself, e.g. that a facility shot is not ours. */
  caption?: string;
  credit: { author: string; url: string };
};

const pexels = (author: string, id: number) => ({ author, url: `https://www.pexels.com/photo/${id}/` });

export const PHOTOS = {
  // ── Page heroes ─────────────────────────────────────────────────────────
  "hero-home": {
    alt: "A man in a cap lifting a cardboard box into the back of a van stacked with boxes",
    size: [2000, 1125],
    focus: "72% 40%",
    credit: pexels("Artem Podrez", 5025665),
  },
  "hero-how": {
    alt: "Packed cardboard boxes stacked in front of a sofa in a bright living room",
    size: [2000, 1333],
    focus: "70% 60%",
    credit: pexels("Ivan S", 8962864),
  },
  "hero-pricing": {
    alt: "Taped cardboard boxes stacked on a wooden shelf against a white brick wall",
    size: [2000, 1333],
    focus: "62% 55%",
    credit: pexels("Ayrat", 12354555),
  },
  "hero-compare": {
    alt: "A row of blue roller doors numbered 9, 8 and 7 at a self-storage building",
    size: [2000, 1333],
    focus: "50% 55%",
    credit: pexels("Steve", 851305),
  },
  "hero-loose": {
    alt: "A sofa and armchair wrapped in plastic sheeting in an empty living room",
    size: [2000, 1333],
    focus: "68% 65%",
    credit: pexels("Mart Production", 7415019),
  },
  "hero-tools": {
    alt: "Hands writing figures in a notebook beside a calculator",
    size: [1960, 1600],
    focus: "70% 50%",
    credit: pexels("Olia Danilevich", 5466814),
  },
  "hero-guides": {
    alt: "Hands sealing a cardboard box with a tape gun",
    size: [2000, 1333],
    focus: "60% 60%",
    credit: pexels("Ketut Subiyanto", 4246124),
  },
  "hero-areas": {
    alt: "Table Mountain in evening light above the suburbs of Cape Town",
    size: [2000, 1335],
    focus: "55% 60%",
    credit: pexels("Jay Jay Redelinghuys", 8470660),
  },
  "hero-about": {
    alt: "Cape Town's city centre at dusk with Table Mountain behind",
    size: [2000, 1356],
    focus: "60% 50%",
    credit: pexels("Andrew Harvard", 34862398),
  },
  "hero-contact": {
    alt: "The V&A Waterfront harbour with Table Mountain behind",
    size: [2000, 1333],
    focus: "60% 50%",
    credit: pexels("Stefan Maritz", 35398305),
  },

  // ── Region pages ────────────────────────────────────────────────────────
  "region-atlantic": {
    alt: "Sea Point's promenade and apartment blocks beneath Lion's Head",
    size: [2000, 1500],
    focus: "55% 45%",
    credit: pexels("shootkin", 40447853),
  },
  "region-city": {
    alt: "Cape Town's city centre beneath Table Mountain",
    size: [2000, 1334],
    focus: "60% 40%",
    credit: pexels("Magda Ehlers", 38238589),
  },
  "region-southern": {
    alt: "Yellow pincushion proteas in front of a mist-covered mountain at Kirstenbosch",
    size: [2000, 1333],
    focus: "65% 40%",
    credit: pexels("op23", 13703409),
  },
  "region-peninsula": {
    alt: "Hout Bay's beach and harbour seen from the mountainside",
    size: [2000, 1333],
    focus: "55% 45%",
    credit: pexels("Magda Ehlers", 3886666),
  },
  "region-blouberg": {
    alt: "Dunes on Blouberg beach with Table Mountain across the bay",
    size: [2000, 1331],
    focus: "60% 55%",
    credit: pexels("gjpzoom", 27421678),
  },
  "region-inland": {
    alt: "Cape Town's suburbs stretching inland towards distant mountains",
    size: [2000, 1333],
    focus: "55% 50%",
    credit: pexels("Nathan Nii Noye Mensah", 39417501),
  },

  // ── Feature sections ────────────────────────────────────────────────────
  "box-closed": {
    alt: "A tape dispenser resting on a sealed cardboard box",
    size: [2000, 1033],
    focus: "45% 50%",
    credit: pexels("Ketut Subiyanto", 4246111),
  },
  "box-open": {
    alt: "An open cardboard box of clothes on a sunny windowsill",
    size: [2000, 1333],
    focus: "45% 60%",
    credit: pexels("cottonbro", 4569337),
  },
  collect: {
    alt: "Two people loading boxes into the back of a van, with a hand truck beside them",
    size: [2000, 1333],
    focus: "45% 60%",
    credit: pexels("Tima Miroshnichenko", 6169661),
  },
  racking: {
    alt: "Cardboard boxes stacked on pallets on tall warehouse racking",
    size: [2000, 1333],
    focus: "55% 45%",
    caption: "Representative image",
    credit: pexels("Ryan K", 27111449),
  },
} as const satisfies Record<string, Photo>;

export type PhotoId = keyof typeof PHOTOS;

/**
 * Hero photo per region page. Four regions share the inland view rather than
 * borrowing a coastal landmark that is not theirs.
 */
export const REGION_PHOTO: Record<string, PhotoId> = {
  "atlantic-seaboard": "region-atlantic",
  "city-bowl": "region-city",
  "southern-suburbs": "region-southern",
  "south-peninsula": "region-peninsula",
  "blouberg-west-coast": "region-blouberg",
  "northern-suburbs": "region-inland",
  "cape-flats": "region-inland",
  "mitchells-plain-khayelitsha": "region-inland",
  helderberg: "region-inland",
};

export const photoSrcSet = (id: PhotoId, ext: "avif" | "jpg") =>
  PHOTO_WIDTHS.map((w) => `/photos/${id}-${w}.${ext} ${w}w`).join(", ");
