import {
  BOX_TYPES,
  LOOSE_ITEM_CATEGORIES,
  LOOSE_ITEMS,
  VEHICLES,
} from "./pricing.g";

// Overridable per-environment via apphosting.yaml; falls back to production
export const APP_URL =
  process.env.NEXT_PUBLIC_APP_URL ?? "https://app.strongboxstorage.co.za";

// Human contact channels — shown in the navbar, footer, and contact page so
// a prospect can reach a real person fast (new-business trust signal).
export const CONTACT_PHONE_DISPLAY = "+27 071 909 0839";
export const CONTACT_PHONE_HREF = "tel:+27719090839";
export const CONTACT_EMAIL = "info@strongbox.co.za";
export const CONTACT_EMAIL_HREF = "mailto:info@strongbox.co.za";

/**
 * Social presence. WhatsApp is derived from the real support number, so it
 * works today; the rest are left blank until the accounts exist. Anything
 * without a `href` is filtered out before render rather than shipped as a
 * dead `#` link, which is what the footer and contact page did before.
 */
export type SocialPlatform = "whatsapp" | "facebook" | "instagram" | "x";

export const SOCIAL_LINKS: { platform: SocialPlatform; label: string; href: string }[] = [
  { platform: "whatsapp", label: "WhatsApp", href: "https://wa.me/27719090839" },
  { platform: "facebook", label: "Facebook", href: "" },
  { platform: "instagram", label: "Instagram", href: "" },
  { platform: "x", label: "X", href: "" },
];

/**
 * Physical HQ, shared by the contact card, the map link, the FAQ and the
 * LocalBusiness structured data in `lib/seo.ts`.
 *
 * There is one facility. Everything else in Cape Town is served from it —
 * see SERVICE_AREAS — so nothing on the site should imply a second branch.
 */
export const HQ_SUBURB = "Kensington";
export const HQ_POSTCODE = "7504";
export const HQ_ADDRESS_LINES = [`${HQ_SUBURB},`, `Cape Town, ${HQ_POSTCODE}, South Africa`];
export const HQ_MAPS_HREF = "https://maps.google.com/?q=Kensington,Cape+Town,7504";

/**
 * Suburb centroid, not a street pin.
 *
 * TODO — replace with the facility's own coordinates once the street address
 * is published. Google matches a Business Profile to the LocalBusiness geo,
 * and a suburb centroid matches loosely; a rooftop pin matches exactly.
 */
export const HQ_GEO = { lat: -33.9243, lng: 18.5333 } as const;

/**
 * Where we collect and deliver. One facility, whole-metro coverage — this is
 * what tells Google the service reaches a searcher's suburb without claiming
 * a branch there. Read by `areaServed` in the structured data and by the
 * coverage section on the contact page.
 */
export const SERVICE_AREAS = [
  "Sea Point", "Green Point", "Camps Bay", "Clifton", "Bantry Bay",
  "City Bowl", "Gardens", "Tamboerskloof", "Oranjezicht", "Vredehoek",
  "Woodstock", "Salt River", "Observatory", "Mowbray", "Rosebank",
  "Rondebosch", "Newlands", "Claremont", "Kenilworth", "Wynberg",
  "Constantia", "Tokai", "Muizenberg", "Kalk Bay", "Fish Hoek",
  "Century City", "Milnerton", "Table View", "Bloubergstrand", "Parklands",
  "Pinelands", "Kensington", "Maitland", "Goodwood", "Bellville",
  "Durbanville", "Brackenfell", "Somerset West", "Hout Bay", "Noordhoek",
] as const;

/**
 * Trading hours, in 24h local time, with schema.org day names.
 *
 * Single source for the contact page's "Operating Hours" card and the
 * `openingHoursSpecification` in the structured data — the two were written
 * separately and had already drifted, and Google reads a mismatch between
 * visible hours and marked-up hours as an inaccuracy.
 */
export const OPENING_HOURS = [
  {
    label: "Mon – Fri",
    days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
    opens: "08:00",
    closes: "18:00",
  },
  { label: "Sat", days: ["Saturday"], opens: "09:00", closes: "13:00" },
] as const;

