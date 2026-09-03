/**
 * Every photograph the site expects, declared in one place.
 *
 * Each slot ships as a labelled placeholder that holds the exact frame the
 * real photograph will occupy, so nothing reflows when the picture lands and
 * the page can be reviewed at full size before a single shot is taken. The
 * `brief` is the art direction — it is rendered onto the placeholder, so the
 * site itself doubles as the shot list.
 *
 * ── To add a real photograph ──
 *  1. Export it at the `size` below (or larger, same ratio) as a .jpg.
 *  2. Drop it in `public/photos/` named after the slot id, e.g.
 *     `public/photos/hero-collection.jpg`.
 *  3. Set `src` on that slot to `/photos/hero-collection.jpg`.
 *
 * `alt` is written now rather than later on purpose: it is what a screen
 * reader and a search engine read, and it is the thing most likely to be
 * skipped if it is left until the photograph arrives.
 */

export type PhotoSlot = {
  /** Alt text. Describes the picture's content, not the fact it is a picture. */
  alt: string;
  /** What to shoot. Rendered on the placeholder as the brief. */
  brief: string;
  /** Frame ratio [w, h]. Reserved up front so the photo cannot shift layout. */
  ratio: [number, number];
  /** Recommended export size in pixels. */
  size: [number, number];
  /** Where this appears, so the shot list reads in page order. */
  usedOn: string;
  /**
   * Path under `public/`. Left undefined until the real photograph exists —
   * that absence is what makes the slot render as a placeholder.
   */
  src?: string;
  /** Above the fold: loaded eagerly rather than lazily. */
  priority?: boolean;
  /**
   * Set on a temporary Unsplash comp standing in until the commissioned
   * photograph arrives. Its presence means the `src` above is NOT ours —
   * delete both fields when the real picture lands. `TEMPORARY_STOCK` below
   * lists every slot still in this state.
   */
  stock?: { id: string; foundVia: string };
};

