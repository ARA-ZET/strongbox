import type { Metadata } from "next";
import Link from "next/link";
import QuickCalculator from "@/components/QuickCalculator";
import FacilityProof from "@/components/FacilityProof";
import FAQAccordion from "@/components/FAQAccordion";
import ComparisonTable from "@/components/ComparisonTable";
import SitePhoto from "@/components/SitePhoto";
import SectionDivider from "@/components/graphics/SectionDivider";
import { DeliveryVanArt } from "@/components/graphics/Illustrations";
import { PALETTE } from "@/lib/palette";
import { FEATURED_ROWS, withLivePrices } from "@/lib/comparison";
import { STORAGE_MODES, USE_CASES } from "@/lib/service-details";
import JsonLd from "@/components/JsonLd";
import { pageMeta, faqJsonLd, serviceJsonLd } from "@/lib/seo";
import { TESTIMONIALS, APP_URL, CUSTOMER_COUNT } from "@/lib/constants";
import { getPrices } from "@/lib/prices";

export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    title: "Cape Town's First Valet Storage Service | StrongBox",
    description: `StrongBox collects, stores, and returns your belongings on demand in Cape Town. No lock-in contracts. Monitored, climate-controlled facility. From R${boxFrom}/month.`,
    path: "",
  });
}

/**
 * The four claims that answer a first-time visitor's immediate objections.
 * They sit inside the hero rather than in a band below it: as their own
 * section the headings landed below the fold, so the first screen carried the
 * pitch with nothing supporting it.
 */
const HERO_BADGES = [
  { icon: "shield", label: "Monitored facility" },
  { icon: "schedule", label: "Same-day collection" },
  { icon: "event_repeat", label: "No lock-in" },
  { icon: "phone_iphone", label: "24/7 dashboard" },
];

const STEPS = [
  {
    num: "01",
    icon: "event_available",
    title: "Book online",
    body: "Pick a date and a window — morning, afternoon or evening. Tell us roughly what you are storing and the quote is built before anyone arrives.",
  },
  {
    num: "02",
    icon: "inventory",
    title: "We collect",
    body: "Our team does the lifting at your door. Every box is photographed and barcoded to your account before it leaves.",
  },
  {
    num: "03",
    icon: "local_shipping",
    title: "Request it back",
    body: "Need something? Tap it in the app and we deliver it back to your door, usually the next working day.",
  },
];

