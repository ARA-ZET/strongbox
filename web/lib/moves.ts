import { WHATSAPP_HREF } from "@/lib/constants";

/**
 * Mini moves — small, local furniture moves — as the site describes them.
 *
 * One module, read by the `/mini-moves` page, the homepage band, the pricing
 * page and the service structured data in `lib/seo.ts`, so the three move
 * types are worded the same everywhere and the FAQ markup cannot drift from
 * the answers on screen.
 *
 * Moves are not yet bookable in the app (see `docs/26_MINI_MOVES.md`): every
 * call to action here goes to a person — WhatsApp, phone or the contact form —
 * and nothing quotes a price for the move itself. Admins set prices in the
 * app; until moves have a price list entry, the site says "quoted per move".
 *
 * The operational promises follow the published Terms: we carry, we do not
 * dismantle furniture or remove doors, someone 18+ must be present, and we
 * are not an insurer. Change them here and in the Terms together.
 */

export const MOVES_PATH = "/mini-moves";

/**
 * The three ways a move can end. The split move is the one only a storage
 * company can offer, so it carries the badge.
 */
export const MOVE_TYPES = [
  {
    id: "home-to-home",
    icon: "home",
    name: "Home to home",
    tagline: "From one address to another",
    body: "House to flat, flat to house, or a few streets over. We load at the old address, drive it across and carry it into the new one.",
    bestFor: "Downsizing, moving in together, or a student flat at the start of the year.",
  },
  {
    id: "to-your-storage",
    icon: "warehouse",
    name: "Into your own storage",
    tagline: "Wherever you already keep things",
    body: "Already renting a self-storage unit, or have a garage or a family member's spare room lined up? We deliver to it and carry it in.",
    bestFor: "When you have the space sorted and need the vehicle and the lifting.",
  },
  {
    id: "split",
    icon: "call_split",
    name: "Split: new home and StrongBox storage",
    tagline: "Part to the new place, part into storage",
    badge: "Move + storage",
    body: "What fits goes to your new home. The rest comes to our facility, where every box and piece is photographed, labelled and stored until you ask for it back. The extra stop costs extra; after that, storage is billed monthly like any other.",
    bestFor: "Moving somewhere smaller, or into a place that is not ready yet.",
  },
] as const;

/** Moving day, end to end. Written to match how a storage collection runs. */
export const MOVE_STEPS = [
  {
    title: "Send us the details",
    body: "Both addresses, the date you would like, and what is moving. A list is fine; photos on WhatsApp are better. Mention stairs, lifts and where we can park.",
  },
  {
    title: "Get a quote and a window",
    body: "We quote before anything is booked, then confirm a date and a morning, afternoon or evening window.",
  },
  {
    title: "Moving day",
    body: "We load at the first address, drive it over and carry it in at the other end. Someone aged 18 or over needs to be at each address to hand over and receive.",
  },
  {
    title: "Anything going into storage is tracked",
    body: "On a split move, the part coming to us is scanned and photographed at your door and added to your StrongBox account, exactly like a normal collection.",
  },
] as const;

/** What makes moving day go well. Practical, and Cape Town specific. */
export const MOVE_PREP = [
  {
    icon: "build",
    title: "Take apart beds and flat-pack",
    body: "We carry, load and place furniture, but we do not dismantle or reassemble it. Bed frames, wardrobes and flat-pack need to be in pieces before we arrive.",
  },
  {
    icon: "apartment",
    title: "Book the lift and the time slot",
    body: "Many complexes and apartment blocks want notice of a move, a booked lift or a set time. Check with the body corporate or managing agent, and tell us.",
  },
  {
    icon: "stairs",
    title: "Tell us about access",
    body: "Stairs, narrow passages, a steep driveway or parking far from the door all change how long a move takes. Mention them when you ask for a quote.",
  },
  {
    icon: "kitchen",
    title: "Empty and defrost the fridge",
    body: "Fridges and freezers travel empty. Switch them off the day before so they are dry when we load them.",
  },
  {
    icon: "work",
    title: "Keep valuables with you",
    body: "Cash, jewellery, important documents and laptops are best carried in your own car.",
  },
  {
    icon: "shield",
    title: "Check your insurance",
    body: "We are not an insurer. Most household contents policies cover goods in transit during a move once you tell your insurer about it.",
  },
] as const;

/**
 * The moves FAQ. A function because one answer quotes the live storage price;
 * the page renders these and emits the same list as FAQPage markup.
 */
export function moveFaq(boxFrom: number): { q: string; a: string }[] {
  return [
    {
      q: "What is a mini move?",
      a: "A small, local move that fits in one trip of one of our vehicles: a few pieces of furniture, a room, or a student or bachelor flat. It can go from one address in Cape Town to another, into a storage unit you already use, or be split between your new home and our facility.",
    },
    {
      q: "How much does a mini move cost?",
      a: `Every move is quoted before you book, because three things set the price: the vehicle your load needs, the distance between the addresses, and the carrying at each end, such as stairs, lifts and how far we park from the door. A split move adds a stop at our facility, so it costs a little more than a single drop-off. The stored part is then billed monthly from R${boxFrom} a box, with no minimum term.`,
    },
    {
      q: "Can part of my move go into storage?",
      a: "Yes. That is the move we are built for. Tell us what goes to the new address and what comes to us. The storage part is scanned and photographed at your door, appears in your StrongBox account, and is delivered to you whenever you ask for it.",
    },
    {
      q: "Will you move things into my own self-storage unit?",
      a: "Yes. Give us the facility's address and access hours, and make sure the unit is open or someone with access meets us there.",
    },
    {
      q: "Do you move outside Cape Town?",
      a: "Mini moves run within the City of Cape Town, the same area we collect from for storage, from Bloubergstrand to Gordon's Bay. For a move to another city or province, a long-distance removal company is the better choice.",
    },
    {
      q: "Do you take furniture apart and put it back together?",
      a: "No. We carry, load and place furniture, but we do not dismantle or reassemble it, or remove doors. Please have bed frames, wardrobes and flat-pack in pieces before we arrive.",
    },
    {
      q: "Do I need to be there?",
      a: "Someone aged 18 or over needs to be at each address, one to hand things over and one to receive them. It does not have to be you, as long as you have told us who it will be.",
    },
    {
      q: "Is my furniture insured during the move?",
      a: "We are a transport and storage service, not an insurer, and we do not sell cover. Most household contents policies cover goods in transit during a move if you tell your insurer beforehand. Check with your insurer or broker before moving day.",
    },
    {
      q: "How far ahead should I book?",
      a: "As early as you can. Month-end and the first weekend of the month are the busiest moving days in Cape Town, so those windows go first.",
    },
  ];
}

/**
 * WhatsApp with the questions a quote needs already typed out, so the first
 * message carries the details instead of starting a round of questions.
 */
export const MOVE_WHATSAPP_HREF = `${WHATSAPP_HREF}?text=${encodeURIComponent(
  [
    "Hi StrongBox, I'd like a quote for a mini move.",
    "",
    "Moving from (suburb):",
    "Moving to (suburb, or StrongBox storage):",
    "Preferred date:",
    "What's moving:",
    "Stairs or a lift at either end:",
  ].join("\n")
)}`;

/** The contact form, opened with "Mini move quote" already chosen. */
export const MOVE_CONTACT_HREF = "/contact?subject=move";
