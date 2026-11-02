import type { Prices } from "./prices";

/**
 * A quote as the calculators hold it: counts keyed by price-list id, plus the
 * pickup vehicle, packing supplies and packing-helper hours. Ids are the same
 * ones the app records as `priceKey` on each StorageUnit, so a quote handed to
 * the app needs no translation (app/lib/core/models/quote.dart).
 */
export type Quote = {
  boxes: Record<string, number>;
  loose: Record<string, number>;
  vehicle?: string;
  supplies?: Record<string, number>;
  helperHours?: number;
};

/*
 * URL form — shared by every hand-off so they all read the same way:
 *
 *   ?boxes=small:2,medium:1&loose=bicycle:1,sofa-3-seater:1&vehicle=bakkie
 *    &supplies=bubble-wrap:2&helper=3
 *
 * Used for: quick calculator → full calculator, /loose-items "Add to Quote" →
 * full calculator, and either calculator → the app's /register.
 */

function encodeCounts(counts: Record<string, number>): string {
  return Object.entries(counts)
    .filter(([, n]) => n > 0)
    .map(([id, n]) => `${id}:${n}`)
    .join(",");
}

function decodeCounts(raw: string | null, validIds: Set<string>): Record<string, number> {
  const out: Record<string, number> = {};
  for (const part of (raw ?? "").split(",")) {
    const [id, n] = part.split(":");
    const count = Math.min(99, Math.max(0, Math.floor(Number(n ?? 1))));
    // Ids the current price list doesn't sell are dropped, not shown at R0.
    if (id && validIds.has(id) && count > 0) out[id] = (out[id] ?? 0) + count;
  }
  return out;
}

/** `?boxes=…&loose=…&vehicle=…`, or "" for an empty quote. */
export function quoteQuery(quote: Quote): string {
  const params = new URLSearchParams();
  const boxes = encodeCounts(quote.boxes);
  const loose = encodeCounts(quote.loose);
  if (boxes) params.set("boxes", boxes);
  if (loose) params.set("loose", loose);
  if (quote.vehicle) params.set("vehicle", quote.vehicle);
  const supplies = encodeCounts(quote.supplies ?? {});
  if (supplies) params.set("supplies", supplies);
  if (quote.helperHours && quote.helperHours > 0) {
    params.set("helper", String(Math.floor(quote.helperHours)));
  }
  const qs = params.toString();
  return qs ? `?${qs}` : "";
}

/**
 * Reads a quote from a query string, keeping only ids on sale in `prices`.
 * Returns null when the URL carries no quote at all, so callers keep their
 * own opening state.
 */
export function parseQuote(search: string, prices: Prices): Quote | null {
  const params = new URLSearchParams(search);
  if (!["boxes", "loose", "vehicle", "supplies", "helper"].some((k) => params.has(k))) {
    return null;
  }
  const vehicle = params.get("vehicle") ?? undefined;
  const hours = Math.min(12, Math.max(0, Math.floor(Number(params.get("helper") ?? 0))));
  return {
    boxes: decodeCounts(params.get("boxes"), new Set(prices.boxes.map((b) => b.id))),
    loose: decodeCounts(params.get("loose"), new Set(prices.looseItems.map((i) => i.id))),
    vehicle: prices.vehicles.some((v) => v.id === vehicle) ? vehicle : undefined,
    supplies: decodeCounts(params.get("supplies"), new Set(prices.supplies.map((s) => s.id))),
    helperHours: prices.packingHelper ? hours : 0,
  };
}
