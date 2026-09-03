"use client";

import { useState } from "react";
import PrepayToggle from "@/components/PrepayToggle";
import {
  BOX_TYPES,
  VEHICLES,
  APP_URL,
  DEFAULT_TIER,
  tierMonthly,
  type PrepayTier,
} from "@/lib/constants";

interface LooseItem {
  name: string;
  price: number;
}

const QUICK_LOOSE: LooseItem[] = [
  { name: "Mountain Bike", price: 110 },
  { name: "Surfboard", price: 95 },
  { name: "Golf Bag", price: 85 },
  { name: "Bicycle", price: 110 },
  { name: "Large Suitcase", price: 75 },
  { name: "Dining Table", price: 145 },
];

export default function FullCalculator() {
  const [boxes, setBoxes] = useState<Record<string, number>>(
    Object.fromEntries(BOX_TYPES.map((b) => [b.id, 0]))
  );
  const [looseItems, setLooseItems] = useState<LooseItem[]>([
    { name: "Mountain Bike", price: 110 },
  ]);
  const [vehicleId, setVehicleId] = useState("small-van");
  const [showAddLoose, setShowAddLoose] = useState(false);
  const [tier, setTier] = useState<PrepayTier>(DEFAULT_TIER);

  const updateBox = (id: string, delta: number) => {
    setBoxes((prev) => ({ ...prev, [id]: Math.max(0, (prev[id] ?? 0) + delta) }));
  };

  const addLooseItem = (item: LooseItem) => {
    setLooseItems((prev) => [...prev, item]);
    setShowAddLoose(false);
  };

  const removeLoose = (idx: number) => {
    setLooseItems((prev) => prev.filter((_, i) => i !== idx));
  };

  const boxTotal = BOX_TYPES.reduce((s, b) => s + (boxes[b.id] ?? 0) * b.price, 0);
  const looseTotal = looseItems.reduce((s, i) => s + i.price, 0);
  /** List price per month, before the prepay discount. */
  const listMonthly = boxTotal + looseTotal;
  const monthlyTotal = tierMonthly(listMonthly, tier);
  const upfront = monthlyTotal * tier.months;
  const vehicle = VEHICLES.find((v) => v.id === vehicleId)!;

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
              {looseItems.map((item, idx) => (
                <div
                  key={idx}
                  className="flex justify-between items-center p-4 bg-mist rounded-xl border border-navy-deep/5"
                >
                  <div className="flex items-center gap-3">
                    <span className="material-symbols-outlined text-navy-deep/60">shopping_basket</span>
                    <span className="font-body-main text-navy-deep">{item.name}</span>
                  </div>
                  <div className="flex items-center gap-4">
                    <span className="font-body-strong text-navy-deep">R{item.price}/mo</span>
                    <button
                      onClick={() => removeLoose(idx)}
                      className="text-error hover:scale-110 transition-transform"
                      aria-label="Remove item"
                    >
                      <span className="material-symbols-outlined">delete</span>
                    </button>
                  </div>
                </div>
              ))}

              {showAddLoose ? (
                <div className="p-4 border-2 border-accent-deep/40 rounded-xl bg-mist">
                  <p className="font-body-strong text-navy-deep mb-3 text-sm">Quick add:</p>
                  <div className="flex flex-wrap gap-2">
                    {QUICK_LOOSE.map((item) => (
                      <button
                        key={item.name}
                        onClick={() => addLooseItem(item)}
                        className="px-3 py-1.5 bg-surface-white border border-navy-deep/10 rounded-full text-sm text-navy-deep hover:border-accent-deep hover:text-accent-deep transition-colors font-body-strong"
                      >
                        {item.name} · R{item.price}
                      </button>
                    ))}
                  </div>
                  <button
                    onClick={() => setShowAddLoose(false)}
                    className="mt-3 text-sm text-on-surface-variant hover:text-error transition-colors"
                  >
                    Cancel
                  </button>
                </div>
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

          {/* Step 4: Prepay term */}
          <div>
            <h4 className="font-body-strong text-navy-deep mb-5 flex items-center gap-2 text-headline-h3">
              <span className="material-symbols-outlined text-accent-deep">event_repeat</span>
              4. Choose Your Term
            </h4>
            <PrepayToggle value={tier} onChange={setTier} name="full-prepay" />
            <p className="text-xs text-on-surface-variant mt-3">
              Storage is billed monthly by default. Paying a term up front discounts the
              monthly rate — the once-off pickup fee is charged either way.
            </p>
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
              {looseItems.map((item, i) => (
                <div key={i} className="flex justify-between text-on-navy-variant">
                  <span>{item.name}</span>
                  <span className="font-bold text-surface-white">R{item.price}/mo</span>
                </div>
              ))}
              {boxTotal === 0 && looseItems.length === 0 && (
                <p className="text-on-navy-variant/60 text-sm italic">No items selected yet.</p>
              )}
            </div>

            <div className="flex justify-between items-end mb-4">
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

            {/* Shown only once a prepay tier is actually selected — on the
                monthly tier this would restate the number above it. */}
            {tier.discount > 0 && listMonthly > 0 && (
              <div className="mb-8 rounded-xl bg-surface-white/5 border border-surface-white/10 p-4 text-sm">
                <div className="flex justify-between text-on-navy-variant">
                  <span>Billed monthly</span>
                  <s>R{listMonthly.toLocaleString("en-ZA")}/mo</s>
                </div>
                <div className="flex justify-between text-on-navy-variant mt-1">
                  <span>You save</span>
                  <span className="text-sky font-body-strong">
                    R{((listMonthly - monthlyTotal) * tier.months).toLocaleString("en-ZA")} over{" "}
                    {tier.months} months
                  </span>
                </div>
                <div className="flex justify-between text-surface-white font-body-strong mt-3 pt-3 border-t border-surface-white/10">
                  <span>Paid up front</span>
                  <span className="tabular-nums">R{upfront.toLocaleString("en-ZA")}</span>
                </div>
              </div>
            )}
          </div>

          <div>
            <a
              href={`${APP_URL}/quote`}
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
