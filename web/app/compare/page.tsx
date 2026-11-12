import type { Metadata } from "next";
import Link from "next/link";
import ComparisonTable from "@/components/ComparisonTable";
import { COMPARISON_ROWS, VERDICT, withLivePrices } from "@/lib/comparison";
import { getPrices } from "@/lib/prices";
import ClosingCta from "@/components/ClosingCta";
import PhotoHero from "@/components/PhotoHero";
import CustodyTrail from "@/components/visuals/CustodyTrail";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    title: "Valet Storage vs Self-Storage in Cape Town",
    description: `Valet storage, self-storage units, DIY and removal-company storage in Cape Town compared honestly, including where we lose. From R${boxFrom} a month.`,
    path: "/compare",
  });
}

export default async function ComparePage() {
  const { boxFrom: BOX_FROM, boxes } = await getPrices();
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Compare", path: "/compare" }])} />
      {/* Hero */}
      <PhotoHero
        photo="hero-compare"
        trail={[{ name: "Compare", path: "/compare" }]}
        title="Four ways to store your things in Cape Town"
        lead="We sell one of these four, so read the table with that in mind. We have tried to write it the way we would explain it on the phone, including the jobs we would lose."
      >
        <p className="mt-5 max-w-xl text-sm text-on-navy-variant">
          Our figures are our live rate card. The others are Cape Town market ranges as at
          2026 and will vary by suburb, unit size and season. Check a current quote before
          you decide.
        </p>
      </PhotoHero>

      {/* The table */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          <ComparisonTable rows={withLivePrices(COMPARISON_ROWS, boxes)} />
        </div>
      </section>

      {/* Where we lose */}
      <section className="py-14 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          <div className="mb-10 max-w-3xl">
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
          <p className="text-on-surface-variant text-sm mt-10 max-w-2xl">
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
      <section className="py-14 md:py-20 bg-surface-white">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            <CustodyTrail className="md:order-2" />
            <div className="md:order-1">
              <span className="text-[13px] font-semibold text-accent-deep mb-3 block">
                Where we are clearly better
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

      <ClosingCta
        title="Put a number on it"
        body="Work out what a self-storage unit would cost you over a year, then compare it with what you would pay us for the same load."
        primary={{ href: "/tools/savings-calculator", label: "Compare the costs" }}
        secondary={{ href: "/pricing#calculator", label: "Get a quote" }}
      />
    </>
  );
}
