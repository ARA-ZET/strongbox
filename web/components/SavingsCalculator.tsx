"use client";

import { useState } from "react";
import Link from "next/link";
import type { Prices } from "@/lib/prices";

/**
 * Self-storage unit vs pay-per-box, over twelve months.
 *
 * This deliberately is not a "savings calculator". On the current rate card
 * StrongBox is cheaper than a Cape Town locker only up to roughly three or
 * four boxes; past that a unit wins on rand and the tool says so, because a
 * visitor who gets a real quote a week later will work it out anyway and a
 * tool caught flattering itself poisons every other number on the site.
 *
 * What it does instead is put both totals side by side and name what the
 * difference buys — which is the actual argument for valet storage.
 *
 * Every input a visitor could dispute is exposed and editable, and the
 * defaults are conservative: unit rent at the bottom of the Cape Town range
 * and only two trips a month, both of which favour the unit.
 */

/** Cape Town self-storage, indicative monthly rent by unit size, 2026. */
const UNITS = [
  { id: "small", label: "Small locker", size: "~3 m² / 7 m³", rent: 750 },
  { id: "medium", label: "Medium unit", size: "~6 m² / 15 m³", rent: 1250 },
  { id: "large", label: "Large unit", size: "~12 m² / 30 m³", rent: 1950 },
];

/** Cost of one round trip to a unit: fuel plus wear, on a ~25 km return run. */
const TRIP_COST = 95;

/** What the price gap actually buys, listed whichever way the gap falls. */
const INCLUDED = [
  "Collection from your door",
  "Return delivery when you ask",
  "Photo inventory of every box",
  "No trips, no lifting, no truck hire",
  "No unit deposit, no access-card fee",
];

const rand = (n: number) => `R${Math.round(n).toLocaleString("en-ZA")}`;

