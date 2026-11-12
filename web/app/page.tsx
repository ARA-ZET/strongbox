import type { Metadata } from "next";
import Link from "next/link";
import QuickCalculator from "@/components/QuickCalculator";
import SuburbChecker from "@/components/SuburbChecker";
import FacilityProof from "@/components/FacilityProof";
import FAQAccordion from "@/components/FAQAccordion";
import ComparisonTable from "@/components/ComparisonTable";
import ClosingCta from "@/components/ClosingCta";
import JsonLd from "@/components/JsonLd";
import Button from "@/components/ui/Button";
import Section from "@/components/ui/Section";
import PhotoHero from "@/components/PhotoHero";
import SitePhoto from "@/components/SitePhoto";
import SectionHeading from "@/components/ui/SectionHeading";
import IconPoint from "@/components/ui/IconPoint";
import BoxScale from "@/components/visuals/BoxScale";
import CoverageMap, { RegionList } from "@/components/visuals/CoverageMap";
import { OrderScreen, StorageScreen } from "@/components/visuals/Phone";
import { FEATURED_ROWS, withLivePrices } from "@/lib/comparison";
import { STORAGE_MODES, USE_CASES } from "@/lib/service-details";
import { pageMeta, faqJsonLd, serviceJsonLd } from "@/lib/seo";
import { getPrices } from "@/lib/prices";

export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    // "Storage" + "Cape Town" lead, because that is what people type.
    // The root layout's title template does not reach a page in its own
    // segment, so the brand is written out here.
    title: "Storage in Cape Town, Collected From Your Door | StrongBox",
    description:
    `Door-to-door storage across Cape Town. We collect your boxes and furniture, store them safely and bring them back on request. From R${boxFrom} a box per month.`,
    path: "",
  });
}

/**
 * The claims that answer a first-time visitor's immediate objections. They
 * sit inside the hero so the first screen carries the pitch and its support
 * together.
 */
const HERO_BADGES = [
  { icon: "shield", label: "Monitored facility" },
  { icon: "home", label: "Collected at your door" },
  { icon: "event_repeat", label: "No lock-in" },
  { icon: "qr_code_2", label: "Every box tracked" },
];

const STEPS = [
  {
    title: "Book online",
    body: "Pick a date and a window: morning, afternoon or evening. Tell us roughly what you are storing and the quote is built before anyone arrives.",
  },
  {
    title: "We collect",
    body: "Our team does the lifting at your door. Every box is photographed and scanned to your account before it leaves.",
  },
  {
    title: "Ask for it back",
    body: "Need something? Pick it in your account and we deliver it to your door, usually the next working day.",
  },
];

const PRICING_POINTS = [
  {
    icon: "inventory_2",
    title: "Priced per box",
    desc: "Each size has its own monthly price. Add or remove boxes as your life changes.",
  },
  {
    icon: "chair",
    title: "Loose and oversized items",
    desc: "Bicycles, surfboards and furniture are priced by the space they actually take up.",
  },
  {
    icon: "verified",
    title: "Tracking is included",
    desc: "Photo inventory, QR labels and your online account cost nothing extra.",
  },
];

