/**
 * StrongBox against the three things a Capetonian actually chooses between
 * when they run out of space.
 *
 * The table is written to be defensible rather than flattering. Competitor
 * figures are market ranges, not quotes, and the `verdict` block below names
 * the cases where another option genuinely wins — a comparison that has us
 * ahead on every row reads as marketing and converts worse than one a reader
 * can check.
 */

export type OptionId = "strongbox" | "self-storage" | "diy" | "removals";

export const OPTIONS: { id: OptionId; label: string; blurb: string; isUs?: boolean }[] = [
  {
    id: "strongbox",
    label: "StrongBox",
    blurb: "Valet storage — we collect, store and return",
    isUs: true,
  },
  {
    id: "self-storage",
    label: "Self-storage unit",
    blurb: "You rent a locker and drive to it",
  },
  {
    id: "diy",
    label: "DIY truck + garage",
    blurb: "Hired bakkie, a friend's spare room",
  },
  {
    id: "removals",
    label: "Removal company storage",
    blurb: "A mover's warehouse, container-billed",
  },
];

export type ComparisonRow = {
  /** Short attribute name, used as the row header. */
  label: string;
  /** Longer framing shown under the label on the full table. */
  detail?: string;
  values: Record<OptionId, string>;
  /**
   * Whether StrongBox is genuinely the strongest answer on this row. Rows set
   * to `false` are the honest ones and are rendered without a highlight.
   */
  weWin: boolean;
  /** Included in the condensed homepage strip. */
  featured?: boolean;
};

export const COMPARISON_ROWS: ComparisonRow[] = [
  {
    label: "What you pay for",
    detail: "The unit of billing, which is where most of the cost difference actually comes from.",
    values: {
      strongbox: "Each box or item you store — nothing for empty space",
      "self-storage": "The whole unit, full or half-empty",
      diy: "Vehicle hire, fuel, and a favour owed",
      removals: "A container or pallet, minimum one",
    },
    weWin: true,
    featured: true,
  },
  {
    label: "Typical monthly cost",
    detail:
      "Cape Town market ranges as at 2026. Ours is our live rate card; the rest are estimates. Per box we are cheaper up to roughly three or four boxes — above that a unit wins on rand.",
    values: {
      strongbox: "R195–R595 per box",
      "self-storage": "R700–R1,800 for the smallest units",
      diy: "R0 after the move — if the space is free",
      removals: "R900–R2,500 per container",
    },
    weWin: false,
    featured: true,
  },
  {
    label: "Collection and delivery",
    values: {
      strongbox: "Included in the pickup fee, booked online",
      "self-storage": "Your problem, every single time",
      diy: "Your problem, plus the driving",
      removals: "Quoted per trip, usually costly",
    },
    weWin: true,
    featured: true,
  },
  {
    label: "Who does the lifting",
    values: {
      strongbox: "Our team, at your door",
      "self-storage": "You, twice",
      diy: "You and whoever you can talk into it",
      removals: "Their team, at their schedule",
    },
    weWin: true,
  },
  {
    label: "Getting one item back",
    detail: "The everyday case: you want the winter duvet, not the whole load.",
    values: {
      strongbox: "Request it in the app, next-day delivery",
      "self-storage": "Drive there and dig through the pile",
      diy: "Depends whose garage it is",
      removals: "Often not possible without unpacking the container",
    },
    weWin: true,
    featured: true,
  },
  {
    label: "Insurance",
    detail:
      "In South Africa the owner insures their own goods in storage, whoever is holding them — usually by extending a household contents policy. None of these four is a substitute for that.",
    values: {
      strongbox: "You insure your own goods; we give you the photo record a claim needs",
      "self-storage": "You insure your own goods; operators often sell or require a policy",
      diy: "Your household policy, if it extends to someone else's garage",
      removals: "You insure your own goods; usually offered as a paid add-on",
    },
    weWin: false,
  },
  {
    label: "Knowing what you stored",
    values: {
      strongbox: "Photo inventory, every box barcoded",
      "self-storage": "Whatever you wrote on the lid",
      diy: "Memory",
      removals: "A manifest, if you asked for one",
    },
    weWin: true,
  },
  {
    label: "Contract and cancellation",
    values: {
      strongbox: "Monthly, cancel anytime — or prepay for a discount",
      "self-storage": "Often a minimum term with a notice period",
      diy: "None",
      removals: "Typically 3–6 months minimum",
    },
    weWin: false,
    featured: true,
  },
  {
    label: "Storing large furniture",
    detail: "Where volume, not convenience, drives the bill.",
    values: {
      strongbox: "Loose items priced by the m³ — fine for a few pieces",
      "self-storage": "Cheapest per m³ once you fill a unit",
      diy: "Free if you have the space",
      removals: "Built for exactly this",
    },
    weWin: false,
  },
  {
    label: "Best for",
    values: {
      strongbox: "Flats and small homes storing boxes and seasonal gear",
      "self-storage": "A full household of furniture, long term",
      diy: "One-off, short term, with space and a strong back",
      removals: "Emigration and long-distance moves",
    },
    weWin: false,
  },
];

/** Rows condensed onto the homepage strip. */
export const FEATURED_ROWS = COMPARISON_ROWS.filter((r) => r.featured);

/**
 * The honest caveat, shown under the table. Naming who we lose to is what
 * makes the rest of the page believable.
 */
export const VERDICT = {
  heading: "When you should not choose us",
  points: [
    {
      title: "You are storing a full house of furniture",
      body: "Past roughly fifteen cubic metres, a self-storage unit is cheaper per cubic metre than paying us by the item. We will tell you that on the phone.",
    },
    {
      title: "You need access several times a week",
      body: "Our returns are next-day. If you are pulling stock or tools out daily, a unit you hold the key to is the right tool.",
    },
    {
      title: "You are moving cities or countries",
      body: "A removal company that stores and ships in one contract will beat splitting the job between us and them.",
    },
  ],
};
