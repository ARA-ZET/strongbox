"use client";

import { useEffect, useState } from "react";
import { APP_URL } from "@/lib/constants";
import type { Prices } from "@/lib/prices";
import { parseQuote, quoteQuery } from "@/lib/quote";
import LooseItemPicker from "@/components/LooseItemPicker";

/**
 * The full quote builder on /pricing. Every number comes from the live
 * `prices` — the loose-item picker is the real loose-item list, not a copy.
 *
 * It opens on any quote in the URL (see lib/quote.ts), which is how the home
 * page's quick calculator and /loose-items "Add to Quote" hand over, and
 * "Book Your Pickup" passes the finished quote on to the app's /register.
 */
export default function FullCalculator({ prices }: { prices: Prices }) {
  const { boxes: BOX_TYPES, vehicles: VEHICLES, looseItems: LOOSE_ITEMS } = prices;
  const [boxes, setBoxes] = useState<Record<string, number>>(
    Object.fromEntries(BOX_TYPES.map((b) => [b.id, 0]))
  );
  // Opens with one bike so the summary shows a real line before any clicks.
  const [loose, setLoose] = useState<Record<string, number>>(
    LOOSE_ITEMS.some((i) => i.id === "bicycle") ? { bicycle: 1 } : {}
  );
  const [vehicleId, setVehicleId] = useState(
    (VEHICLES.find((v) => v.recommended) ?? VEHICLES[0]).id
  );
  const [showAddLoose, setShowAddLoose] = useState(false);

  // Read after mount rather than via useSearchParams, so /pricing stays
  // statically rendered.
  useEffect(() => {
    const quote = parseQuote(window.location.search, prices);
    if (!quote) return;
    setBoxes(Object.fromEntries(BOX_TYPES.map((b) => [b.id, quote.boxes[b.id] ?? 0])));
    setLoose(quote.loose);
    if (quote.vehicle) setVehicleId(quote.vehicle);
  }, [prices, BOX_TYPES]);

  const updateBox = (id: string, delta: number) => {
    setBoxes((prev) => ({ ...prev, [id]: Math.max(0, (prev[id] ?? 0) + delta) }));
  };

  const updateLoose = (id: string, delta: number) => {
    setLoose((prev) => {
      const next = { ...prev, [id]: Math.max(0, (prev[id] ?? 0) + delta) };
      if (!next[id]) delete next[id];
      return next;
    });
  };

  const selectedLoose = LOOSE_ITEMS.filter((i) => (loose[i.id] ?? 0) > 0);
  const boxTotal = BOX_TYPES.reduce((s, b) => s + (boxes[b.id] ?? 0) * b.price, 0);
  const looseTotal = selectedLoose.reduce((s, i) => s + loose[i.id] * i.price, 0);
  const monthlyTotal = boxTotal + looseTotal;
  const vehicle = VEHICLES.find((v) => v.id === vehicleId) ?? VEHICLES[0];
  const registerHref = `${APP_URL}/register${quoteQuery({ boxes, loose, vehicle: vehicle.id })}`;

  return (
    <div className="bg-surface-white rounded-3xl shadow-tactile-lg overflow-hidden border border-navy-deep/5">
      <div className="grid grid-cols-1 lg:grid-cols-12">
        {/* Left — controls */}
        <div className="lg:col-span-7 p-8 md:p-14 space-y-10">
          {/* Step 1: Boxes */}
          <div>
            <h4 className="font-body-strong text-navy-deep mb-5 flex items-center gap-2 text-headline-h3">
              <span className="material-symbols-outlined text-accent-deep">package_2</span>
              1. Select StrongBoxes &amp; Sizes
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {BOX_TYPES.map((box) => (
                <div
                  key={box.id}
                  className="p-4 border rounded-xl border-navy-deep/10 flex justify-between items-center"
                >
                  <div>
                    <p className="font-body-strong text-sm text-navy-deep">{box.label}</p>
                    <p className="text-xs text-on-surface-variant">R{box.price}/mo</p>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => updateBox(box.id, -1)}
                      aria-label={`Remove one ${box.label}`}
                      className="w-8 h-8 rounded-full bg-navy-deep/5 flex items-center justify-center font-bold text-navy-deep hover:bg-navy-deep/10 transition-colors"
                    >
                      −
                    </button>
                    <span aria-live="polite" className="font-bold text-navy-deep w-5 text-center tabular-nums">{boxes[box.id]}</span>
                    <button
                      onClick={() => updateBox(box.id, 1)}
                      aria-label={`Add one ${box.label}`}
                      className="w-8 h-8 rounded-full bg-navy-deep/5 flex items-center justify-center font-bold text-navy-deep hover:bg-navy-deep/10 transition-colors"
                    >
                      +
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Step 2: Loose items */}
          <div>
            <h4 className="font-body-strong text-navy-deep mb-5 flex items-center gap-2 text-headline-h3">
              <span className="material-symbols-outlined text-accent-deep">chair</span>
              2. Add Loose Items
            </h4>
            <div className="space-y-3">
              {selectedLoose.map((item) => (
                <div
                  key={item.id}
                  className="flex justify-between items-center gap-3 p-4 bg-mist rounded-xl border border-navy-deep/5"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <span className="material-symbols-outlined text-navy-deep/60">{item.icon}</span>
                    <div className="min-w-0">
                      <p className="font-body-main text-navy-deep truncate">{item.name}</p>
                      <p className="text-xs text-on-surface-variant">R{item.price}/mo each</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      onClick={() => updateLoose(item.id, -1)}
                      aria-label={loose[item.id] === 1 ? `Remove ${item.name}` : `Remove one ${item.name}`}
                      className="w-8 h-8 rounded-full bg-surface-white flex items-center justify-center font-bold text-navy-deep hover:bg-navy-deep/10 transition-colors"
                    >
                      −
                    </button>
                    <span aria-live="polite" className="font-bold text-navy-deep w-5 text-center tabular-nums">{loose[item.id]}</span>
                    <button
                      onClick={() => updateLoose(item.id, 1)}
                      aria-label={`Add one ${item.name}`}
                      className="w-8 h-8 rounded-full bg-surface-white flex items-center justify-center font-bold text-navy-deep hover:bg-navy-deep/10 transition-colors"
                    >
                      +
                    </button>
                  </div>
                </div>
              ))}

              {showAddLoose ? (
                <LooseItemPicker
                  looseItems={LOOSE_ITEMS}
                  looseItemCategories={prices.looseItemCategories}
                  onAdd={(id) => updateLoose(id, 1)}
                  onClose={() => setShowAddLoose(false)}
                />
              ) : (
                <button
                  onClick={() => setShowAddLoose(true)}
                  className="w-full py-4 border-2 border-dashed border-navy-deep/20 rounded-xl text-navy-deep/60 font-body-strong flex items-center justify-center gap-2 hover:border-accent-deep hover:text-accent-deep hover:bg-accent/5 transition-all"
                >
                  <span className="material-symbols-outlined">add</span>
                  Add Loose Item
                </button>
              )}
            </div>
          </div>

          {/* Step 3: Vehicle */}
          <div>
            <h4 className="font-body-strong text-navy-deep mb-5 flex items-center gap-2 text-headline-h3">
              <span className="material-symbols-outlined text-accent-deep">local_shipping</span>
              3. Choose Pickup Vehicle
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {VEHICLES.map((v) => (
                <label key={v.id} className="cursor-pointer group relative">
                  <input
                    type="radio"
                    name="vehicle"
                    value={v.id}
                    checked={vehicleId === v.id}
                    onChange={() => setVehicleId(v.id)}
                    className="hidden"
                  />
                  <div
                    className={`p-4 border-2 rounded-xl text-center transition-all ${
                      vehicleId === v.id
                        ? "border-accent-deep bg-accent/5"
                        : "border-navy-deep/5 hover:bg-navy-deep/5"
                    }`}
                  >
                    {v.recommended && (
                      <span className="absolute -top-2 left-1/2 -translate-x-1/2 bg-accent text-on-accent text-xs font-bold px-2 py-0.5 rounded-full whitespace-nowrap">
                        Recommended
                      </span>
                    )}
                    <span
                      className={`material-symbols-outlined text-3xl mb-2 block transition-colors ${
                        vehicleId === v.id ? "text-accent-deep" : "text-navy-deep/40"
                      }`}
                    >
                      {v.icon}
                    </span>
                    <p className="font-body-strong text-sm text-navy-deep">{v.label}</p>
                    <p className="text-xs text-on-surface-variant">{v.desc}</p>
                    <p className="text-xs font-bold text-navy-deep mt-1">R{v.price} once-off</p>
                  </div>
                </label>
              ))}
            </div>
          </div>
        </div>

        {/* Right — summary */}
        <div className="lg:col-span-5 bg-navy-deep p-8 md:p-14 text-surface-white flex flex-col justify-between">
          <div>
            <h3 className="text-headline-h3 font-bold mb-8">Estimated Summary</h3>
            <div className="space-y-4 border-b border-surface-white/10 pb-8 mb-8 text-sm">
              {BOX_TYPES.filter((b) => (boxes[b.id] ?? 0) > 0).map((b) => (
                <div key={b.id} className="flex justify-between text-on-navy-variant">
                  <span>{boxes[b.id]}× {b.label}</span>
                  <span className="font-bold text-surface-white">
                    R{((boxes[b.id] ?? 0) * b.price).toLocaleString("en-ZA")}
                  </span>
                </div>
              ))}
              {selectedLoose.map((item) => (
                <div key={item.id} className="flex justify-between text-on-navy-variant">
                  <span>{loose[item.id]}× {item.name}</span>
                  <span className="font-bold text-surface-white">
                    R{(loose[item.id] * item.price).toLocaleString("en-ZA")}
                  </span>
                </div>
              ))}
              {monthlyTotal === 0 && (
                <p className="text-on-navy-variant/60 text-sm italic">No items selected yet.</p>
              )}
            </div>

            <div className="flex justify-between items-end mb-8">
              <div>
                <p className="text-label-caps text-on-navy-variant uppercase tracking-widest mb-1 text-xs">
                  Est. Total Monthly
                </p>
                <p className="text-5xl font-bold text-sky tabular-nums">
                  R{monthlyTotal.toLocaleString("en-ZA")}
                </p>
              </div>
              <div className="text-right">
                <p className="text-label-caps text-on-navy-variant uppercase tracking-widest mb-1 text-xs">
                  Initial Pickup
                </p>
                <p className="text-2xl font-bold">R{vehicle.price}</p>
              </div>
            </div>
          </div>

          <div>
            <a
              href={registerHref}
              className="w-full h-[64px] bg-accent text-on-accent rounded-xl font-body-strong text-lg shadow-lg hover:opacity-90 transition-all flex items-center justify-center gap-3 active:scale-95"
            >
              Book Your Pickup
              <span className="material-symbols-outlined">arrow_forward</span>
            </a>
            <p className="text-center text-xs text-on-navy-variant/50 mt-4 italic">
              Prices inclusive of 15% VAT. Terms and conditions apply.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
