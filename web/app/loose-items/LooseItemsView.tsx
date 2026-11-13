"use client";

import { useState } from "react";
import type { Prices } from "@/lib/prices";
import { quoteQuery } from "@/lib/quote";
import Link from "next/link";
import ClosingCta from "@/components/ClosingCta";
import PhotoHero from "@/components/PhotoHero";

/** The interactive body of /loose-items; `page.tsx` fetches the live prices. */
export default function LooseItemsView({
  looseItems: LOOSE_ITEMS,
  looseItemCategories: LOOSE_ITEM_CATEGORIES,
}: Pick<Prices, "looseItems" | "looseItemCategories">) {
  const [activeCategory, setActiveCategory] = useState<string>("All");
  const example = LOOSE_ITEMS.find((item) => item.id === "dining-table");

  const filtered =
    activeCategory === "All"
      ? LOOSE_ITEMS
      : LOOSE_ITEMS.filter((item) => item.category === activeCategory);

  return (
    <>
      {/* Hero */}
      <PhotoHero
        photo="hero-loose"
        trail={[{ name: "Loose items", path: "/loose-items" }]}
        title="Furniture and loose item storage"
        lead="For the things that will not fit in a box: beds, bicycles, desks, surfboards. Each one is priced by the space it takes up, labelled, and tracked exactly as a box is."
      />

      {/* Category filter + grid */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          {/* Category chips */}
          <div className="flex gap-2 flex-wrap mb-10">
            {LOOSE_ITEM_CATEGORIES.map((cat) => (
              <button
                key={cat}
                onClick={() => setActiveCategory(cat)}
                className={`px-5 py-2 rounded-full font-body-strong text-sm transition-colors ${
                  activeCategory === cat
                    ? "bg-navy-deep text-surface-white"
                    : "bg-mist text-navy-deep hover:bg-surface-container"
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          {/* Items grid */}
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {filtered.map((item) => (
              <div
                key={item.id}
                className="bg-surface-white border border-outline-variant rounded-xl p-6 flex flex-col items-center text-center card-hover"
              >
                <div className="w-14 h-14 rounded-full bg-accent/15 flex items-center justify-center mb-3">
                  <span className="material-symbols-outlined text-accent-deep text-3xl">
                    {item.icon}
                  </span>
                </div>
                <h3 className="font-body-strong text-navy-deep text-sm mb-1">{item.name}</h3>
                <p className="text-accent-deep font-bold text-sm">R{item.price}/mo</p>
                <Link
                  href={`/pricing${quoteQuery({ boxes: {}, loose: { [item.id]: 1 } })}#calculator`}
                  className="mt-4 w-full border border-accent-deep text-accent-deep py-2 rounded-lg font-body-strong text-sm hover:bg-accent hover:text-on-accent transition-colors"
                >
                  Add to Quote
                </Link>
              </div>
            ))}

            {/* Custom item card */}
            <div className="bg-surface-white border-2 border-dashed border-accent-deep/40 rounded-xl p-6 flex flex-col items-center text-center hover:border-accent-deep transition-colors">
              <div className="w-12 h-12 rounded-full bg-accent/10 flex items-center justify-center mb-3">
                <span className="material-symbols-outlined text-accent-deep text-2xl">add</span>
              </div>
              <h3 className="font-body-strong text-navy-deep text-sm mb-1">Custom Item</h3>
              <p className="text-on-surface-variant text-xs mb-4">Specify dimensions</p>
              <Link
                href="/contact"
                className="w-full border border-accent-deep text-accent-deep py-2 rounded-lg font-body-strong text-sm hover:bg-accent hover:text-on-accent transition-colors"
              >
                Ask Us
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* How pricing works */}
      <section className="py-14 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-headline-h1 font-bold text-navy-deep mb-5">
                How loose item pricing works
              </h2>
              <p className="text-on-surface-variant text-body-main mb-6">
                We work out the cubic metres your item takes up in our facility and charge for that. No rounded-up guesses and no flat furniture fee.
              </p>
              <div className="space-y-4">
                {[
                  { icon: "straighten", text: "We measure your item's dimensions (L × W × H)" },
                  { icon: "calculate", text: "Calculate the exact m³ of space used in our facility" },
                  { icon: "receipt", text: "Charge a flat per-m³ monthly rate — no surprises" },
                ].map(({ icon, text }) => (
                  <div key={text} className="flex items-start gap-3">
                    <span className="material-symbols-outlined text-accent-deep shrink-0">{icon}</span>
                    <p className="text-body-main text-on-surface-variant">{text}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className="bg-surface-white rounded-xl p-8 shadow-tactile">
              <h3 className="text-headline-h3 font-bold text-navy-deep mb-6">An example</h3>
              <div className="space-y-4 text-sm">
                <div className="flex justify-between py-3 border-b border-outline-variant">
                  <span className="text-on-surface-variant">Item</span>
                  <span className="font-body-strong text-navy-deep">Dining Table</span>
                </div>
                <div className="flex justify-between py-3 border-b border-outline-variant">
                  <span className="text-on-surface-variant">Dimensions</span>
                  <span className="font-body-strong text-navy-deep">160 × 90 × 75 cm</span>
                </div>
                <div className="flex justify-between py-3 border-b border-outline-variant">
                  <span className="text-on-surface-variant">Volume</span>
                  <span className="font-body-strong text-navy-deep">1.08 m³</span>
                </div>
                <div className="flex justify-between py-3 bg-accent/10 rounded-lg px-3">
                  <span className="font-body-strong text-navy-deep">Monthly cost</span>
                  <span className="font-bold text-accent-deep text-base">
                    {example ? `R${example.price}/mo` : "See the list above"}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <ClosingCta
        tone="white"
        title="Not sure what something will cost?"
        body="Add boxes, loose items and a vehicle in the quote builder and see the whole figure in one place."
        secondary={{ href: "/contact", label: "Ask us" }}
      />
    </>
  );
}
