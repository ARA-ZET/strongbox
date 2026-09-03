import type { IllustrationName } from "@/components/graphics/Illustration";

/**
 * The guides library, as plain data.
 *
 * Kept as typed records rather than MDX so the site keeps its zero-runtime-
 * dependency footprint and every article renders through one reviewed layout.
 * Adding a guide means adding an entry here — the index page, the article
 * route and the sitemap all read from this array.
 */

export type ArticleSection = {
  heading: string;
  paragraphs: string[];
  /** Optional bullet list rendered after the paragraphs. */
  list?: string[];
};

export type Article = {
  slug: string;
  title: string;
  /** Shown on the index card and used as the page description. */
  excerpt: string;
  category: string;
  readMinutes: number;
  /** ISO date. Rendered as "Updated <month year>". */
  updated: string;
  illustration: IllustrationName;
  intro: string;
  sections: ArticleSection[];
  /** Related internal links shown at the foot of the article. */
  related?: { href: string; label: string }[];
};

export const ARTICLES: Article[] = [
  {
    slug: "moving-out-checklist",
    title: "The Cape Town moving-out checklist",
    excerpt:
      "Six weeks of ordered steps, from giving notice to handing back the keys — with the bits people forget, like the municipal account and the geyser.",
    category: "Moving",
    readMinutes: 7,
    updated: "2026-07-14",
    illustration: "checklist",
    intro:
      "Most moving stress is scheduling stress. The lifting is one bad day; the fortnight of half-finished admin either side is what actually ruins the month. This is the order we have watched work, built around the dates that are fixed for you — your notice period and your handover — rather than the ones you can move.",
    sections: [
      {
        heading: "Six weeks out — lock the fixed dates",
        paragraphs: [
          "Two dates are not yours to choose: the day your lease ends and the day you can get into the next place. Everything else arranges itself around the gap between them, and that gap is where storage either saves you or costs you.",
        ],
        list: [
          "Give written notice, and keep the acknowledgement — a calendar month is standard in South Africa, but read the clause.",
          "Book the movers or the bakkie. Month-end and the first weekend of the month are the worst and priciest slots in Cape Town.",
          "If the two dates do not meet, decide now whether you are storing or paying double rent for a fortnight.",
        ],
      },
      {
        heading: "Four weeks out — decide what is actually coming",
        paragraphs: [
          "This is the only step that reduces the size of the job. Everything else just reorganises it. Work room by room and put each thing into one of four piles: coming with you, going into storage, being sold or given away, being thrown out.",
          "Be blunt about the storage pile. If you cannot say when you would next use something, that is a sell decision wearing a storage costume.",
        ],
      },
      {
        heading: "Three weeks out — the admin nobody remembers",
        paragraphs: [
          "These are the items that generate a phone call two months later, usually about money.",
        ],
        list: [
          "Municipal account: request a final reading and closure, and photograph the meters on handover day.",
          "Fibre and DStv: transfers take longer than the move does. Start now.",
          "Change of address: bank, medical aid, insurer, SARS, the vehicle licence department, and your car and household policies — an out-of-date address can void a claim.",
          "Domestic staff and gardeners: give proper notice or arrange the handover to the new owners.",
        ],
      },
      {
        heading: "Two weeks out — pack the storage pile first",
        paragraphs: [
          "Anything going into storage is by definition something you will not need before the move, so it can be boxed and out of the way while you still have room to work. Label by room and by contents, not just by room — 'kitchen' on six boxes tells you nothing in November.",
          "Photograph anything valuable before it is wrapped. It takes a minute and settles any question later.",
        ],
      },
      {
        heading: "Moving week — the box that stays with you",
        paragraphs: [
          "Pack one box, clearly marked, that does not go on the truck: kettle, mugs, phone chargers, toilet paper, cleaning cloths, medication, a toolset, and the documents for the new place. It is the difference between a first night and a first ordeal.",
        ],
      },
      {
        heading: "Handover day",
        paragraphs: [
          "Do the walkthrough with the agent rather than after them, and photograph every room once it is empty. Meter readings, keys, remotes, gate tags and alarm codes all get counted and signed for. That photo set is what protects your deposit.",
        ],
      },
    ],
    related: [
      { href: "/how-it-works", label: "How collection and return actually work" },
      { href: "/tools/savings-calculator", label: "What storage will cost you for the gap" },
    ],
  },
  {
    slug: "small-space-decluttering",
    title: "Decluttering a small Cape Town flat",
    excerpt:
      "A room-by-room method for flats where there is no garage to hide things in — and an honest rule for what deserves to be stored rather than sold.",
    category: "Organising",
    readMinutes: 6,
    updated: "2026-06-02",
    illustration: "questions",
    intro:
      "Advice written for suburban houses assumes a garage, a loft and a spare room. A one-bedroom in Sea Point or Observatory has none of those, which means every object is competing for space you actively live in. The method below is built for that constraint: decide by frequency of use, not by sentiment, and get the seasonal things out of the room entirely.",
    sections: [
      {
        heading: "Start with the surfaces, not the cupboards",
        paragraphs: [
          "Clear horizontal surfaces first — counters, the dining table, the floor beside the bed. It is the fastest visible change, and in a small flat the visual relief is what gives you the appetite to keep going. Cupboards are a three-hour job; a counter is twenty minutes.",
        ],
      },
      {
        heading: "The twelve-month test",
        paragraphs: [
          "For each item ask one question: have I used this in the last twelve months, and will I use it in the next twelve? Two noes is a sell or donate. One yes and one no is usually a storage item — the ski gear, the camping kit, the baby equipment you are keeping for a second child.",
          "The trap is the maybe pile. A maybe pile is a decision you have deferred at the cost of the floor space it sits on. Put a date on it: if you have not reached for it by then, it goes.",
        ],
      },
      {
        heading: "Seasonal rotation is the whole trick",
        paragraphs: [
          "Cape Town has two genuinely different wardrobes and two sets of gear. Winter coats, heaters and duvets are dead weight from October to April; the fans, the beach kit and the braai things are dead weight the rest of the year.",
          "Rotating half of that out of the flat and back again is the single biggest space gain available to a small home, and it is precisely the case valet storage is built for — the swap happens at your door rather than in a rented van.",
        ],
        list: [
          "Winter: coats, heaters, thick bedding, wet-weather gear.",
          "Summer: fans, beach and braai kit, camping equipment, sports gear.",
          "Year-round candidates: documents, books, inherited furniture, hobby equipment between projects.",
        ],
      },
      {
        heading: "Sentimental things get a budget, not an exemption",
        paragraphs: [
          "Nobody should throw out their grandmother's letters to save a shelf. But sentiment expands to fill whatever space it is allowed, so give it a fixed allocation — one box, or two — and make things compete for a place in it. What does not fit gets photographed and let go.",
        ],
      },
      {
        heading: "Do not buy storage furniture to solve this",
        paragraphs: [
          "Ottomans with hollow bases and under-bed drawers convert clutter into hidden clutter while taking up floor area themselves. In a flat under about 60 m², the maths rarely works. Reduce the volume first; only then decide whether anything needs a new container.",
        ],
      },
    ],
    related: [
      { href: "/loose-items", label: "What it costs to store bigger items" },
      { href: "/resources/packing-a-box-that-lasts", label: "Packing a box that survives storage" },
    ],
  },
  {
    slug: "what-self-storage-really-costs",
    title: "What a self-storage unit really costs in Cape Town",
    excerpt:
      "The rent is roughly half the bill. Here is the rest of it — access fees, insurance, the deposit, and the drive — and when a unit is still the right answer.",
    category: "Costs",
    readMinutes: 8,
    updated: "2026-08-11",
    illustration: "pricing",
    intro:
      "Self-storage is advertised on a monthly rent, and the rent is the part that is easiest to compare and least likely to be the whole number. This is what the twelve-month figure usually looks like once the rest of it is on the page — and, since we sell the alternative, the cases where a unit still beats us.",
    sections: [
      {
        heading: "The advertised rent",
        paragraphs: [
          "Cape Town self-storage runs from roughly R750 a month for a small locker to around R1,950 for a large unit, with the wide variation driven by suburb and by how close to the N1 you are. Introductory rates of 50% off the first two months are common — and the rate that matters is the one in month three.",
        ],
      },
      {
        heading: "The bits that are not the rent",
        paragraphs: [
          "None of these are hidden exactly; they are just not on the billboard.",
        ],
        list: [
          "A deposit, typically one month, held until you vacate.",
          "Insurance, often compulsory, sometimes only available through the operator.",
          "A padlock and, at some sites, an access card fee.",
          "Annual escalation, usually somewhere between 6% and 10%.",
          "A notice period on the way out — leaving on short notice can mean paying for a month you do not use.",
        ],
      },
      {
        heading: "The drive is a real cost",
        paragraphs: [
          "A 25 km return trip costs roughly R95 in fuel and wear. Two trips a month is R2,280 over a year, which is often more than the difference between two unit sizes — and it does not price your Saturday morning at anything at all.",
          "This is the line item people leave out when they compare, and it is the one that most reliably changes the answer.",
        ],
      },
      {
        heading: "The empty-space problem",
        paragraphs: [
          "A unit is billed by the locker. If your things fill 60% of the smallest unit that fits them, you are paying full rent for 40% air, every month, for as long as you keep it. That is the structural difference from paying by the box, and it does not go away with negotiation.",
        ],
      },
      {
        heading: "When a unit is still the right call",
        paragraphs: [
          "Three cases, and we lose all of them.",
        ],
        list: [
          "You are storing a full household of furniture. Past roughly fifteen cubic metres a unit is cheaper per cubic metre than paying by the item.",
          "You need access several times a week — a workshop, tools, or stock for a small business.",
          "You want to keep a vehicle, trailer or boat somewhere, which valet storage does not do at all.",
        ],
      },
    ],
    related: [
      { href: "/tools/savings-calculator", label: "Run your own numbers" },
      { href: "/compare", label: "The full four-way comparison" },
    ],
  },
  {
    slug: "packing-a-box-that-lasts",
    title: "How to pack a box that survives a year in storage",
    excerpt:
      "Weight distribution, what actually causes damage in storage, and the five things that should never go into a sealed box in the first place.",
    category: "Practical",
    readMinutes: 5,
    updated: "2026-05-20",
    illustration: "package-arrived",
    intro:
      "Almost nothing is damaged in storage by the storage. It is damaged in the handling either side, or by being sealed in with something it should not have been sealed in with. Both are avoidable in the ten minutes it takes to pack a box properly.",
    sections: [
      {
        heading: "Heavy things go in small boxes",
        paragraphs: [
          "The instinct is the opposite — big box, fill it up — and it is how boxes fail. Books, tools and crockery go in the smallest box available; bedding, cushions and clothing go in the large ones. A box you cannot lift comfortably will be dropped by somebody eventually, and a box that flexes in the middle will collapse the one below it on a shelf.",
          "Aim for around 15 kg as an upper limit, whatever the size.",
        ],
      },
      {
        heading: "Fill the gaps, square off the top",
        paragraphs: [
          "Empty space inside a box is what lets contents move, and movement is what breaks things. Pack to the top and fill the voids — clothing and towels work as well as paper and are already going into storage anyway.",
          "A box packed flat to the top stacks. A bulging one does not, and whatever goes on top of it slides off.",
        ],
      },
      {
        heading: "The five things that should not go in",
        paragraphs: ["These are the ones that cause problems weeks later, from inside the box."],
        list: [
          "Anything liquid — cosmetics, cleaning products, half-used paint. Temperature swings push liquids past their seals.",
          "Food of any kind, including sealed and dried. It is what attracts pests to an otherwise clean facility.",
          "Batteries left in devices — remote controls, torches, toys. They leak and destroy the thing they are inside.",
          "Anything damp. A towel that felt dry after a beach trip is enough to mildew a box of linen over a season.",
          "Candles and anything wax-based, which slump in a warm month and never recover their shape.",
        ],
      },
      {
        heading: "Label for the person opening it in November",
        paragraphs: [
          "Write the contents on two adjacent sides, not the lid — on a shelf the lid is the one face nobody can see. 'Kitchen — pots, colander, mixing bowls' is a label; 'kitchen' is a shrug.",
          "If your boxes are with us, the photo inventory does this job for you: every box is photographed and barcoded to your account, so retrieval is a search rather than a memory test.",
        ],
      },
      {
        heading: "Electronics, art and timber",
        paragraphs: [
          "Screens travel upright, never flat, and keep their original box if you have it. Framed art goes on edge with corner protection, never stacked face-down. Solid timber is the one thing genuinely at risk from the storage environment itself rather than the handling — which is why humidity control is worth asking any operator about before you sign.",
        ],
      },
    ],
    related: [
      { href: "/about", label: "How our facility is monitored and climate-managed" },
      { href: "/pricing", label: "Box sizes and what each one costs" },
    ],
  },
];

export function getArticle(slug: string): Article | undefined {
  return ARTICLES.find((a) => a.slug === slug);
}

/** Formats an article's `updated` date as "July 2026". */
export function formatUpdated(iso: string): string {
  return new Date(iso).toLocaleDateString("en-ZA", { month: "long", year: "numeric" });
}
