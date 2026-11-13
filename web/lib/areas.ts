/**
 * Where we collect and deliver, grouped the way Capetonians actually describe
 * where they live.
 *
 * One facility (Kensington), whole-metro coverage. Each region gets its own
 * page at /areas/[slug], so every entry here must carry copy that is genuinely
 * about that part of the city — housing, access, the reasons people there
 * store — and not the same paragraph with the name swapped. Near-identical
 * location pages are what Google classes as doorway pages; distinct ones are
 * what earn a suburb search.
 *
 * Read by: the areas hub and region pages, the suburb checker, the contact
 * page, the footer, `SERVICE_AREAS` in `lib/constants.ts`, and `areaServed`
 * in the structured data. Add a suburb here and all of them pick it up.
 *
 * Nothing in this file may promise a different price, window or fee by area:
 * the collection fee depends on the vehicle, not the suburb.
 */

export type Region = {
  slug: string;
  /** As a title or link label: "Southern Suburbs". */
  name: string;
  /** As a phrase in a sentence, with its own preposition: "on the Cape Flats". */
  where: string;
  /** Short line for cards and the checker result. */
  summary: string;
  suburbs: readonly string[];
  /** Region page opening, two short paragraphs. */
  intro: readonly [string, string];
  /** Practicalities of collecting here — what we plan around. */
  onTheDay: readonly string[];
  /** The situations that most often bring people from this area to us. */
  reasons: readonly { icon: string; title: string; body: string }[];
};