export const PHOTOS = {
  "hero-collection": {
    alt: "A StrongBox team member carrying a labelled storage box out of a Cape Town apartment building",
    brief:
      "Two staff in branded shirts carrying labelled boxes from a flat entrance to the van. Daylight, shot from the pavement. Warm and human — this is the whole promise in one frame.",
    ratio: [4, 3],
    size: [1200, 900],
    usedOn: "Homepage hero",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/hero-collection.jpg",
    stock: { id: "photo-1551825687-f9de1603ed8b", foundVia: "https://unsplash.com/photos/smiling-man-stands-behind-delivery-truck" },
    priority: true,
  },
  "facility-racking": {
    alt: "Barcoded storage boxes on numbered steel racking inside the StrongBox facility",
    brief:
      "Wide shot down a racking bay: uniform boxes, visible QR labels, shelf position markers. Clean, well lit, no clutter. This is the shot that answers 'where does my stuff actually go?'",
    ratio: [4, 3],
    size: [1200, 900],
    usedOn: "Homepage and About — Inside the Facility",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/facility-racking.jpg",
    stock: { id: "photo-1627309366653-2dedc084cdf1", foundVia: "https://unsplash.com/s/photos/warehouse-aisle" },
  },
  "facility-aisle": {
    alt: "A clean, well-lit aisle between storage racks in the StrongBox facility",
    brief:
      "Looking down an aisle, racks either side, receding perspective. Include a climate/humidity gauge or access-controlled door in frame if you can — it evidences the claims beside it.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — step 3, Stored Securely",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/facility-aisle.jpg",
    stock: { id: "photo-1664382953403-fc1ac77073a0", foundVia: "https://unsplash.com/s/photos/warehouse-aisle" },
  },
  "team-portrait": {
    alt: "The StrongBox team standing beside their branded collection van in Cape Town",
    brief:
      "Group shot, four to six people, beside the van. Relaxed, looking at camera, Table Mountain or a recognisable Cape Town backdrop if possible. Faces sell a new business.",
    ratio: [4, 3],
    size: [1200, 900],
    usedOn: "About — Our Story",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/team-portrait.jpg",
    stock: { id: "photo-1714976327299-398b8fcc2e06", foundVia: "https://unsplash.com/s/photos/happy-small-business-team" },
  },
  "box-lineup": {
    alt: "The four StrongBox box sizes lined up side by side, from 45 litre to XL heavy-duty",
    brief:
      "All four sizes together on a plain light background, largest to smallest, so scale is obvious at a glance. Straight on, even lighting. A tape measure or everyday object for scale helps.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "Pricing hero",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/box-lineup.jpg",
    stock: { id: "photo-1624137527136-66e631bdaa0e", foundVia: "https://unsplash.com/s/photos/moving-boxes" },
    priority: true,
  },
  "loose-items-load": {
    alt: "A bicycle, surfboard and armchair being loaded into a StrongBox van",
    brief:
      "The awkward, non-boxable things — bike, board, a chair — going into the van. Shows at a glance that you take more than boxes.",
    ratio: [4, 3],
    size: [1100, 825],
    usedOn: "Loose Items hero",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/loose-items-load.jpg",
    stock: { id: "photo-1783473007464-1dbf2ff30dec", foundVia: "https://unsplash.com/s/photos/movers-carrying-boxes" },
    priority: true,
  },
  "storage-closed-box": {
    alt: "A sealed and taped StrongBox carton with its QR label on the side",
    brief:
      "One sealed box, straight on, plain light background. Tape across the seam and the QR label clearly visible. It must read unmistakably as CLOSED — this image is doing half the work of explaining the closed-box option.",
    ratio: [4, 3],
    size: [800, 600],
    usedOn: "Homepage — two ways to store",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/storage-closed-box.jpg",
    stock: {
      id: "photo-1630448927918-1dbcd8ba439b",
      foundVia: "https://unsplash.com/s/photos/sealed-cardboard-box-label",
    },
  },
  "storage-open-box": {
    alt: "An open StrongBox carton with its contents laid out beside it, each item labelled",
    brief:
      "An OPEN box with its contents lifted out and arranged beside it, each item tagged — ideally with a phone or tablet in frame showing those same items listed in the account. The contents must be visible: the whole point of the open-box option is that you can see inside without opening anything.",
    ratio: [4, 3],
    size: [800, 600],
    usedOn: "Homepage — two ways to store",
    // TEMPORARY stock comp. The stand-in shows the *outcome* (contents
    // reviewed on a device) because no free stock exists of an open box with
    // its contents catalogued — shoot the literal version described above.
    src: "/photos/storage-open-box.jpg",
    stock: {
      id: "photo-1758523671391-c510afb87d19",
      foundVia: "https://unsplash.com/s/photos/moving-house-couple-boxes",
    },
  },
  "collection-day": {
    alt: "A StrongBox team member and a client together in a hallway with labelled boxes ready to go",
    brief:
      "The moment the service actually happens: our person and the client in a hallway or doorway with boxes stacked and ready, both at ease. Warm, unhurried, cool interior light. Not a posed handshake.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — what happens on collection day",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/collection-day.jpg",
    stock: {
      id: "photo-1758523670991-ee93bc48d81d",
      foundVia: "https://unsplash.com/s/photos/moving-house-couple-boxes",
    },
  },
  "custody-label": {
    alt: "Close-up of a StrongBox QR label on a carton, in the format SBX-0000-A0",
    brief:
      "Macro on the label itself, stuck to the corrugated edge of a box, with the SBX code legible. Shallow depth of field. This is the proof shot for the whole chain-of-custody argument — the code has to be readable.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — chain of custody",
    // TEMPORARY stock comp. The obvious stand-in — a macro of a real barcode
    // label — is heavily sepia and fought the navy section it sits on, so
    // this cooler warehouse frame holds the space instead. Shoot the macro
    // described above; it is a far better picture for this argument.
    src: "/photos/custody-label.jpg",
    stock: {
      id: "photo-1781559818983-4180d744416a",
      foundVia: "https://unsplash.com/s/photos/warehouse-worker-tablet-inventory",
    },
  },
  "how-it-works-hero": {
    alt: "A relaxed client at home smiling beside labelled StrongBox boxes ready for collection",
    brief:
      "A client at home, smiling to camera, with two or three labelled boxes packed and waiting. Calm and unhurried — the opposite of moving-day chaos. Cool, bright interior light. This is the mood the whole page is arguing for, so warmth matters more than tidiness here.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works hero",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/how-it-works-hero.jpg",
    stock: {
      id: "photo-1783099780043-ad7b2a9fabad",
      foundVia: "https://unsplash.com/s/photos/woman-packing-boxes-home",
    },
    priority: true,
  },
  "app-booking": {
    alt: "A phone showing the StrongBox booking screen with a collection date selected",
    brief:
      "Hand holding a phone with the real booking flow on screen, shot over the shoulder in a home setting. Use an actual screenshot — a mocked-up interface will not match what they get.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — step 1, Get Your Quote",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/app-booking.jpg",
    stock: { id: "photo-1551650975-87deedd944c3", foundVia: "https://unsplash.com/s/photos/hand-holding-phone-app" },
  },
  "van-doorstep": {
    alt: "A StrongBox van parked outside a Cape Town home with the rear doors open and boxes being loaded",
    brief:
      "The branded van at a doorstep, back doors open, a staff member mid-load. Registration visible is fine. Establishes that you are a real operation with real vehicles.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — step 2, We Collect",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/van-doorstep.jpg",
    stock: { id: "photo-1558803116-b443d28fa878", foundVia: "https://unsplash.com/s/photos/delivery-van" },
  },
  "handover-signature": {
    alt: "A client signing for their delivered boxes on a StrongBox driver's tablet at their front door",
    brief:
      "Close-ish on the handover: client signing the device, delivered boxes stacked beside them. Doorway framing. Closes the loop the hero opened.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "How It Works — step 4, Request Back Anytime",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/handover-signature.jpg",
    stock: { id: "photo-1566576721346-d4a3b4eaeb55", foundVia: "https://unsplash.com/s/photos/moving-boxes" },
  },
  "qr-scan": {
    alt: "A StrongBox staff member scanning the QR label on a storage box with a handheld device",
    brief:
      "Tight shot: the QR label on a box, being scanned. Screen showing the matched record is a bonus. This is the proof behind 'photo inventory and barcode tracking'.",
    ratio: [4, 3],
    size: [1000, 750],
    usedOn: "Compare — where we are clearly better",
    // TEMPORARY stock comp — replace with the commissioned shot.
    src: "/photos/qr-scan.jpg",
    stock: { id: "photo-1781559818983-c32838ee3d55", foundVia: "https://unsplash.com/s/photos/warehouse-worker-tablet-inventory" },
  },
} as const satisfies Record<string, PhotoSlot>;

export type PhotoId = keyof typeof PHOTOS;

/** Slots with no image at all yet — these render as labelled placeholders. */
export const OUTSTANDING_PHOTOS = (Object.keys(PHOTOS) as PhotoId[]).filter(
  (id) => !(PHOTOS[id] as PhotoSlot).src
);

/**
 * Slots currently filled by a temporary Unsplash comp rather than by our own
 * photography. Every one of these must be replaced before the site is treated
 * as finished: they are generic stock, they show people who are not our staff
 * or customers, and the Unsplash Licence does not carry a model release.
 */
export const TEMPORARY_STOCK = (Object.keys(PHOTOS) as PhotoId[]).filter(
  (id) => (PHOTOS[id] as PhotoSlot).stock
);
