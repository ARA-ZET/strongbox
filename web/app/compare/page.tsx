import type { Metadata } from "next";
import Link from "next/link";
import ComparisonTable from "@/components/ComparisonTable";
import { COMPARISON_ROWS, VERDICT, withLivePrices } from "@/lib/comparison";
import { APP_URL } from "@/lib/constants";
import { getPrices } from "@/lib/prices";
import Illustration from "@/components/graphics/Illustration";
import SitePhoto from "@/components/SitePhoto";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    title: "StrongBox vs Self-Storage in Cape Town",
    description: `An honest comparison of valet storage, self-storage units, DIY storage and removal-company warehousing in Cape Town — including the cases where we are the wrong choice. StrongBox from R${boxFrom}/month.`,
    path: "/compare",
  });
}

export default async function ComparePage() {
  const { boxFrom: BOX_FROM, boxes } = await getPrices();
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Compare", path: "/compare" }])} />
      {/* Hero */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              The Honest Comparison
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-4">
              Four ways to store your stuff in Cape Town
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl mb-6">
              We sell one of these four, so read the table with that in mind. We have
              tried to write it the way we would explain it on the phone — including the
              jobs we would lose.
            </p>
            <p className="text-xs text-on-surface-variant max-w-xl">
              Our figures are our live rate card. The others are Cape Town market ranges
              as at 2026 and will vary by suburb, unit size and season — check a current
              quote before you decide.
            </p>
          </div>
          <Illustration name="checklist" priority className="max-w-[380px] mx-auto" />
        </div>
      </section>

      {/* The table */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <ComparisonTable rows={withLivePrices(COMPARISON_ROWS, boxes)} />
        </div>
      </section>

      {/* Where we lose */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-12">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              Straight Answers
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep">{VERDICT.heading}</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter">
            {VERDICT.points.map(({ title, body }) => (
              <div
                key={title}
                className="bg-surface-white rounded-xl p-8 shadow-tactile border border-outline-variant"
              >
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-3">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
          <p className="text-center text-on-surface-variant text-sm mt-10 max-w-2xl mx-auto">
            If one of those is you,{" "}
            <Link href="/contact" className="text-accent-deep font-body-strong hover:underline">
              tell us anyway
            </Link>
            . We would rather point you somewhere better than take a booking you will
            cancel in a month.
          </p>
        </div>
      </section>

      {/* Where we win */}
      <section className="py-20 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            <SitePhoto id="qr-scan" className="md:order-2 shadow-tactile" />
            <div className="md:order-1">
              <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
                Where We Are Clearly Better
              </span>
              <h2 className="text-headline-h1 font-bold text-navy-deep mb-6">
                Boxes, not lockers
              </h2>
              <p className="text-on-surface-variant text-body-main mb-8">
                The smallest self-storage unit in Cape Town is bigger than most people
                need. If what you are storing is a few boxes, a bicycle and a suitcase,
                you are renting a lot of empty air — and driving to it. Past three or
                four boxes the rand tips the other way, and we will say so.
              </p>
              <div className="space-y-5">
                {[
                  {
                    icon: "package_2",
                    title: "Priced per box",
                    desc: `From R${BOX_FROM} a month. Store six boxes, pay for six boxes.`,
                  },
                  {
                    icon: "home",
                    title: "Nobody drives anywhere",
                    desc: "Collection and return happen at your door, booked online.",
                  },
                  {
                    icon: "photo_library",
                    title: "You can see what you stored",
                    desc: "Every box is photographed and barcoded to your account.",
                  },
                ].map(({ icon, title, desc }) => (
                  <div key={title} className="flex items-start gap-4">
                    <div className="w-10 h-10 rounded-lg bg-sky-tint flex items-center justify-center shrink-0">
                      <span className="material-symbols-outlined text-accent-deep">{icon}</span>
                    </div>
                    <div>
                      <h3 className="font-body-strong text-navy-deep">{title}</h3>
                      <p className="text-on-surface-variant text-sm">{desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h1 font-bold text-surface-white mb-4">
            Put a number on it
          </h2>
          <p className="text-on-navy-variant mb-10 max-w-xl mx-auto">
            Work out what a self-storage unit would actually cost you over a year, then
            compare it with what you would pay us for the same load.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/tools/savings-calculator"
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:opacity-90 transition-all inline-flex items-center justify-center gap-2"
            >
              Compare the costs
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
            <a
              href={`${APP_URL}/register`}
              className="border-2 border-surface-white/30 text-surface-white px-10 py-4 rounded-xl font-body-strong hover:bg-surface-white/10 transition-all"
            >
              Get Started
            </a>
          </div>
        </div>
      </section>
    </>
  );
}