export default async function HomePage() {
  const prices = await getPrices();
  const { boxes: BOX_TYPES, boxFrom: BOX_FROM } = prices;
  return (
    <>
      {/* The homepage renders the FAQ block and the rate card, so it is the
          page entitled to carry their markup. */}
      <JsonLd data={[faqJsonLd(), serviceJsonLd(BOX_TYPES)]} />
      {/* ── Hero ── */}
      <section className="bg-navy-deep relative overflow-hidden flex items-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-gutter items-center py-14 md:py-20 relative z-10">
          <div className="text-surface-white">
            <h1 className="text-display-bold font-bold text-surface-white mb-6 leading-tight">
              Storage that comes to you
            </h1>
            <p className="text-on-navy text-body-main mb-8 max-w-lg">
              We collect your boxes from your door, store them in a monitored,
              climate-controlled facility in Cape Town, and bring them back whenever you
              ask. No truck to hire, no unit to visit, no lock-in.
            </p>

            <div className="flex flex-wrap gap-4 mb-10">
              <Link
                href="/pricing"
                className="bg-accent text-on-accent h-[56px] px-8 rounded-xl font-body-strong flex items-center gap-2 hover:bg-accent-deep transition-colors"
              >
                Get a free quote
                <span className="material-symbols-outlined">arrow_forward</span>
              </Link>
              <Link
                href="/how-it-works"
                className="border-2 border-surface-white/40 text-surface-white h-[56px] px-8 rounded-xl font-body-strong hover:bg-surface-white hover:text-navy-deep hover:border-surface-white transition-all flex items-center justify-center"
              >
                See how it works
              </Link>
            </div>

            {/* Trust strip — inside the hero, so proof is on the first screen. */}
            <ul className="flex flex-wrap gap-x-6 gap-y-3 border-t border-surface-white/10 pt-6">
              {HERO_BADGES.map(({ icon, label }) => (
                <li key={label} className="flex items-center gap-2 text-on-navy text-sm">
                  <span className="material-symbols-outlined text-sky text-lg" aria-hidden="true">
                    {icon}
                  </span>
                  {label}
                </li>
              ))}
            </ul>
          </div>

          <div className="relative mt-12 md:mt-0">
            <div className="relative">
              <SitePhoto id="hero-collection" tone="dark" />
              <div className="absolute bottom-6 left-6 bg-surface-white p-4 rounded-xl shadow-tactile-md flex items-center gap-3">
                <div className="w-3 h-3 rounded-full bg-emerald-500" />
                <p className="text-navy-deep font-body-strong text-sm">Items collected safely</p>
              </div>
            </div>
          </div>
        </div>
        {/* Decorative */}
        <div className="absolute right-0 top-0 w-1/3 h-full bg-navy opacity-30 transform translate-x-1/2 -skew-x-12 pointer-events-none" />
      </section>

      <SectionDivider from="navyDeep" to="white" variant="wave" size="sm" />

      {/* ── How it works ── */}
      <section className="pt-14 pb-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep tracking-widest uppercase text-xs mb-3 block">
              The Process
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep">
              Three steps, none of them involve a truck
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter relative">
            {STEPS.map(({ num, icon, title, body }) => (
              <div
                key={num}
                className="bg-surface-white border border-outline-variant p-10 rounded-xl shadow-tactile card-hover relative z-10"
              >
                <span className="absolute top-6 right-6 text-4xl font-bold text-outline-variant">
                  {num}
                </span>
                <div className="w-12 h-12 rounded-lg bg-sky-tint flex items-center justify-center mb-6">
                  <span className="material-symbols-outlined text-accent-deep text-3xl">{icon}</span>
                </div>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-3">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
            <div className="hidden md:block absolute top-1/2 left-0 w-full h-[2px] border-t-2 border-dashed border-outline-variant -translate-y-1/2 z-0" />
          </div>
          <div className="text-center mt-10">
            <Link
              href="/how-it-works"
              className="text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
            >
              See the full process
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>

      {/* ── Who it's for ── */}
      {/*
        Self-identification. A visitor who recognises their own situation in
        one of these six converts far better than one who has to work out
        whether a generic "storage" pitch applies to them.
      */}
      <section className="py-24 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep tracking-widest uppercase text-xs mb-3 block">
              Who It&apos;s For
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              Most people come to us for one of six reasons
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              If one of these is your situation, the service was built for it.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-gutter">
            {USE_CASES.map(({ icon, title, body }) => (
              <div
                key={title}
                className="bg-surface-white rounded-xl p-8 border border-outline-variant shadow-tactile card-hover"
              >
                <div className="w-11 h-11 rounded-lg bg-sky-tint flex items-center justify-center mb-5">
                  <span className="material-symbols-outlined text-accent-deep text-2xl">{icon}</span>
                </div>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-2">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Two ways to store ── */}

      {/*
        The closed/open choice is the biggest functional difference in what
        the service can do for someone, and it was documented in the product
        spec but absent from the site entirely.
      */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep tracking-widest uppercase text-xs mb-3 block">
              Two Ways To Store
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              Sealed and untouched, or catalogued item by item
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              You choose per box, and you can mix the two. The difference decides how
              precisely you can reach back into storage later.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-gutter">
            {STORAGE_MODES.map(({ id, name, icon, tagline, body, bestFor, points }) => (
              <div
                key={id}
                className="bg-surface-white rounded-xl shadow-tactile border border-outline-variant flex flex-col overflow-hidden"
              >
                {/*
                  Closed versus open is a difference you can see in a second
                  and only understand slowly from prose, so the picture leads
                  and the text explains what it means.
                */}
                <SitePhoto
                  id={id === "closed" ? "storage-closed-box" : "storage-open-box"}
                  rounded=""
                />

                <div className="p-8 md:p-10 flex flex-col flex-1">
                <div className="flex items-center gap-4 mb-5">
                  <div className="w-12 h-12 rounded-lg bg-sky-tint flex items-center justify-center shrink-0">
                    <span className="material-symbols-outlined text-accent-deep text-3xl">
                      {icon}
                    </span>
                  </div>
                  <div>
                    <h3 className="text-headline-h3 font-bold text-navy-deep">{name}</h3>
                    <p className="text-sm text-accent-deep font-body-strong">{tagline}</p>
                  </div>
                </div>

                <p className="text-on-surface-variant text-body-main mb-6">{body}</p>

                <ul className="space-y-2.5 mb-6">
                  {points.map((point) => (
                    <li key={point} className="flex items-start gap-3 text-navy-deep text-sm">
                      <span
                        aria-hidden="true"
                        className="material-symbols-outlined text-accent-deep text-lg shrink-0"
                      >
                        check_circle
                      </span>
                      {point}
                    </li>
                  ))}
                </ul>

                <p className="mt-auto pt-5 border-t border-outline-variant text-sm text-on-surface-variant">
                  <span className="font-body-strong text-navy-deep">Best for: </span>
                  {bestFor}
                </p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Proof: inside the facility ── */}
      <FacilityProof tone="mist" />

      {/* ── Comparison strip ── */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-12">
            <span className="font-label-caps text-accent-deep tracking-widest uppercase text-xs mb-3 block">
              Versus The Alternatives
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              Stop renting space you don&apos;t use
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              The smallest self-storage unit in Cape Town is bigger than most people
              need. Pay by the box instead — and let someone else do the driving.
            </p>
          </div>
          <ComparisonTable rows={withLivePrices(FEATURED_ROWS, BOX_TYPES)} />
          <div className="text-center mt-10">
            <Link
              href="/compare"
              className="text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
            >
              See the full comparison — including where we lose
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>

      <SectionDivider from="white" to="navyDeep" variant="angle" />

      {/* ── Simple pricing ── */}
      <section className="py-24 bg-navy-deep text-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            <div>
              <span className="font-label-caps text-sky tracking-widest uppercase text-xs mb-4 block">
                Simple Pricing
              </span>
              <h2 className="text-headline-h1 font-bold mb-6">
                From R{BOX_FROM} per box, per month
              </h2>
              <p className="text-on-navy text-lg mb-8">
                No rigid plans and no paying for empty space. You pay for the boxes and
                items you actually store, billed monthly — cancel any time.
              </p>
              <div className="space-y-5">
                {[
                  {
                    icon: "inventory_2",
                    title: "Box-level precision",
                    desc: "Four standard sizes, priced individually. Add or remove boxes as your life changes.",
                  },
                  {
                    icon: "shopping_basket",
                    title: "Loose and oversized items",
                    desc: "Bicycles, surfboards and furniture are priced by the space they actually occupy.",
                  },
                  {
                    icon: "verified",
                    title: "Everything else included",
                    desc: "Photo inventory, barcode tracking and your dashboard cost nothing extra.",
                  },
                ].map(({ icon, title, desc }) => (
                  <div key={title} className="flex items-start gap-4">
                    <div className="bg-surface-white/10 p-2 rounded-lg shrink-0">
                      <span className="material-symbols-outlined text-sky">{icon}</span>
                    </div>
                    <div>
                      <h3 className="font-body-strong">{title}</h3>
                      <p className="text-on-navy-variant text-sm">{desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {BOX_TYPES.map(({ id, label, price, desc }) => (
                <div
                  key={id}
                  className="bg-surface-white/5 border border-surface-white/10 p-6 rounded-xl hover:bg-surface-white/10 transition-colors"
                >
                  <p className="font-label-caps text-sky uppercase text-xs mb-2">{label}</p>
                  <div className="flex items-baseline gap-1 mb-3">
                    <span className="text-2xl font-bold">R{price}</span>
                    <span className="text-on-navy-variant text-xs">/mo</span>
                  </div>
                  <p className="text-xs text-on-navy-variant">{desc}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <SectionDivider from="navyDeep" to="mist" variant="wave" />

      {/* ── Calculator ── */}
      <QuickCalculator prices={prices} />

      {/* ── Testimonials ── */}
      <section className="py-24 bg-navy">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="mb-14">
            <h2 className="text-headline-h1 font-bold text-surface-white mb-2">
              Trusted by {CUSTOMER_COUNT} Capetonians
            </h2>
            <p className="text-on-navy-variant">
              See how we&apos;re changing the way the city lives.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter">
            {TESTIMONIALS.map(({ quote, name, initials, location, stars }) => (
              <div
                key={name}
                className="bg-surface-white/10 p-8 rounded-xl border border-surface-white/5"
              >
                <div className="flex gap-1 mb-4" aria-label={`${stars} out of 5 stars`}>
                  {Array.from({ length: stars }).map((_, i) => (
                    <span
                      key={i}
                      aria-hidden="true"
                      className="material-symbols-outlined material-symbols-filled text-sky"
                    >
                      star
                    </span>
                  ))}
                </div>
                <p className="text-on-navy italic mb-8 text-body-main">&ldquo;{quote}&rdquo;</p>
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-sky text-navy-deep flex items-center justify-center font-bold text-sm">
                    {initials}
                  </div>
                  <div>
                    <p className="text-surface-white font-body-strong">{name}</p>
                    <p className="text-xs text-on-navy-variant">{location}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── FAQ ── */}
      <FAQAccordion />

      {/* ── Closing CTA ── */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="bg-accent rounded-xl p-10 md:p-14 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8">
            <div className="relative z-10">
              <h2 className="text-headline-h1 font-bold text-on-accent mb-3">
                Ready to reclaim your space?
              </h2>
              <p className="text-on-accent/90 text-lg max-w-xl">
                The service starts at your door, stores your boxes safely, and ends right
                back at your door. Pay by the box, not by the locker.
              </p>
            </div>
            <div className="relative z-10 flex flex-col sm:flex-row gap-4 shrink-0">
              <a
                href={`${APP_URL}/register`}
                className="bg-navy-deep text-surface-white px-8 py-4 rounded-xl font-body-strong shadow-lg hover:bg-navy transition-colors text-center"
              >
                Get started
              </a>
              <Link
                href="/contact"
                className="bg-surface-white text-navy-deep px-8 py-4 rounded-xl font-body-strong hover:bg-sky-tint transition-colors text-center"
              >
                Speak to an expert
              </Link>
            </div>
            <div className="absolute -right-16 -bottom-16 w-72 h-72 bg-navy-deep/10 rounded-full pointer-events-none" />
            <div className="absolute -left-16 -top-16 w-56 h-56 bg-navy-deep/10 rounded-full pointer-events-none" />
            {/* Van watermark — reinforces "we bring it back" without stealing the CTA */}
            <div className="hidden lg:block absolute -right-4 -bottom-6 w-[280px] text-navy-deep opacity-[0.18] pointer-events-none">
              <DeliveryVanArt accent="currentColor" surface={PALETTE.accent} />
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
