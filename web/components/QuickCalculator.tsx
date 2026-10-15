"use client";

import { useState } from "react";
import Link from "next/link";
import { APP_URL } from "@/lib/constants";
import type { Prices } from "@/lib/prices";
import { quoteQuery } from "@/lib/quote";
import LooseItemPicker from "@/components/LooseItemPicker";

/**
 * Home-page cost estimator.
 *
 * A cut-down version of `FullCalculator` on the pricing page: boxes and loose
 * items, but no vehicle choice. It takes the live `prices` (see
 * lib/prices.ts), so the box sizes, loose items and their prices are the same
 * objects the pricing table, /loose-items and the full calculator render.
 *
 * Both buttons carry the quote along (lib/quote.ts): "Get Started" to the
 * app's /register, "Build Full Quote" into the full calculator.
 */
export default function QuickCalculator({ prices }: { prices: Prices }) {
  const { boxes: BOX_TYPES, looseItems: LOOSE_ITEMS, pickupFrom: PICKUP_FROM } = prices;
  const [counts, setCounts] = useState<Record<string, number>>(
    // Opens on a plausible small load rather than all zeros, so the estimate
    // shows a real number before the visitor touches anything.
    Object.fromEntries(BOX_TYPES.map((b, i) => [b.id, i === 0 ? 2 : i === 1 ? 1 : 0]))
  );
  const [loose, setLoose] = useState<Record<string, number>>({});
  const [showPicker, setShowPicker] = useState(false);

  const update = (id: string, delta: number) =>
    setCounts((prev) => ({ ...prev, [id]: Math.max(0, (prev[id] ?? 0) + delta) }));

  const updateLoose = (id: string, delta: number) =>
    setLoose((prev) => {
      const next = { ...prev, [id]: Math.max(0, (prev[id] ?? 0) + delta) };
      if (!next[id]) delete next[id];
      return next;
    });

  const selectedLoose = LOOSE_ITEMS.filter((i) => (loose[i.id] ?? 0) > 0);
  const boxTotal = BOX_TYPES.reduce((sum, b) => sum + (counts[b.id] ?? 0) * b.price, 0);
  const looseTotal = selectedLoose.reduce((sum, i) => sum + loose[i.id] * i.price, 0);
  const total = boxTotal + looseTotal;
  const query = quoteQuery({ boxes: counts, loose });

  const stepper = (label: string, value: number, onChange: (delta: number) => void) => (
    <div className="flex items-center gap-2 bg-mist rounded-lg p-1 shrink-0">
      <button
        onClick={() => onChange(-1)}
        className="w-8 h-8 rounded bg-surface-white shadow-sm flex items-center justify-center hover:bg-sky-tint transition-colors font-bold text-navy-deep"
        aria-label={`Remove one ${label}`}
      >
        −
      </button>
      <span className="w-6 text-center font-bold text-navy-deep text-sm tabular-nums">{value}</span>
      <button
        onClick={() => onChange(1)}
        className="w-8 h-8 rounded bg-surface-white shadow-sm flex items-center justify-center hover:bg-sky-tint transition-colors font-bold text-navy-deep"
        aria-label={`Add one ${label}`}
      >
        +
      </button>
    </div>
  );

  return (
    <section className="py-24 bg-mist" id="calculator">
      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
        <div className="grid md:grid-cols-12 gap-gutter items-center">
          {/* Left copy */}
          <div className="md:col-span-5 mb-10 md:mb-0">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Cost Estimator
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-5">
              Estimate your monthly storage cost
            </h2>
            <p className="text-on-surface-variant text-body-main mb-8">
              You pay per box or item, per month — nothing for space you don&apos;t use.
              Add boxes and furniture below to see a live estimate.
            </p>
            <div className="space-y-3">
              {[
                "No long-term contracts",
                "Billed monthly, cancel anytime",
                "Photo inventory of every box included",
              ].map((text) => (
                <div key={text} className="flex items-center gap-3 text-navy-deep font-body-strong">
                  <span className="material-symbols-outlined text-accent-deep">
                    check_circle
                  </span>
                  {text}
                </div>
              ))}
            </div>
          </div>

          {/* Calculator card */}
          <div className="md:col-span-7">
            <div className="bg-surface-white rounded-xl shadow-tactile overflow-hidden flex flex-col md:flex-row">
              {/* Controls */}
              <div className="p-8 flex-1 space-y-5">
                {BOX_TYPES.map((box) => (
                  <div key={box.id} className="flex justify-between items-center gap-4">
                    <div className="min-w-0">
                      <p className="font-body-strong text-navy-deep">{box.label}</p>
                      <p className="text-xs text-on-surface-variant">
                        {box.desc} · R{box.price}/mo
                      </p>
                    </div>
                    {stepper(box.label, counts[box.id] ?? 0, (d) => update(box.id, d))}
                  </div>
                ))}

                {/* Loose items — the same list /loose-items shows */}
                <div className="pt-5 border-t border-outline-variant/40 space-y-4">
                  {selectedLoose.map((item) => (
                    <div key={item.id} className="flex justify-between items-center gap-4">
                      <div className="min-w-0 flex items-center gap-2">
                        <span className="material-symbols-outlined text-accent-deep shrink-0">
                          {item.icon}
                        </span>
                        <div className="min-w-0">
                          <p className="font-body-strong text-navy-deep truncate">{item.name}</p>
                          <p className="text-xs text-on-surface-variant">R{item.price}/mo each</p>
                        </div>
                      </div>
                      {stepper(item.name, loose[item.id], (d) => updateLoose(item.id, d))}
                    </div>
                  ))}

                  {showPicker ? (
                    <LooseItemPicker
                      looseItems={LOOSE_ITEMS}
                      looseItemCategories={prices.looseItemCategories}
                      onAdd={(id) => updateLoose(id, 1)}
                      onClose={() => setShowPicker(false)}
                    />
                  ) : LOOSE_ITEMS.length > 0 ? (
                    <button
                      onClick={() => setShowPicker(true)}
                      className="w-full py-3 border-2 border-dashed border-navy-deep/20 rounded-xl text-navy-deep/60 text-sm font-body-strong flex items-center justify-center gap-2 hover:border-accent-deep hover:text-accent-deep hover:bg-accent/5 transition-all"
                    >
                      <span className="material-symbols-outlined text-lg">chair</span>
                      Add furniture &amp; loose items
                    </button>
                  ) : null}
                  <p className="text-xs text-on-surface-variant">
                    <Link href="/loose-items" className="text-accent-deep font-body-strong hover:underline">
                      Loose items
                    </Link>{" "}
                    are priced by the space they occupy.
                  </p>
                </div>
              </div>

              {/* Summary panel */}
              <div className="bg-navy-deep p-8 md:w-[280px] text-surface-white flex flex-col justify-between">
                <div>
                  <p className="font-label-caps text-on-navy-variant uppercase tracking-widest mb-4 text-xs">
                    Your Estimate
                  </p>

                  {/* Line items, so the total is shown to be arrived at rather
                      than merely asserted — the same breakdown the full
                      calculator gives on the pricing page. */}
                  <div className="space-y-2 text-xs border-b border-surface-white/10 pb-5 mb-5">
                    {BOX_TYPES.filter((b) => (counts[b.id] ?? 0) > 0).map((b) => (
                      <div key={b.id} className="flex justify-between gap-3 text-on-navy-variant">
                        <span className="truncate">
                          {counts[b.id]}× {b.label}
                        </span>
                        <span className="font-bold text-surface-white tabular-nums shrink-0">
                          R{((counts[b.id] ?? 0) * b.price).toLocaleString("en-ZA")}
                        </span>
                      </div>
                    ))}
                    {selectedLoose.map((i) => (
                      <div key={i.id} className="flex justify-between gap-3 text-on-navy-variant">
                        <span className="truncate">
                          {loose[i.id]}× {i.name}
                        </span>
                        <span className="font-bold text-surface-white tabular-nums shrink-0">
                          R{(loose[i.id] * i.price).toLocaleString("en-ZA")}
                        </span>
                      </div>
                    ))}
                    {total === 0 && (
                      <p className="text-on-navy-variant/60 italic">Nothing selected yet.</p>
                    )}
                  </div>

                  <div className="flex items-baseline gap-1">
                    <span className="text-xl font-bold">R</span>
                    <span key={total} className="text-5xl font-bold tabular-nums transition-all duration-200">
                      {total.toLocaleString("en-ZA")}
                    </span>
                    <span className="text-on-navy-variant text-sm">/mo</span>
                  </div>
                  <p className="text-xs text-on-navy-variant mt-4">
                    Plus a once-off pickup from R{PICKUP_FROM}, depending on the
                    vehicle your load needs.
                  </p>
                </div>
                <div className="space-y-3 mt-8">
                  <a
                    href={`${APP_URL}/register${query}`}
                    className="block w-full bg-accent text-on-accent py-4 rounded-xl font-body-strong text-center hover:opacity-90 transition-all"
                  >
                    Get Started
                  </a>
                  <Link
                    href={`/pricing${query}#calculator`}
                    className="block w-full border border-surface-white/30 text-surface-white py-3 rounded-xl font-body-strong text-center text-sm hover:bg-surface-white/10 transition-all"
                  >
                    Build Full Quote
                  </Link>
                  <p className="text-xs text-on-navy-variant/60 text-center">
                    15% VAT inclusive
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
