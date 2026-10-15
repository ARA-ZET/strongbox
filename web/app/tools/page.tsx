import type { Metadata } from "next";
import Link from "next/link";
import Illustration from "@/components/graphics/Illustration";
import { getPrices, type Prices } from "@/lib/prices";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "Free Storage Tools & Calculators",
  description:
    "Free tools for working out what storage should cost you in Cape Town: a cost comparison against self-storage, a full quote builder, and per-item pricing for furniture and gear.",
  path: "/tools",
});

const tools = ({ boxFrom, looseItemFrom }: Prices) => [
  {
    href: "/tools/savings-calculator",
    icon: "savings",
    title: "Cost Comparison",
    body: "What a self-storage unit actually costs you over a year — rent plus the driving — against paying us by the box, break-even included.",
    cta: "Open tool",
    badge: "Most used",
  },
  {
    href: "/pricing#calculator",
    icon: "calculate",
    title: "Quote Builder",
    body: `Add boxes, loose items and a collection vehicle to build your exact monthly figure. From R${boxFrom} a box.`,
    cta: "Open tool",
  },
  {
    href: "/loose-items",
    icon: "chair",
    title: "Loose Item Pricer",
    body: `Bikes, surfboards, beds, appliances — see what each one costs to store, priced by the space it occupies. From R${looseItemFrom}.`,
    cta: "Open tool",
  },
];

export default async function ToolsPage() {
  const TOOLS = tools(await getPrices());
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Free Tools", path: "/tools" }])} />
      {/* Hero */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Free Tools
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-4">
              Work out the number before you talk to anyone
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              No email address, no account, no sales call. Three calculators that use our
              real rate card, so what you see here is what you would be quoted.
            </p>
          </div>
          <Illustration name="pricing" priority className="max-w-[340px] mx-auto" />
        </div>
      </section>

      {/* Tool cards */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter">
            {TOOLS.map(({ href, icon, title, body, cta, badge }) => (
              <Link
                key={href}
                href={href}
                className="group relative bg-surface-white border border-outline-variant rounded-xl p-8 shadow-tactile card-hover flex flex-col"
              >
                {badge && (
                  <span className="absolute top-6 right-6 bg-sky-tint text-accent-deep text-xs font-bold px-3 py-1 rounded-full">
                    {badge}
                  </span>
                )}
                <div className="w-12 h-12 rounded-lg bg-sky-tint flex items-center justify-center mb-6">
                  <span className="material-symbols-outlined text-accent-deep text-3xl">{icon}</span>
                </div>
                <h2 className="text-headline-h3 font-bold text-navy-deep mb-3">{title}</h2>
                <p className="text-on-surface-variant text-body-main mb-6 flex-1">{body}</p>
                <span className="text-accent-deep font-body-strong inline-flex items-center gap-1">
                  {cta}
                  <span className="material-symbols-outlined text-sm transition-transform group-hover:translate-x-1">
                    arrow_forward
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Guides cross-link */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="bg-surface-white rounded-xl border border-outline-variant p-10 md:p-14 flex flex-col md:flex-row items-center justify-between gap-8 shadow-tactile">
            <div>
              <h2 className="text-headline-h2 font-bold text-navy-deep mb-3">
                Not sure what to store in the first place?
              </h2>
              <p className="text-on-surface-variant max-w-xl">
                Our guides cover the decisions before the pricing — what to keep, what to
                let go, and how to pack a box that survives a year on a shelf.
              </p>
            </div>
            <Link
              href="/resources"
              className="bg-accent text-on-accent px-8 py-4 rounded-xl font-body-strong hover:bg-accent-deep transition-colors shrink-0 inline-flex items-center gap-2"
            >
              Read the guides
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