export default async function HomePage() {
  const prices = await getPrices();
  const { boxes, boxFrom } = prices;
  return (
    <>
      {/* The homepage renders the FAQ block and the rate card, so it is the
          page entitled to carry their markup. */}
      <JsonLd data={[faqJsonLd(), serviceJsonLd(boxes)]} />

      {/* ── Hero ── */}
      <PhotoHero
        photo="hero-home"
        height="tall"
        eyebrow="Door-to-door storage in Cape Town"
        title="Storage that comes to you"
        lead="We collect your boxes and furniture from your door, keep them in a monitored facility, and bring them back when you ask. No truck to hire, no unit to visit, no lock-in."
        footer={
          <ul className="mt-12 grid grid-cols-2 gap-x-6 gap-y-4 border-t border-surface-white/15 pt-6 md:mt-16 md:grid-cols-4">
            {HERO_BADGES.map(({ icon, label }) => (
              <li key={label} className="flex items-center gap-2.5 text-sm font-medium text-on-navy">
                <span aria-hidden="true" className="material-symbols-outlined text-xl text-sky">
                  {icon}
                </span>
                {label}
              </li>
            ))}
          </ul>
        }
      >
        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Button href="/pricing#calculator" arrow>
            Get a quote
          </Button>
          <Button href="/how-it-works" variant="on-dark">
            See how it works
          </Button>
        </div>

        <p className="mt-6 flex items-start gap-2 text-sm text-on-navy">
          <span aria-hidden="true" className="material-symbols-outlined shrink-0 text-lg text-sky">
            location_on
          </span>
          <span>
            Anywhere in the metro, from Bloubergstrand to Gordon&apos;s Bay.{" "}
            <Link href="/areas" className="text-surface-white underline underline-offset-4 hover:text-sky">
              Check your suburb
            </Link>
          </span>
        </p>
      </PhotoHero>

      {/* ── How it works ── */}
      <Section>
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-20">
          <div>
            <SectionHeading
              title="Three steps, and none of them involves a truck"
              lead="You book, we carry, and it comes back when you ask for it."
              className="!mb-10"
            />
            <ol className="relative">
              {STEPS.map(({ title, body }, i) => (
                <li
                  key={title}
                  data-reveal
                  style={{ ["--i" as string]: i }}
                  className="relative flex gap-5 pb-9 last:pb-0"
                >
                  {i < STEPS.length - 1 && (
                    <span aria-hidden="true" className="absolute left-5 top-11 h-[calc(100%-2.75rem)] w-px bg-outline-variant" />
                  )}
                  <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-navy-deep text-sm font-bold text-surface-white">
                    {i + 1}
                  </span>
                  <div>
                    <h3 className="text-headline-h3 font-semibold text-navy-deep">{title}</h3>
                    <p className="mt-1.5 text-body-main text-on-surface-variant">{body}</p>
                  </div>
                </li>
              ))}
            </ol>
            <Link
              href="/how-it-works"
              className="mt-9 inline-flex items-center gap-1.5 font-semibold text-accent-deep hover:underline"
            >
              See the full process
              <span aria-hidden="true" className="material-symbols-outlined text-lg">arrow_forward</span>
            </Link>
          </div>

          {/* What you see while it happens: the order, and the stored item. */}
          <div className="mx-auto flex w-full max-w-[520px] items-start justify-center gap-5">
            <div className="w-[248px] shrink-0">
              <OrderScreen />
            </div>
            <div className="mt-16 hidden w-[248px] shrink-0 sm:block">
              <StorageScreen />
            </div>
          </div>
        </div>
      </Section>

      {/* ── Two ways to store ── */}
      {/*
        The closed/open choice is the biggest functional difference in what
        the service can do for someone. It is a difference you can see in a
        second and only understand slowly from prose, so the picture leads.
      */}
      <Section tone="mist">
        <SectionHeading
          title="Sealed and untouched, or listed item by item"
          lead="You choose per box, and you can mix the two. The difference decides how precisely you can reach back into storage later."
        />
        <div className="grid gap-gutter md:grid-cols-2">
          {STORAGE_MODES.map(({ id, name, tagline, body, bestFor, points }, i) => (
            <article
              key={id}
              data-reveal
              style={{ ["--i" as string]: i }}
              className="flex flex-col overflow-hidden rounded-2xl border border-outline-variant bg-surface-white"
            >
              <div className="relative aspect-[16/9] border-b border-outline-variant bg-mist">
                <SitePhoto
                  id={id === "closed" ? "box-closed" : "box-open"}
                  sizes="(min-width: 1280px) 576px, (min-width: 768px) 50vw, 100vw"
                  className="absolute inset-0"
                />
              </div>
              <div className="flex flex-1 flex-col p-6 sm:p-8">
                <p className="text-sm font-semibold text-accent-deep">{tagline}</p>
                <h3 className="mt-1 text-headline-h2 font-semibold text-navy-deep">{name}</h3>
                <p className="mt-3 text-body-main text-on-surface-variant">{body}</p>
                <ul className="mt-5 mb-auto space-y-2.5">
                  {points.map((point) => (
                    <li key={point} className="flex items-start gap-3 text-[15px] text-navy-deep">
                      <span aria-hidden="true" className="material-symbols-outlined mt-0.5 shrink-0 text-lg text-accent-deep">
                        check
                      </span>
                      {point}
                    </li>
                  ))}
                </ul>
                <p className="mt-6 border-t border-outline-variant pt-5 text-sm text-on-surface-variant">
                  <span className="font-semibold text-navy-deep">Best for: </span>
                  {bestFor}
                </p>
              </div>
            </article>
          ))}
        </div>
      </Section>

      {/* ── Who it's for ── */}
      {/*
        Self-identification. A visitor who recognises their own situation in
        one of these converts far better than one who has to work out whether
        a generic "storage" pitch applies to them. A ruled list, not a grid of
        cards: nine cards in a row is a wall, a list can be scanned.
      */}
      <Section>
        <div className="grid gap-10 lg:grid-cols-[minmax(0,4fr)_minmax(0,8fr)] lg:gap-16">
          <div data-reveal className="lg:sticky lg:top-36 lg:self-start">
            <h2 className="text-headline-h1 font-bold text-navy-deep">
              Most people come to us for one of these reasons
            </h2>
            <p className="mt-4 text-body-lead text-on-surface-variant">
              If one of them is your situation, the service was built for it.
            </p>
          </div>
          <ul className="grid gap-x-10 sm:grid-cols-2">
            {USE_CASES.map(({ icon, title, body }, i) => (
              <li
                key={title}
                data-reveal
                style={{ ["--i" as string]: i % 2 }}
                className="flex gap-4 border-t border-outline-variant py-5"
              >
                <span aria-hidden="true" className="material-symbols-outlined mt-0.5 shrink-0 text-2xl text-accent-deep">
                  {icon}
                </span>
                <div>
                  <h3 className="font-semibold text-navy-deep">{title}</h3>
                  <p className="mt-1 text-[15px] leading-relaxed text-on-surface-variant">{body}</p>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </Section>

      {/* ── Proof: inside the facility ── */}
      <FacilityProof tone="mist" />

      {/* ── Pricing ── */}
      <Section tone="navy">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div data-reveal>
            <h2 className="text-headline-h1 font-bold">From R{boxFrom} per box, per month</h2>
            <p className="mt-4 text-body-lead text-on-navy">
              No plans and no paying for empty space. You pay for the boxes and items you
              actually store, billed monthly, and you can stop at any time.
            </p>
            <div className="mt-8 space-y-6">
              {PRICING_POINTS.map(({ icon, title, desc }) => (
                <IconPoint key={title} icon={icon} title={title} dark>
                  {desc}
                </IconPoint>
              ))}
            </div>
          </div>
          <div>
            <BoxScale boxes={boxes} dark />
            <dl className="mt-6 grid grid-cols-2 gap-px overflow-hidden rounded-xl bg-surface-white/10 sm:grid-cols-4">
              {boxes.map(({ id, label, price }) => (
                <div key={id} className="bg-navy-deep p-4">
                  <dt className="text-xs text-on-navy-variant">{label}</dt>
                  <dd className="mt-1 text-xl font-bold">
                    R{price}
                    <span className="text-xs font-normal text-on-navy-variant"> /mo</span>
                  </dd>
                </div>
              ))}
            </dl>
            <p className="mt-3 text-xs text-on-navy-variant">
              Boxes drawn to scale by volume, beside a dining chair.{" "}
              <Link href="/pricing" className="text-on-navy underline underline-offset-4 hover:text-surface-white">
                Full price list
              </Link>
            </p>
          </div>
        </div>
      </Section>

      {/* ── Calculator ── */}
      <QuickCalculator prices={prices} />

      {/* ── Across Cape Town ── */}
      {/*
        "Do you come to me?" is the first question nearly every caller asks.
        Answering it on the homepage, for the whole metro, is the
        local-relevance signal that matters most to a visitor and to a suburb
        search alike.
      */}
      <Section>
        <div className="grid gap-12 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:gap-16">
          <div>
            <SectionHeading
              title="Wherever you live in Cape Town, we come to you"
              lead="One facility and one fleet, covering the whole metro. Storage costs the same in every suburb, and the collection fee depends on the vehicle you need, not on how far you are from us."
              className="!mb-8"
            />
            <div data-reveal className="rounded-2xl border border-outline-variant bg-mist p-5 sm:p-6">
              <SuburbChecker />
            </div>
            <RegionList className="mt-8" />
          </div>
          <div className="lg:sticky lg:top-36 lg:self-start">
            <CoverageMap />
          </div>
        </div>
      </Section>

      {/* ── Comparison strip ── */}
      <Section tone="mist">
        <SectionHeading
          title="Stop renting space you do not use"
          lead="The smallest self-storage unit in Cape Town is bigger than most people need. Pay by the box instead, and let someone else do the driving."
        />
        <div data-reveal>
          <ComparisonTable rows={withLivePrices(FEATURED_ROWS, boxes)} />
        </div>
        <Link
          href="/compare"
          className="mt-8 inline-flex items-center gap-1.5 font-semibold text-accent-deep hover:underline"
        >
          See the full comparison, including where we lose
          <span aria-hidden="true" className="material-symbols-outlined text-lg">arrow_forward</span>
        </Link>
      </Section>

      {/* ── FAQ ── */}
      <FAQAccordion />

      <ClosingCta
        title="Ready to get your space back?"
        body="It starts at your door and ends at your door. Price your load in about a minute; no account needed to see the number."
      />
    </>
  );
}