export default function SavingsCalculator({ prices }: { prices: Prices }) {
  const { boxes: BOX_TYPES } = prices;
  // Our cheapest collection — the small van on the default rate card.
  const SMALL_VAN =
    prices.vehicles.find((v) => v.id === "small-van") ??
    prices.vehicles.find((v) => v.price === prices.pickupFrom)!;
  const [boxes, setBoxes] = useState(6);
  const [boxTypeId, setBoxTypeId] = useState(
    (BOX_TYPES.find((b) => b.id === "medium") ?? BOX_TYPES[0]).id
  );
  const [unitId, setUnitId] = useState("small");
  const [rent, setRent] = useState(UNITS[0].rent);
  const [tripsPerMonth, setTripsPerMonth] = useState(2);

  const unit = UNITS.find((u) => u.id === unitId)!;
  const boxType = BOX_TYPES.find((b) => b.id === boxTypeId) ?? BOX_TYPES[0];

  /** Changing the unit resets the rent to that size's default. */
  const pickUnit = (id: string) => {
    setUnitId(id);
    setRent(UNITS.find((u) => u.id === id)!.rent);
  };

  // ── Self-storage side ──
  const unitYear = rent * 12;
  const tripsYear = tripsPerMonth * 12 * TRIP_COST;
  const selfStorageYear = unitYear + tripsYear;

  // ── StrongBox side ──
  const rate = boxType.price;
  const strongboxYear = rate * boxes * 12 + SMALL_VAN.price;

  const gap = selfStorageYear - strongboxYear;
  const cheaper = gap > 0;

  /**
   * Largest whole number of boxes that still costs less than the unit. Stated
   * outright rather than left for the visitor to discover by dragging.
   */
  const breakEven = Math.floor((selfStorageYear - SMALL_VAN.price) / (rate * 12));

  return (
    <div className="bg-surface-white rounded-3xl shadow-tactile-lg overflow-hidden border border-outline-variant">
      <div className="grid grid-cols-1 lg:grid-cols-12">
        {/* ── Inputs ── */}
        <div className="lg:col-span-7 p-8 md:p-12 space-y-9">
          <div>
            <label
              htmlFor="savings-boxes"
              className="font-body-strong text-navy-deep text-headline-h3 flex items-center gap-2 mb-2"
            >
              <span className="material-symbols-outlined text-accent-deep">package_2</span>
              How much are you storing?
            </label>
            <p className="text-sm text-on-surface-variant mb-5">
              In boxes. A single wardrobe is roughly six; a spare room is closer to
              twenty-five.
            </p>
            <div className="flex items-center gap-5 mb-5">
              <input
                id="savings-boxes"
                type="range"
                min={1}
                max={40}
                value={boxes}
                onChange={(e) => setBoxes(Number(e.target.value))}
                className="flex-1 accent-accent"
              />
              <output
                htmlFor="savings-boxes"
                className="w-24 shrink-0 text-center rounded-lg bg-mist border border-outline-variant py-2 font-bold text-navy-deep tabular-nums"
              >
                {boxes} {boxes === 1 ? "box" : "boxes"}
              </output>
            </div>
            <fieldset>
              <legend className="text-sm font-body-strong text-navy-deep mb-2">Box size</legend>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                {BOX_TYPES.map((b) => (
                  <label key={b.id} className="cursor-pointer">
                    <input
                      type="radio"
                      name="box-size"
                      value={b.id}
                      checked={boxTypeId === b.id}
                      onChange={() => setBoxTypeId(b.id)}
                      className="sr-only"
                    />
                    <div
                      className={`p-3 border-2 rounded-lg text-center transition-all ${
                        boxTypeId === b.id
                          ? "border-accent bg-sky-tint"
                          : "border-outline-variant hover:bg-mist"
                      }`}
                    >
                      <p className="text-xs font-body-strong text-navy-deep">
                        {b.label.replace(" Box", "").replace(/ \(.*\)/, "")}
                      </p>
                      <p className="text-xs text-on-surface-variant">R{b.price}/mo</p>
                    </div>
                  </label>
                ))}
              </div>
            </fieldset>
          </div>

          <div>
            <p className="font-body-strong text-navy-deep text-headline-h3 flex items-center gap-2 mb-2">
              <span className="material-symbols-outlined text-accent-deep">warehouse</span>
              What would you rent instead?
            </p>
            <p className="text-sm text-on-surface-variant mb-5">
              Self-storage is billed by the unit, so the smallest one that fits is what
              you pay for — full or not.
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {UNITS.map((u) => (
                <label key={u.id} className="cursor-pointer">
                  <input
                    type="radio"
                    name="unit-size"
                    value={u.id}
                    checked={unitId === u.id}
                    onChange={() => pickUnit(u.id)}
                    className="sr-only"
                  />
                  <div
                    className={`p-4 border-2 rounded-xl text-center transition-all ${
                      unitId === u.id
                        ? "border-accent bg-sky-tint"
                        : "border-outline-variant hover:bg-mist"
                    }`}
                  >
                    <p className="font-body-strong text-sm text-navy-deep">{u.label}</p>
                    <p className="text-xs text-on-surface-variant mt-1">{u.size}</p>
                  </div>
                </label>
              ))}
            </div>
          </div>

          <div className="grid sm:grid-cols-2 gap-6">
            <div>
              <label htmlFor="savings-rent" className="font-body-strong text-navy-deep block mb-2">
                Monthly unit rent
              </label>
              <div className="flex items-center rounded-lg border border-outline-variant bg-mist px-4 focus-within:border-accent focus-within:ring-2 focus-within:ring-accent/20">
                <span className="text-on-surface-variant">R</span>
                <input
                  id="savings-rent"
                  type="number"
                  min={0}
                  step={50}
                  value={rent}
                  onChange={(e) => setRent(Math.max(0, Number(e.target.value)))}
                  className="w-full bg-transparent py-3 px-2 text-navy-deep font-body-strong outline-none tabular-nums"
                />
              </div>
              <p className="text-xs text-on-surface-variant mt-2">
                Got a real quote? Type it in — the comparison uses your number.
              </p>
            </div>

            <div>
              <label htmlFor="savings-trips" className="font-body-strong text-navy-deep block mb-2">
                Trips to the unit per month
              </label>
              <div className="flex items-center rounded-lg border border-outline-variant bg-mist px-4 focus-within:border-accent focus-within:ring-2 focus-within:ring-accent/20">
                <input
                  id="savings-trips"
                  type="number"
                  min={0}
                  max={30}
                  value={tripsPerMonth}
                  onChange={(e) =>
                    setTripsPerMonth(Math.min(30, Math.max(0, Number(e.target.value))))
                  }
                  className="w-full bg-transparent py-3 pr-2 text-navy-deep font-body-strong outline-none tabular-nums"
                />
              </div>
              <p className="text-xs text-on-surface-variant mt-2">
                Costed at {rand(TRIP_COST)} a return trip in fuel and wear. Your time is
                not counted.
              </p>
            </div>
          </div>

        </div>

        {/* ── Result ── */}
        <div className="lg:col-span-5 bg-navy-deep p-8 md:p-12 text-surface-white flex flex-col justify-between">
          <div>
            <p className="font-label-caps text-on-navy-variant uppercase tracking-widest text-xs mb-6">
              Over 12 months
            </p>

            {/* Self-storage */}
            <div className="mb-6">
              <div className="flex justify-between items-baseline mb-2 gap-4">
                <span className="text-on-navy">{unit.label}</span>
                <span className="text-2xl font-bold tabular-nums">{rand(selfStorageYear)}</span>
              </div>
              <ul className="text-xs text-on-navy-variant space-y-1">
                <li className="flex justify-between gap-4">
                  <span>Rent, {rand(rent)} × 12</span>
                  <span className="tabular-nums">{rand(unitYear)}</span>
                </li>
                <li className="flex justify-between gap-4">
                  <span>
                    {tripsPerMonth * 12} trips × {rand(TRIP_COST)}
                  </span>
                  <span className="tabular-nums">{rand(tripsYear)}</span>
                </li>
              </ul>
            </div>

            {/* StrongBox */}
            <div className="mb-8 pb-8 border-b border-surface-white/10">
              <div className="flex justify-between items-baseline mb-2 gap-4">
                <span className="text-on-navy">StrongBox</span>
                <span className="text-2xl font-bold text-sky tabular-nums">
                  {rand(strongboxYear)}
                </span>
              </div>
              <ul className="text-xs text-on-navy-variant space-y-1">
                <li className="flex justify-between gap-4">
                  <span>
                    {boxes} × {rand(rate)} × 12
                  </span>
                  <span className="tabular-nums">{rand(rate * boxes * 12)}</span>
                </li>
                <li className="flex justify-between gap-4">
                  <span>One-off collection</span>
                  <span className="tabular-nums">{rand(SMALL_VAN.price)}</span>
                </li>
                <li className="flex justify-between gap-4">
                  <span>Trips to a facility</span>
                  <span>None</span>
                </li>
              </ul>
            </div>

            <p className="font-label-caps text-on-navy-variant uppercase tracking-widest text-xs mb-2">
              {cheaper ? "We are cheaper by" : "The unit is cheaper by"}
            </p>
            <p
              key={gap}
              className={`text-5xl font-bold tabular-nums ${cheaper ? "text-sky" : "text-surface-white"}`}
            >
              {rand(Math.abs(gap))}
            </p>
            <p className="text-sm text-on-navy-variant mt-2">
              {rand(Math.abs(gap) / 12)} a month
              {cheaper && tripsPerMonth > 0
                ? `, plus ${tripsPerMonth * 12} trips across town you never make.`
                : "."}
            </p>

            {/* Stated outright rather than left to be discovered by dragging. */}
            <p className="text-xs text-on-navy-variant mt-4 rounded-lg bg-surface-white/5 border border-surface-white/10 p-3">
              At {rand(rate)} a box, a {unit.label.toLowerCase()} works out cheaper than{" "}
              <span className="text-sky font-body-strong">
                more than {breakEven} {breakEven === 1 ? "box" : "boxes"}
              </span>{" "}
              with us. Below that, we win on price too.
            </p>

            {/* The actual argument, whichever way the rand falls. */}
            <div className="mt-6">
              <p className="text-sm text-on-navy mb-3">
                {cheaper ? "And it still includes" : "What that difference buys"}
              </p>
              <ul className="space-y-1.5">
                {INCLUDED.map((item) => (
                  <li key={item} className="flex gap-2 text-xs text-on-navy-variant">
                    <span
                      aria-hidden="true"
                      className="material-symbols-outlined text-sky text-base shrink-0"
                    >
                      check_circle
                    </span>
                    {item}
                  </li>
                ))}
              </ul>
            </div>
          </div>

          <div className="mt-10">
            <Link
              href="/pricing#calculator"
              className="w-full h-[56px] bg-accent text-on-accent rounded-xl font-body-strong flex items-center justify-center gap-2 hover:bg-accent-deep transition-colors"
            >
              Build your exact quote
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
            <p className="text-xs text-on-navy-variant/70 mt-4">
              Estimates only, VAT inclusive. Unit rents are Cape Town market ranges, not
              quotes from a named operator. Neither side includes insurance — in South
              Africa you insure your own goods either way.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
