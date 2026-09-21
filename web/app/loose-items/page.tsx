"use client";

import { useState } from "react";
import { LOOSE_ITEMS, LOOSE_ITEM_CATEGORIES } from "@/lib/constants";
import Illustration from "@/components/graphics/Illustration";
import SitePhoto from "@/components/SitePhoto";
import Link from "next/link";
import SectionDivider from "@/components/graphics/SectionDivider";

export default function LooseItemsPage() {
  const [activeCategory, setActiveCategory] = useState<string>("All");

  const filtered =
    activeCategory === "All"
      ? LOOSE_ITEMS
      : LOOSE_ITEMS.filter((item) => item.category === activeCategory);

  return (
    <>
      {/* Hero */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Loose Items Storage
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-4">
              We Store More Than Just Boxes
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              Add furniture and oversized items that won&apos;t fit in a standard valet box. We handle everything from beds to office chairs. Priced by the exact space they occupy.
            </p>
          </div>
          <SitePhoto id="loose-items-load" className="shadow-tactile" />
        </div>
      </section>

      {/* Category filter + grid */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
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
                  href="/pricing#calculator"
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
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
                Fair Pricing
              </span>
              <h2 className="text-headline-h2 font-bold text-navy-deep mb-5">
                How Loose Item Pricing Works
              </h2>
              <p className="text-on-surface-variant text-body-main mb-6">
                We calculate the exact cubic metres your item occupies in our facility. No rounded-up guesses, no flat furniture fees — just accurate, honest pricing.
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
              <Illustration name="pricing" className="max-w-[220px] mx-auto mb-6" />
              <h3 className="text-headline-h3 font-bold text-navy-deep mb-6">Example Calculation</h3>
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
                  <span className="font-bold text-accent-deep text-base">R145/mo</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <SectionDivider from="mist" to="navyDeep" variant="angle" />

      {/* CTA */}
      <section className="py-16 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h1 font-bold text-surface-white mb-4">
            Not sure what something will cost?
          </h2>
          <p className="text-on-navy-variant mb-8 max-w-xl mx-auto">
            Use our full quote builder to add boxes, loose items, and choose your vehicle — all in one place.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/pricing#calculator"
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:opacity-90 transition-all"
            >
              Open Full Calculator
            </Link>
            <Link
              href="/contact"
              className="border-2 border-surface-white/30 text-surface-white px-10 py-4 rounded-xl font-body-strong hover:bg-surface-white/10 transition-all"
            >
              Ask Our Team
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
