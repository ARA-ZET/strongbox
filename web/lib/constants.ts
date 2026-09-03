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

export const BOX_TYPES = [
  { id: "small", label: "Small Box (45L)", desc: "Documents, books, small tech", price: 195 },
  { id: "medium", label: "Medium Box (80L)", desc: "Clothing, kitchenware", price: 295 },
  { id: "large", label: "Large Box (120L)", desc: "Bulky bedding, winter gear", price: 395 },
  { id: "xl", label: "XL Heavy-Duty Box", desc: "Heavy or oversized boxable items", price: 595 },
] as const;

export const LOOSE_ITEM_CATEGORIES = [
  "All", "Beds", "Tables", "Office", "Appliances", "Outdoor", "Other",
] as const;

export const LOOSE_ITEMS = [
  { id: "dining-table", name: "Dining Table", category: "Tables", icon: "table_restaurant", price: 145 },
  { id: "coffee-table", name: "Coffee Table", category: "Tables", icon: "table_bar", price: 85 },
  { id: "desk", name: "Desk", category: "Office", icon: "desk", price: 110 },
  { id: "tv-stand", name: "TV Stand", category: "Tables", icon: "tv", price: 95 },
  { id: "office-chair", name: "Office Chair", category: "Office", icon: "chair", price: 85 },
  { id: "bookshelf", name: "Bookshelf", category: "Office", icon: "shelves", price: 100 },
  { id: "single-bed", name: "Single Bed", category: "Beds", icon: "single_bed", price: 120 },
  { id: "double-bed", name: "Double Bed", category: "Beds", icon: "bed", price: 175 },
  { id: "queen-bed", name: "Queen Bed", category: "Beds", icon: "king_bed", price: 195 },
  { id: "bicycle", name: "Bicycle", category: "Outdoor", icon: "pedal_bike", price: 110 },
  { id: "surfboard", name: "Surfboard", category: "Outdoor", icon: "surfing", price: 95 },
  { id: "fridge", name: "Fridge", category: "Appliances", icon: "kitchen", price: 195 },
  { id: "washing-machine", name: "Washing Machine", category: "Appliances", icon: "local_laundry_service", price: 175 },
  { id: "mirror", name: "Mirror", category: "Other", icon: "wall_art", price: 75 },
  { id: "golf-bag", name: "Golf Bag", category: "Outdoor", icon: "sports_golf", price: 85 },
  { id: "luggage", name: "Large Suitcase", category: "Other", icon: "luggage", price: 75 },
  { id: "kayak", name: "Kayak", category: "Outdoor", icon: "kayaking", price: 145 },
  { id: "sofa", name: "2-Seater Sofa", category: "Other", icon: "weekend", price: 220 },
] as const;

// `recommended` is declared on every entry so the union stays uniform — the
// calculator reads `v.recommended` directly.
export const VEHICLES = [
  { id: "small-van", label: "Small Van", desc: "Up to 1 m³", price: 250, icon: "airport_shuttle", recommended: false },
  { id: "medium-truck", label: "Medium Truck", desc: "Up to 3 m³", price: 450, icon: "open_in_full", recommended: true },
  { id: "large-fleet", label: "Large Fleet", desc: "Up to 8 m³", price: 850, icon: "local_shipping", recommended: false },
] as const;

/**
 * Prepay commitments. Storage is billed monthly by default; paying a term up
 * front buys a discount on the monthly rate. The pickup fee is a one-off and
 * is never discounted, so it sits outside this.
 *
 * TODO — the discount percentages are a proposal, not signed-off numbers.
 * They are read by `PrepayToggle` and both calculators and appear nowhere
 * else, so changing them here changes them everywhere.
 */
export const PREPAY_TIERS = [
  { id: "monthly", label: "Monthly", months: 1, discount: 0, note: "Cancel anytime" },
  { id: "quarterly", label: "3 months", months: 3, discount: 0.05, note: "Save 5%" },
  { id: "biannual", label: "6 months", months: 6, discount: 0.1, note: "Save 10%" },
  { id: "annual", label: "12 months", months: 12, discount: 0.2, note: "Save 20%" },
] as const;

export type PrepayTier = (typeof PREPAY_TIERS)[number];

/** The default — what an unqualified "R195/mo" on the site refers to. */
export const DEFAULT_TIER = PREPAY_TIERS[0];

/** Deepest discount available, for the "save up to X%" line. */
export const MAX_PREPAY_SAVING = Math.max(...PREPAY_TIERS.map((t) => t.discount));

/** Monthly rate after a tier's prepay discount, rounded to the rand. */
export function tierMonthly(monthly: number, tier: PrepayTier): number {
  return Math.round(monthly * (1 - tier.discount));
}

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
