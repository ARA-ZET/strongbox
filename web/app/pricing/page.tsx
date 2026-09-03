import type { Metadata } from "next";
import Link from "next/link";
import FullCalculator from "@/components/FullCalculator";
import { APP_URL, BOX_TYPES, BOX_FROM, LOOSE_ITEM_FROM, CUSTOMER_COUNT } from "@/lib/constants";
import SitePhoto from "@/components/SitePhoto";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd, serviceJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "Pricing — Flexible Volume-Based Storage",
  description: `StrongBox pricing starts from R${BOX_FROM}/month. No hidden fees, no lock-in contracts. Pay only for the space you actually use in Cape Town.`,
  path: "/pricing",
});

const benefits = [
  "Climate Controlled Storage",
  "Photo Cataloging (Digital Inventory)",
  "24/7 Monitored, Access-Controlled Facility",
  "Next-Day Delivery Notice",
];

export default function PricingPage() {
  return (
    <>
      <JsonLd
        data={[
          breadcrumbJsonLd([{ name: "Pricing", path: "/pricing" }]),
          serviceJsonLd(),
        ]}
      />
      {/* Hero */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Pricing Transparency
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-4">
              Flexible Volume-Based Pricing
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              No more paying for empty space. With StrongBox, you only pay for exactly what you store. Scalable solutions that grow and shrink with your needs.
            </p>
          </div>
          <SitePhoto id="box-lineup" className="shadow-tactile" />
        </div>
      </section>

      {/* Box types + Loose items */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h2 font-bold text-navy-deep text-center mb-10">How We Charge</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-gutter">
            {/* StrongBox units */}
            <div className="bg-mist rounded-xl p-8 border border-navy-deep/5">
              <div className="flex items-center gap-3 mb-6">
                <span className="material-symbols-outlined text-accent-deep text-2xl">inventory_2</span>
                <div>
                  <h3 className="text-headline-h3 font-bold text-navy-deep">StrongBox Units</h3>
                  <p className="text-on-surface-variant text-sm">
                    Choose the size that fits your items. Charged per unit per month.
                  </p>
                </div>
              </div>
              <div className="space-y-4">
                {BOX_TYPES.map(({ id, label, price }) => (
                  <div key={id} className="flex justify-between items-center py-4 border-b border-navy-deep/8 last:border-0">
                    <span className="font-body-strong text-navy-deep">{label}</span>
                    <span className="text-accent-deep font-bold">R{price}/mo</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Loose items */}
            <div className="bg-mist rounded-xl p-8 border border-navy-deep/5">
              <div className="flex items-center gap-3 mb-6">
                <span className="material-symbols-outlined text-accent-deep text-2xl">chair</span>
                <div>
                  <h3 className="text-headline-h3 font-bold text-navy-deep">Loose Items</h3>
                  <p className="text-on-surface-variant text-sm">
                    Items too big for a box are charged based on their unique dimensions.
                  </p>
                </div>
              </div>
              <div className="bg-surface-white rounded-xl p-6 italic text-on-surface-variant text-body-main border border-navy-deep/5 mb-6">
                &ldquo;Bikes, golf clubs, surfboards, or single furniture items — we calculate the exact space they occupy to ensure you get the fairest price in Cape Town.&rdquo;
              </div>
              <div className="flex items-center gap-6">
                {[
                  { icon: "pedal_bike", label: "Gear" },
                  { icon: "chair", label: "Furniture" },
                  { icon: "construction", label: "Equipment" },
                ].map(({ icon, label }) => (
                  <div key={label} className="flex flex-col items-center gap-1">
                    <span className="material-symbols-outlined text-accent-deep text-3xl">{icon}</span>
                    <span className="text-xs font-label-caps text-on-surface-variant uppercase tracking-widest">
                      {label}
                    </span>
                  </div>
                ))}
              </div>
              <div className="mt-6">
                <Link
                  href="/loose-items"
                  className="text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1 text-sm"
                >
                  Browse all loose items — from R{LOOSE_ITEM_FROM}/mo
                  <span className="material-symbols-outlined text-sm">arrow_forward</span>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Full Calculator */}
      <section className="py-24 bg-mist" id="calculator">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-12">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              Cost Estimator
            </span>
            <h2 className="text-headline-h2 font-bold text-navy-deep mb-3">
              Calculate Your Custom Quote
            </h2>
            <p className="text-on-surface-variant max-w-xl mx-auto">
              Use our interactive tool to build your storage plan. See exactly what you&apos;ll pay before you book.
            </p>
          </div>
          <FullCalculator />
        </div>
      </section>

      {/* Standard benefits */}
      <section className="py-20 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h3 className="text-headline-h3 font-bold text-navy-deep mb-8">
            Standard Benefits for All Customers
          </h3>
          <div className="bg-surface-white rounded-xl overflow-hidden shadow-tactile border border-navy-deep/5">
            {benefits.map((benefit, i) => (
              <div
                key={benefit}
                className={`flex justify-between items-center py-5 px-6 ${
                  i < benefits.length - 1 ? "border-b border-navy-deep/5" : ""
                } hover:bg-mist transition-colors`}
              >
                <span className="font-body-strong text-navy-deep">{benefit}</span>
                <span className="flex items-center gap-2 text-emerald-600 font-body-strong text-sm">
                  <span className="material-symbols-outlined text-base">check_circle</span>
                  Included
                </span>
              </div>
            ))}
          </div>

          {/*
            Stated where people evaluate the price, not only in the FAQ and the
            terms. Insurance is the one thing a prospect is likely to assume is
            bundled — it is not, and finding that out after collection day is
            the worst possible moment.
          */}
          <div className="mt-8 flex items-start gap-4 rounded-xl border border-outline-variant bg-mist p-6">
            <span className="material-symbols-outlined text-accent-deep shrink-0" aria-hidden="true">
              info
            </span>
            <div>
              <h4 className="font-body-strong text-navy-deep mb-1">
                Insurance is not included — you insure your own goods
              </h4>
              <p className="text-on-surface-variant text-sm">
                We are a storage and transport service, not an insurer. In South Africa
                your household contents policy is normally the right place for this, and
                most insurers will extend it to goods held in storage once you tell them
                where the items are. Have a word with your insurer or broker before
                collection day. Every box is photographed and barcoded to your account,
                so you have the record a claim would need.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="bg-navy-deep rounded-3xl p-14 text-center relative overflow-hidden">
            <div
              className="absolute inset-0 opacity-10 pointer-events-none"
              style={{
                backgroundImage:
                  "radial-gradient(circle at 2px 2px, rgba(255,255,255,0.2) 1px, transparent 0)",
                backgroundSize: "32px 32px",
              }}
            />
            <h2 className="text-headline-h1 font-bold text-surface-white mb-5 relative z-10">
              Ready to reclaim your space?
            </h2>
            <p className="text-surface-white/70 max-w-2xl mx-auto mb-10 text-lg relative z-10">
              Join {CUSTOMER_COUNT} Cape Town residents who have extended their closets with StrongBox. Secure, valet-managed, and 100% stress-free.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center relative z-10">
              <a
                href={`${APP_URL}/register`}
                className="bg-accent text-on-accent h-[56px] px-12 rounded-full font-body-strong text-lg hover:shadow-xl transition-all"
              >
                Get Started Today
              </a>
              <Link
                href="/contact"
                className="border-2 border-surface-white/30 text-surface-white h-[56px] px-12 rounded-full font-body-strong text-lg hover:bg-surface-white/10 transition-all"
              >
                Schedule a Consult
              </Link>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