export const REGIONS: readonly Region[] = [
  {
    slug: "atlantic-seaboard",
    name: "Atlantic Seaboard",
    where: "on the Atlantic Seaboard",
    summary: "Flats and apartment blocks from Mouille Point to Bakoven.",
    suburbs: [
      "Sea Point", "Green Point", "Mouille Point", "Three Anchor Bay", "Fresnaye",
      "Bantry Bay", "Clifton", "Camps Bay", "Bakoven", "V&A Waterfront",
    ],
    intro: [
      "Most homes on the Seaboard are flats, and most flats here were built before anyone owned a surfboard, a bike and a pram at the same time. There is no garage, the storeroom is a shared one in the basement, and every square metre you give to winter gear is one you are paying Seaboard rent for.",
      "We collect from your door, store everything in Kensington, and bring it back when you ask. You never have to find parking on Main Road with a carload of boxes.",
    ],
    onTheDay: [
      "Tell us if your building needs the lift booked or a move-in form signed — we will match our window to the slot the body corporate gives you.",
      "Street parking is tight, so let us know where a van can stop: a loading bay, the driveway, or the visitor bay.",
      "Holiday lets and Airbnbs are welcome. Someone over 18 has to be there to sign, but it does not have to be you.",
    ],
    reasons: [
      { icon: "ac_unit", title: "Seasonal swaps", body: "Wetsuits and beach kit out of the flat in winter, heaters and duvets out in summer." },
      { icon: "home_work", title: "Letting the flat out", body: "Clear the personal things out before tenants or guests arrive, and have them back when you return." },
      { icon: "swap_horiz", title: "Between leases", body: "Seaboard leases rarely line up to the day. We hold the gap so you do not pay for two flats." },
    ],
  },
  {
    slug: "city-bowl",
    name: "City Bowl",
    where: "in the City Bowl",
    summary: "Cottages, apartments and steep streets under the mountain.",
    suburbs: [
      "Cape Town CBD", "Gardens", "Tamboerskloof", "Oranjezicht", "Vredehoek",
      "Higgovale", "De Waterkant", "Bo-Kaap", "Zonnebloem", "University Estate",
    ],
    intro: [
      "City Bowl homes are either old cottages with narrow passages and no storage, or new apartments with plenty of glass and not much cupboard. Either way, the spare room is usually also the study, the gym and the guest room.",
      "We take what you are not using this season off your hands and bring it back to your door when you want it. There is no unit across town to visit.",
    ],
    onTheDay: [
      "Steep streets and stairs are normal here. Tell us about stairs or a long walk from the kerb when you book so we bring enough hands.",
      "For CBD apartment blocks, let us know the loading-bay rules and any booking the building manager needs.",
      "Morning, afternoon or evening windows. Evenings work well if you are at the office all day.",
    ],
    reasons: [
      { icon: "construction", title: "Renovating an old house", body: "Get furniture out of the dust while the floors or the kitchen are done, then have it back a room at a time." },
      { icon: "storefront", title: "Small business stock", body: "Stock, samples and event kit that should not be living in a city apartment." },
      { icon: "flight_takeoff", title: "Working away", body: "Give up the flat for a contract abroad without selling everything you own." },
    ],
  },
  {
    slug: "southern-suburbs",
    name: "Southern Suburbs",
    where: "in the Southern Suburbs",
    summary: "From Observatory and Rondebosch to Constantia and Tokai.",
    suburbs: [
      "Woodstock", "Salt River", "Observatory", "Mowbray", "Rosebank", "Rondebosch",
      "Newlands", "Claremont", "Kenilworth", "Wynberg", "Plumstead", "Diep River",
      "Bergvliet", "Meadowridge", "Constantia", "Tokai", "Retreat", "Kirstenhof",
    ],
    intro: [
      "The Southern Suburbs run from student accommodation in Obs and Rondebosch to family homes in Bergvliet and Constantia, and the storage problem changes along the way. Near campus it is a student moving out every December. Further south it is a family house being renovated, or a parent downsizing.",
      "Winter is wet on this side of the mountain, and Newlands is among the wettest places in the city. Garages and outside storerooms get damp. Our facility is climate-controlled, so boxes do not spend July soaking up moisture.",
    ],
    onTheDay: [
      "Shared accommodation is fine. Each student can have their own account and their own boxes, all collected on the same visit.",
      "Security estates and complexes: give us the gate or guardhouse details so the driver is not stuck at the boom.",
      "If the house is being renovated, tell us what is coming back first. We return it room by room as the work finishes.",
    ],
    reasons: [
      { icon: "school", title: "Students over the long break", body: "Clear the room at the end of the year and have your things delivered to the new place in February." },
      { icon: "construction", title: "Renovations and extensions", body: "Furniture and breakables out of the way for the builders, back when the dust settles." },
      { icon: "home", title: "Downsizing the family home", body: "Store the things you are not ready to decide on, and decide later without a deadline." },
    ],
  },
  {
    slug: "south-peninsula",
    name: "Hout Bay & South Peninsula",
    where: "in Hout Bay and on the South Peninsula",
    summary: "Hout Bay, Muizenberg, Fish Hoek, Noordhoek and Simon's Town.",
    suburbs: [
      "Hout Bay", "Lakeside", "Marina da Gama", "Muizenberg", "St James", "Kalk Bay",
      "Fish Hoek", "Clovelly", "Sun Valley", "Noordhoek", "Kommetjie", "Simon's Town",
    ],
    intro: [
      "Down the peninsula, a storage unit means a long drive: over Ou Kaapse Weg, along Main Road, or out of Hout Bay on its only two roads. Do it twice a month and the drive costs more than the unit.",
      "We do the drive for you. Your things are collected from your door and come back to your door. The collection fee depends on the size of the vehicle, not on how far down the coast you live.",
    ],
    onTheDay: [
      "Sea air is hard on metal and timber. Make sure bikes, tools and wooden furniture are dry when we collect, and they will stay that way in storage.",
      "Surfboards, kayaks and bikes are priced as loose items. You do not need a box for them.",
      "Plots and smallholdings in Noordhoek and Kommetjie: give us a pin and tell us if the driveway is gravel.",
    ],
    reasons: [
      { icon: "surfing", title: "Ocean and outdoor gear", body: "Boards, wetsuits, kayaks and camping kit out of the house in the off-season." },
      { icon: "home_work", title: "Holiday-letting the house", body: "Lock away the personal things before the summer let and get them back when it ends." },
      { icon: "home", title: "Retiring and downsizing", body: "Moving to something smaller without choosing, this week, what goes for good." },
    ],
  },
  {
    slug: "northern-suburbs",
    name: "Northern Suburbs",
    where: "in the Northern Suburbs",
    summary: "Pinelands to Durbanville, Bellville, Brackenfell and Kraaifontein.",
    suburbs: [
      "Kensington", "Maitland", "Brooklyn", "Pinelands", "Thornton", "Goodwood",
      "Parow", "Edgemead", "Bothasig", "Plattekloof", "Panorama", "Welgemoed",
      "Bellville", "Tyger Valley", "Durbanville", "Brackenfell", "Kuils River", "Kraaifontein",
    ],
    intro: [
      "Our facility is in Kensington, on this side of the city, so the Northern Suburbs are close by. Homes here range from freestanding family houses to townhouse complexes where the garage holds the car and the second car parks outside.",
      "Many people moving to Cape Town from Gauteng settle here first. If you are renting while you look for a place to buy, we can hold what does not fit until you find it.",
    ],
    onTheDay: [
      "Townhouse and security complexes: send the access details with the booking so the driver is let in without a phone call.",
      "If you have just arrived from up-country, we can collect straight from your temporary rental.",
      "You do not need a car or a trailer. That is the point of the service.",
    ],
    reasons: [
      { icon: "flight_land", title: "Moving to Cape Town", body: "Rent first, buy later. Your extra furniture waits with us while you find the right house." },
      { icon: "family_restroom", title: "Making room at home", body: "A baby on the way, a parent moving in, or a teenager who needs their own room." },
      { icon: "storefront", title: "Stock and records", body: "Business stock, files and equipment, catalogued so you can ask for one carton back." },
    ],
  },
  {
    slug: "blouberg-west-coast",
    name: "Blouberg & West Coast",
    where: "in Blouberg and on the West Coast",
    summary: "Milnerton and Century City up to Table View, Parklands and Melkbos.",
    suburbs: [
      "Century City", "Milnerton", "Sunset Beach", "Table View", "Bloubergstrand",
      "Big Bay", "Parklands", "Sunningdale", "Melkbosstrand", "Montague Gardens", "Atlantis",
    ],
    intro: [
      "Much of the West Coast is newer development: apartments in Century City and Big Bay, and townhouses in Parklands and Sunningdale that were built with a small garage and a smaller storeroom. Many of the people living here are new to Cape Town.",
      "The south-easter blows sand and salt into every garage on this coast. Boxes stored with us stay clean and dry, and you get them back when you ask.",
    ],
    onTheDay: [
      "New estates are not always on the map yet. Drop a pin when you book and add the gate code or guardhouse instructions.",
      "Kitesurf and beach gear is welcome. Store boards and bikes as loose items.",
      "Apartment blocks in Century City and Big Bay often need a lift booking. Tell us the slot and we will plan around it.",
    ],
    reasons: [
      { icon: "flight_land", title: "Just moved here", body: "Shipped a whole Joburg house into a smaller coastal place? Store the extra while you settle." },
      { icon: "kitesurfing", title: "Wind and water sports", body: "Kites, boards and wetsuits out of the lounge when the season ends." },
      { icon: "swap_horiz", title: "Between homes", body: "Transfer delays and occupation dates that do not line up. We hold the gap." },
    ],
  },
  {
    slug: "cape-flats",
    name: "Cape Flats",
    where: "on the Cape Flats",
    summary: "Athlone, Gugulethu, Langa, Grassy Park and the suburbs between.",
    suburbs: [
      "Athlone", "Rylands", "Gatesville", "Crawford", "Lansdowne", "Langa", "Bonteheuwel",
      "Bishop Lavis", "Elsies River", "Manenberg", "Hanover Park", "Gugulethu", "Nyanga",
      "Belhar", "Ottery", "Wetton", "Grassy Park", "Lotus River", "Pelican Park",
    ],
    intro: [
      "Homes on the Cape Flats often hold more than one household. Grandparents, children and grandchildren share the space, a back room gets built when the family grows, and furniture moves around as people move in and out.",
      "When you need a room cleared — for a relative, for building work, or for a function at home — we collect what has to move and bring it back when you are ready. The price is the same here as anywhere else in the city.",
    ],
    onTheDay: [
      "Building an extension? Tell us when the builders start and when they finish. We collect before and deliver back after.",
      "Anyone over 18 that you name can hand over and sign: a parent, an aunt, a neighbour you trust.",
      "Pay monthly by EFT against an invoice. You do not need a credit card.",
    ],
    reasons: [
      { icon: "construction", title: "Building or extending", body: "Furniture and appliances out of harm's way while the back room or second storey goes up." },
      { icon: "family_restroom", title: "Family moving in or out", body: "Make space for someone coming home, or keep a relative's things safe while they are away." },
      { icon: "celebration", title: "Hosting at home", body: "Clear the lounge for a wedding, a funeral or a big family gathering, and have it put back after." },
    ],
  },
  {
    slug: "mitchells-plain-khayelitsha",
    name: "Mitchells Plain & Khayelitsha",
    where: "in Mitchells Plain, Khayelitsha and surrounds",
    summary: "Mitchells Plain, Khayelitsha, Philippi, Delft, Blue Downs and Eerste River.",
    suburbs: [
      "Mitchells Plain", "Strandfontein", "Philippi", "Khayelitsha", "Delft", "Blue Downs",
      "Eerste River", "Mfuleni", "Kleinvlei", "Blackheath",
    ],
    intro: [
      "Families here use every room, and one room is often a business too: a salon, a tuck shop, or a stock room for something sold online or at the market. When stock, furniture and family all share one house, something has to give.",
      "We collect from your door and keep things in our monitored facility in Kensington. Each box is photographed and tracked in your account, and you can ask for it back whenever you need it. The collection fee depends on the vehicle you need, not where you live.",
    ],
    onTheDay: [
      "Give us a pin or a landmark when you book. Street numbers are not always easy to find, so we will phone or WhatsApp you on the way.",
      "If you run a business from home, open boxes let you ask for a single carton of stock back.",
      "Pay monthly by EFT using the reference on your invoice. You do not need a credit card.",
    ],
    reasons: [
      { icon: "storefront", title: "Stock for a home business", body: "Keep stock safe and out of the house, and get back only the cartons you need." },
      { icon: "construction", title: "Building or extending", body: "Clear rooms before the builders arrive and have everything returned when the work is done." },
      { icon: "family_restroom", title: "A full house", body: "Make room when family moves in, and keep a relative's furniture until they need it again." },
    ],
  },
  {
    slug: "helderberg",
    name: "Helderberg",
    where: "in the Helderberg",
    summary: "Somerset West, Strand, Gordon's Bay and Sir Lowry's Pass.",
    suburbs: [
      "Somerset West", "Strand", "Gordon's Bay", "Firgrove", "Macassar", "Sir Lowry's Pass",
    ],
    intro: [
      "The Helderberg is still Cape Town, even if it feels like its own town. Many people retire here, many semigrate here, and many families move into new estates where the houses are bigger than the flat they left but have less storage than they expected.",
      "We collect from your door and bring things back when you ask, so you are not driving an hour on the N2 to visit a unit.",
    ],
    onTheDay: [
      "Most Helderberg estates have controlled access. Send the gate details with your booking.",
      "Strand and Gordon's Bay are windy. Tape boxes properly and keep anything salty or sandy out of a sealed box.",
      "You can book a morning, afternoon or evening window, the same as the rest of the city.",
    ],
    reasons: [
      { icon: "home", title: "Downsizing into retirement", body: "Move into the smaller place now and decide about the rest of the furniture later." },
      { icon: "flight_land", title: "Semigrating", body: "Arriving from Gauteng into a rental first. Keep the rest stored while you find a home to buy." },
      { icon: "ac_unit", title: "Seasonal gear", body: "Beach and camping kit in winter, heaters and blankets in summer, out of the garage." },
    ],
  },
];

export function getRegion(slug: string): Region | undefined {
  return REGIONS.find((r) => r.slug === slug);
}

/** Every suburb with the region it belongs to — what the checker searches. */
export const SUBURB_INDEX: readonly { suburb: string; region: Region }[] = REGIONS.flatMap(
  (region) => region.suburbs.map((suburb) => ({ suburb, region }))
);

/** Case-, accent- and punctuation-insensitive form for matching typed input. */
export function normaliseSuburb(s: string): string {
  return s
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    // Drop apostrophes rather than spacing them, so "simons town" finds "Simon's Town".
    .replace(/['’]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();
}
