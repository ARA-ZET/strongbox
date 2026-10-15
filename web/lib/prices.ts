import { cache } from "react";

import { DEFAULT_PRICES } from "./pricing.g";
import { ICON_NAMES } from "./icons";

/**
 * The live price list.
 *
 * Admins set prices in the app (Admin → Pricing), which writes the Firestore
 * document `priceLists/{tenantId}`. The Flutter app listens to that document;
 * this module reads it for the site through Firestore's public REST API — the
 * doc is world-readable, so no key or SDK is needed — and caches it for
 * PRICE_REVALIDATE_SECONDS, so a published change reaches every page within
 * about five minutes without a redeploy.
 *
 * Until an admin first publishes, or if Firestore is unreachable or returns
 * something malformed, the site falls back to DEFAULT_PRICES (generated from
 * packages/pricing/pricing.json) — it never renders without prices.
 *
 * Server-only: call getPrices() in a server component, page, metadata or
 * route, and pass the result to client components as a prop.
 */

export const PRICE_REVALIDATE_SECONDS = 300;

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? "strongbox-app";
const TENANT_ID = process.env.STRONGBOX_TENANT_ID ?? "strongbox-default";
const DOC_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/priceLists/${TENANT_ID}`;

export type BoxType = { id: string; label: string; desc: string; price: number };
export type LooseItem = {
  id: string;
  name: string;
  category: string;
  icon: string;
  price: number;
};
export type Vehicle = {
  id: string;
  label: string;
  desc: string;
  capacityM3: number;
  price: number;
  recommended: boolean;
  icon: string;
};

export type Prices = {
  /** Only entries on sale — retired ones are dropped here. */
  boxes: BoxType[];
  /** Filter chips for /loose-items; always starts with "All". */
  looseItemCategories: string[];
  looseItems: LooseItem[];
  vehicles: Vehicle[];
  /** Cheapest box, for "from R…" copy. */
  boxFrom: number;
  looseItemFrom: number;
  pickupFrom: number;
};

type Raw = Record<string, unknown>;

/* ---- Firestore REST value decoding ---------------------------------- */

type FsValue = {
  stringValue?: string;
  integerValue?: string;
  doubleValue?: number;
  booleanValue?: boolean;
  nullValue?: null;
  arrayValue?: { values?: FsValue[] };
  mapValue?: { fields?: Record<string, FsValue> };
};

function decode(v: FsValue): unknown {
  if ("stringValue" in v) return v.stringValue;
  if ("integerValue" in v) return Number(v.integerValue);
  if ("doubleValue" in v) return v.doubleValue;
  if ("booleanValue" in v) return v.booleanValue;
  if ("arrayValue" in v) return (v.arrayValue?.values ?? []).map(decode);
  if ("mapValue" in v) return decodeFields(v.mapValue?.fields ?? {});
  return null;
}

function decodeFields(fields: Record<string, FsValue>): Raw {
  return Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, decode(v)]));
}

/* ---- validation ------------------------------------------------------ */

const str = (v: unknown) => (typeof v === "string" ? v.trim() : "");
const price = (v: unknown) =>
  typeof v === "number" && Number.isFinite(v) && v > 0 ? Math.round(v) : 0;
const onSale = (r: Raw) => r.active !== false;
const list = (v: unknown): Raw[] =>
  Array.isArray(v) ? v.filter((x): x is Raw => !!x && typeof x === "object") : [];

// Only glyphs the site bundles (lib/icons.ts) can render; anything else would
// show as its literal name.
const BUNDLED_ICONS = new Set<string>(ICON_NAMES);

function normalise(raw: Raw): Prices | null {
  const boxes: BoxType[] = list(raw.boxes)
    .filter(onSale)
    .map((b) => ({ id: str(b.id), label: str(b.label), desc: str(b.desc), price: price(b.price) }))
    .filter((b) => b.id && b.label && b.price);

  const looseItems: LooseItem[] = list(raw.looseItems)
    .filter(onSale)
    .map((i) => ({
      id: str(i.id),
      name: str(i.name),
      category: str(i.category) || "Other",
      icon: BUNDLED_ICONS.has(str(i.icon)) ? str(i.icon) : "inventory_2",
      price: price(i.price),
    }))
    .filter((i) => i.id && i.name && i.price);

  const vehicles: Vehicle[] = list(raw.vehicles)
    .filter(onSale)
    .map((v) => ({
      id: str(v.id),
      label: str(v.label),
      desc: str(v.desc),
      capacityM3: typeof v.capacityM3 === "number" ? v.capacityM3 : 0,
      price: price(v.price),
      recommended: v.recommended === true,
      icon: BUNDLED_ICONS.has(str(v.icon)) ? str(v.icon) : "local_shipping",
    }))
    .filter((v) => v.id && v.label && v.price);

  // Calculators need at least one of each to render.
  if (!boxes.length || !vehicles.length) return null;

  const declared = Array.isArray(raw.looseItemCategories)
    ? raw.looseItemCategories.map(str).filter(Boolean)
    : [];
  const categories = [...new Set([...declared, ...looseItems.map((i) => i.category)])].filter(
    (c) => c !== "All"
  );

  const min = (xs: number[]) => (xs.length ? Math.min(...xs) : 0);
  return {
    boxes,
    looseItemCategories: ["All", ...categories],
    looseItems,
    vehicles,
    boxFrom: min(boxes.map((b) => b.price)),
    looseItemFrom: min(looseItems.map((i) => i.price)),
    pickupFrom: min(vehicles.map((v) => v.price)),
  };
}

/** The packaged defaults — what the site shows before the first publish. */
export const DEFAULT_PRICE_LIST: Prices = normalise(DEFAULT_PRICES as unknown as Raw)!;

async function fetchPrices(): Promise<Prices> {
  try {
    const res = await fetch(DOC_URL, {
      next: { revalidate: PRICE_REVALIDATE_SECONDS, tags: ["prices"] },
    });
    // 404 = no admin has published yet.
    if (!res.ok) return DEFAULT_PRICE_LIST;
    const doc = (await res.json()) as { fields?: Record<string, FsValue> };
    return normalise(decodeFields(doc.fields ?? {})) ?? DEFAULT_PRICE_LIST;
  } catch {
    return DEFAULT_PRICE_LIST;
  }
}

/** Live prices, fetched once per render and cached for five minutes. */
export const getPrices = cache(fetchPrices);
