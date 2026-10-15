import type { Metadata } from "next";
import Link from "next/link";
import SavingsCalculator from "@/components/SavingsCalculator";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
import { getPrices } from "@/lib/prices";
export const metadata: Metadata = pageMeta({
  title: "Storage Cost Comparison — Cape Town",
  description:
    "Compare a self-storage unit against paying StrongBox per box over a year in Cape Town — rent, trips and all. Shows the break-even point honestly. No email required.",
  path: "/tools/savings-calculator",
});

export default async function SavingsCalculatorPage() {
  const prices = await getPrices();
  return (
    <>
      <JsonLd
        data={breadcrumbJsonLd([
          { name: "Free Tools", path: "/tools" },
          { name: "Cost Comparison", path: "/tools/savings-calculator" },
        ])}
      />
      {/* Hero */}
      <section className="py-16 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <nav aria-label="Breadcrumb" className="mb-6">
            <Link
              href="/tools"
              className="inline-flex items-center gap-1 text-accent-deep font-body-strong text-sm hover:underline"
            >
              <span className="material-symbols-outlined text-base">arrow_back</span>
              Free tools
            </Link>
          </nav>
          <h1 className="text-display-bold font-bold text-navy-deep mb-4 max-w-3xl">
            What is a self-storage unit really costing you?
          </h1>
          <p className="text-on-surface-variant text-body-main max-w-2xl">
            A unit is billed by the locker, not by what is in it, and the rent is only
            part of the bill — every trip out there costs fuel and an afternoon. Set the
            numbers to match your situation and see the twelve-month gap, including the
            point past which a unit costs less than we do.
          </p>
        </div>
      </section>

      {/* Calculator */}
      <section className="py-12 md:py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <SavingsCalculator prices={prices} />
        </div>
      </section>

      {/* Method */}
      <section className="pb-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="bg-mist rounded-xl p-8 md:p-10 border border-outline-variant max-w-3xl">
            <h2 className="text-headline-h3 font-bold text-navy-deep mb-4">
              How this is worked out
            </h2>
            <ul className="space-y-3 text-on-surface-variant text-body-main">
              <li className="flex gap-3">
                <span className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                Unit rents are Cape Town market ranges for 2026, not quotes from any
                named operator. If you have a real figure, type it in — the comparison
                uses yours.
              </li>
              <li className="flex gap-3">
                <span className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                Trips are costed at R95 for a roughly 25 km return run in fuel and wear.
                Your time is not priced in, which favours the unit.
              </li>
              <li className="flex gap-3">
                <span className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                Our side uses the box rate you pick, our published one-off collection
                fee for a small van, and nothing else. Collection and the photo
                inventory are already inside that number.
              </li>
              <li className="flex gap-3">
                <span className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                Both sides exclude the return delivery, which is quoted when you ask for
                your items back.
              </li>
              <li className="flex gap-3">
                <span className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                Neither side includes insurance. In South Africa you insure your own
                goods in storage, normally by extending your household contents policy,
                whoever is holding them.
              </li>
            </ul>
            <p className="text-on-surface-variant text-sm mt-6">
              Storing more than a few boxes, or furniture rather than boxes? A unit
              usually wins on price.{" "}
              <Link href="/compare" className="text-accent-deep font-body-strong hover:underline">
                We spell out exactly when
              </Link>
              .
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