/** The hours as the contact card renders them, e.g. "Mon – Fri: 08:00 – 18:00". */
export const OPENING_HOURS_LINES = OPENING_HOURS.map(
  ({ label, opens, closes }) => `${label}: ${opens} – ${closes}`
);

/*
 * The price list — boxes, loose items and pickup vehicles — is generated
 * from packages/pricing/pricing.json, which the Flutter app reads too, so
 * the site and the client portal can never quote different numbers. Edit
 * the JSON and run `node packages/pricing/build.mjs`; do not add prices
 * here.
 *
 * Storage is billed monthly per box or item, with no term or prepay
 * discounts. The pickup fee is a one-off per collection.
 */
export { BOX_TYPES, LOOSE_ITEM_CATEGORIES, LOOSE_ITEMS, VEHICLES };

/**
 * Headline trust figures, shown on the about page, the homepage and the
 * pricing CTA.
 *
 * TODO — placeholders inherited from the first build of the site. Replace
 * with audited figures before any paid campaign points at these pages; they
 * are referenced only through these exports.
 */
export const TRUST_STATS = [
  { value: "500+", label: "Happy Clients" },
  { value: "12,000+", label: "Boxes Stored" },
  { value: "4.9", label: "Star Rating" },
  { value: "R0", label: "Items Lost" },
] as const;

/** Customer-count claim used in section headings and CTA copy. */
export const CUSTOMER_COUNT = "2,000+";

/** Cheapest box, for the "from R…" line in page metadata and the social card. */
export const BOX_FROM = Math.min(...BOX_TYPES.map((b) => b.price));

/** Cheapest pickup on offer, quoted as a "from" figure outside the calculator. */
export const PICKUP_FROM = Math.min(...VEHICLES.map((v) => v.price));

/** Cheapest loose item, quoted the same way. */
export const LOOSE_ITEM_FROM = Math.min(...LOOSE_ITEMS.map((i) => i.price));

export const TESTIMONIALS = [
  {
    quote: "StrongBox changed my life in Sea Point. My flat is tiny, but now I can swap my winter gear for my surfboard in minutes. The concierge service is impeccable.",
    name: "Thandi M.",
    initials: "TM",
    location: "Sea Point Resident",
    stars: 5,
  },
  {
    quote: "As an estate agent, I recommend StrongBox to all my clients who are downsizing. They are professional, punctual, and highly secure. Best in Cape Town!",
    name: "Johan K.",
    initials: "JK",
    location: "Verified Customer",
    stars: 5,
  },
  {
    quote: "Storing my collection of rare books was a worry until I found StrongBox. Their humidity-controlled facility and digital inventory give me total confidence.",
    name: "Linda S.",
    initials: "LS",
    location: "Verified Customer",
    stars: 5,
  },
];

export const FAQ_ITEMS = [
  {
    q: "Do you insure my items?",
    a: "No — we store and transport, we are not an insurer, and we do not sell cover. In South Africa this normally sits with your own household contents policy: most insurers will extend it to goods held in storage once you tell them where the items are, often for little or no extra premium. Speak to your insurer or broker before collection day. What we do give you is the record a claim needs — every box is photographed and barcoded to your account at collection, so you have dated evidence of what you handed over and the condition it was in.",
  },
  {
    q: "How quickly can I get my items back?",
    a: "Standard delivery is next-day — request before 12pm and we'll have your items back by end of the following business day. Same-day delivery is available for an additional fee.",
  },
  {
    q: "Do you provide packing materials?",
    a: "Yes! We supply all StrongBox-branded packing boxes, tape, and protective wrap. You can also request our team to pack items for you as an add-on service.",
  },
  {
    q: "Is there a minimum storage period?",
    a: "No minimums. We bill monthly and you can cancel any time. Your items will be returned within 2 business days of cancellation.",
  },
  {
    q: "How do you handle fragile items?",
    a: "Fragile items are wrapped individually, photographed before collection, and stored in climate-controlled zones. Your digital inventory shows exactly how each item was packed.",
  },
  {
    q: "Where is the storage facility located?",
    a: "Our facility is in Kensington, Cape Town — with 24/7 security monitoring, climate control, and humidity management. It is the only one, and we collect from and deliver to the whole of Cape Town from it, so you never need to travel there. The exact address is shared with clients on signup.",
  },
];
