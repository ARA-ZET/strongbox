/**
 * The operational detail a prospect needs before committing, in one place.
 *
 * Everything here is drawn from the specs the product is actually being built
 * to — `docs/02_BUSINESS_RULES.md`, `docs/20_PICKUPS.md`, `docs/21_DELIVERIES.md`
 * — and from the published Terms, rather than invented for the marketing site.
 * If an operational rule changes, it changes here and in the Terms together.
 */

/**
 * Closed vs open boxes. This is a real choice a customer makes per box and it
 * appeared nowhere on the site, despite being the single biggest difference
 * in what the service can do for them.
 */
export const STORAGE_MODES = [
  {
    id: "closed",
    name: "Closed box",
    icon: "inventory_2",
    tagline: "You pack it, we seal it",
    body: "You fill and close the box yourself. We photograph the outside, barcode it to your account, and it stays sealed until it comes back to you. We never open it.",
    bestFor: "Documents, books, winter bedding — anything you will want back in one go.",
    points: [
      "Exterior photograph at collection",
      "One permanent QR label per box",
      "Comes back as a whole box",
    ],
  },
  {
    id: "open",
    name: "Open box",
    icon: "photo_library",
    tagline: "Catalogued item by item",
    body: "We photograph and barcode each item inside before it is stored, so your dashboard lists the contents rather than just the box. You can then ask for one thing back without recalling the rest.",
    bestFor: "Mixed loads, equipment and gear you will dip into over the year.",
    points: [
      "Every item photographed and listed",
      "Request a single item back",
      "Item-level history in your account",
    ],
  },
] as const;

/** Self-identification: the six situations that actually bring people to us. */
export const USE_CASES = [
  {
    icon: "swap_horiz",
    title: "Between leases",
    body: "Your lease ends on the 30th and the new place is only ready on the 5th. We hold the gap so you are not paying double rent or sleeping around your own boxes.",
  },
  {
    icon: "construction",
    title: "Renovating",
    body: "Get the furniture and the breakables out of the dust for a few months, then have them delivered back a room at a time as the work finishes.",
  },
  {
    icon: "home",
    title: "Downsizing",
    body: "Moving somewhere smaller without deciding, today, what you will never use again. Store the maybes and make the call when you are not under time pressure.",
  },
  {
    icon: "ac_unit",
    title: "Seasonal rotation",
    body: "Winter coats and heaters out from October, beach and braai gear out from April. In a Cape Town flat this is the single biggest space gain available.",
  },
  {
    icon: "flight_takeoff",
    title: "Working away or travelling",
    body: "A contract abroad, a long trip, a year at sea. Give up the flat without giving up your things, and have them waiting when you land.",
  },
  {
    icon: "storefront",
    title: "Small business stock",
    body: "Stock, records, event kit and equipment that should not be living in your lounge. Catalogued so you can pull one carton without unpacking the lot.",
  },
] as const;

/** What actually happens on the day, so there are no surprises at the door. */
export const COLLECTION_DAY = [
  {
    icon: "event_available",
    title: "You pick a date and a window",
    body: "Morning (08:00–12:00), afternoon (12:00–17:00) or evening (17:00–20:00). We confirm the window in advance and tell you who is coming.",
  },
  {
    icon: "person",
    title: "Someone over 18 needs to be there",
    body: "To hand the items over and sign for them. It does not have to be you — a housemate, a partner or a building manager is fine, as long as you have told us.",
  },
  {
    icon: "inventory",
    title: "We carry from your door",
    body: "Our team does the lifting from inside your home to the van. We will not dismantle furniture, remove doors, or carry anything where doing so is unsafe.",
  },
  {
    icon: "photo_camera",
    title: "Everything is photographed and scanned in front of you",
    body: "Each box gets its photograph and its QR scan before it goes in the van, so the record of what we took and what condition it was in is made while you are standing there.",
  },
  {
    icon: "draw",
    title: "You sign it off",
    body: "On the driver's device, or by one-time PIN. The job is not marked complete until every box is scanned, photographed and signed for.",
  },
  {
    icon: "schedule",
    title: "It takes about as long as you would think",
    body: "Roughly a quarter of an hour per box, plus half an hour of setup. A dozen boxes is a morning, not a day.",
  },
] as const;

