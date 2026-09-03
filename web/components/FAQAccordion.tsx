"use client";

import { useState } from "react";
import { FAQ_ITEMS } from "@/lib/constants";
import Illustration from "@/components/graphics/Illustration";

export default function FAQAccordion() {
  const [open, setOpen] = useState<number | null>(null);

  return (
    <section className="py-24 bg-mist" id="faq">
      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
        <div className="text-center mb-14">
          <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
            Common Questions
          </span>
          <h2 className="text-headline-h1 font-bold text-navy-deep">Everything you need to know</h2>
          <p className="text-on-surface-variant mt-3 max-w-xl mx-auto">
            Insurance, turnaround times, packing materials and the small print — answered
            before you have to ask.
          </p>
        </div>
        <div className="grid lg:grid-cols-[minmax(0,360px)_minmax(0,1fr)] gap-12 items-start max-w-4xl lg:max-w-none mx-auto">
          <div className="hidden lg:block lg:sticky lg:top-28">
            <Illustration name="questions" className="max-w-[340px]" />
          </div>
          <div className="space-y-3">
          {FAQ_ITEMS.map((item, idx) => (
            <div
              key={idx}
              className="bg-surface-white rounded-xl border border-navy-deep/8 overflow-hidden shadow-tactile"
            >
              <button
                className="w-full flex justify-between items-center p-6 text-left gap-4"
                onClick={() => setOpen(open === idx ? null : idx)}
                aria-expanded={open === idx}
              >
                <span className="font-body-strong text-navy-deep">{item.q}</span>
                <span
                  className={`material-symbols-outlined text-accent-deep shrink-0 transition-transform duration-200 ${
                    open === idx ? "rotate-180" : ""
                  }`}
                >
                  expand_more
                </span>
              </button>
              {open === idx && (
                <div className="px-6 pb-6 text-on-surface-variant text-body-main border-t border-navy-deep/5 pt-4">
                  {item.a}
                </div>
              )}
            </div>
          ))}
          </div>
        </div>
      </div>
    </section>
  );
}