/** The tracking story, which is the answer to "how do I know you won't lose it". */
export const TRACKING_POINTS = [
  {
    icon: "qr_code_2",
    title: "One permanent code per box",
    body: "Every box carries a QR label in the form SBX-0000-A0. It is generated once, tied to that box, and never reused for anything else.",
  },
  {
    icon: "history",
    title: "Every scan is written down",
    body: "Each scan creates a record that cannot be edited or deleted afterwards — who scanned it, when, and what changed. Nothing about your box moves silently.",
  },
  {
    icon: "photo_library",
    title: "Photographed at both ends",
    body: "At least one photograph when we collect and one when we deliver, timestamped and tied to the job, so condition is a matter of record rather than of argument.",
  },
  {
    icon: "shelves",
    title: "A shelf position, not a pile",
    body: "Each box is given a location on the racking when it lands. Retrieval is a scan against a known position, not a search through a stack.",
  },
] as const;

/** Getting things back — the part people most often ask about second. */
export const RETRIEVAL_POINTS = [
  {
    icon: "touch_app",
    title: "Request it in your account",
    body: "Pick the boxes — or, for catalogued boxes, the individual items — choose a date and a window, and confirm the address.",
  },
  {
    icon: "local_shipping",
    title: "Next business day as standard",
    body: "Requests placed before 12:00 come back the next business day. Same-day delivery is available for an extra charge where we have the capacity.",
  },
  {
    icon: "unarchive",
    title: "One item, not the whole load",
    body: "If a box was catalogued when we collected it, you can ask for a single item out of it and leave the rest with us.",
  },
  {
    icon: "block",
    title: "No warehouse visits",
    body: "We do not offer walk-in access to the facility. Everything comes to your door — that is the point of the service.",
  },
] as const;

/**
 * What we will and will not take. Sourced from the Terms so the two cannot
 * drift apart; a prospect who finds out at the door is a cancelled booking.
 */
export const ACCEPTED_ITEMS = [
  "Furniture and mattresses",
  "Clothing, bedding and linen",
  "Books, files and documents",
  "Kitchenware and appliances",
  "Sports gear, bikes and boards",
  "Business stock and equipment",
  "Tools and hobby equipment",
  "Framed art and mirrors",
] as const;

export const PROHIBITED_ITEMS = [
  "Perishable food, of any kind",
  "Live animals or plants",
  "Firearms, ammunition or explosives",
  "Flammable or corrosive substances",
  "Anything illegal",
  "Anything that smells or attracts pests",
] as const;

/** Discouraged rather than banned — worth stating separately and plainly. */
export const AT_OWN_RISK =
  "We ask that you do not send cash, jewellery or irreplaceable documents. If you do, they are held entirely at your own risk, and most household insurance policies will not cover them while they are in storage.";

/** Billing mechanics, in the words a customer would use. */
export const BILLING_POINTS = [
  {
    icon: "calendar_month",
    title: "Billed monthly, in advance",
    body: "You pay for the boxes and items you actually have with us. Add or remove boxes and the bill follows on the next cycle.",
  },
  {
    icon: "lock_open",
    title: "No minimum term",
    body: "There is no lock-in and no notice period. Prepay three, six or twelve months if you want the discount — that is a choice, not a condition.",
  },
  {
    icon: "u_turn_left",
    title: "Cancelling brings everything home",
    body: "Tell us to stop and we return your items within two business days of the final collection charge being settled. Nothing is held hostage.",
  },
  {
    icon: "notifications_active",
    title: "We talk to you before anything stops",
    body: "If an account falls more than 30 days past due we may pause new deliveries, but you can still see everything you have with us, and we will have contacted you first.",
  },
] as const;
