import type { Metadata } from "next";
import Link from "next/link";
import FAQAccordion from "@/components/FAQAccordion";
import ClosingCta from "@/components/ClosingCta";
import JsonLd from "@/components/JsonLd";
import Button from "@/components/ui/Button";
import Section from "@/components/ui/Section";
import SectionHeading from "@/components/ui/SectionHeading";
import IconPoint from "@/components/ui/IconPoint";
import PhotoHero from "@/components/PhotoHero";
import PhotoFeature from "@/components/PhotoFeature";
import CustodyTrail from "@/components/visuals/CustodyTrail";
import { BookingScreen, OrderScreen, StorageScreen } from "@/components/visuals/Phone";
import { pageMeta, breadcrumbJsonLd, faqJsonLd } from "@/lib/seo";
import {
  COLLECTION_DAY,
  TRACKING_POINTS,
  RETRIEVAL_POINTS,
  ACCEPTED_ITEMS,
  PROHIBITED_ITEMS,
  AT_OWN_RISK,
  BILLING_POINTS,
} from "@/lib/service-details";

const TRAIL = [{ name: "How it works", path: "/how-it-works" }];

/** The step photos sit in one half of a 1200px column. */
const STEP_SIZES = "(min-width: 1280px) 568px, (min-width: 768px) 46vw, 100vw";

export const metadata: Metadata = pageMeta({
  title: "How Door-to-Door Storage Works in Cape Town",
  description:
    "Book online, we collect from your door, store it in a monitored Cape Town facility and deliver it back on request. Every box photographed and scanned.",
  path: "/how-it-works",
});

/**
 * The service in four steps, written from the journey the product actually
 * runs (`docs/journey/JOURNEY.md`). Each step is paired with a picture of the
 * thing it describes: the booking screen, loading at the kerb, the racking,
 * the order on its way back.
 */
const STEPS = [
  {
    title: "Get a quote and book",
    body: "Build your quote online: boxes, loose items and the vehicle to fetch them. Then pick a date and a morning, afternoon or evening window. We confirm the booking, and you can print your labels and start packing.",
    notes: ["Empty boxes are included", "Packing supplies and a helper are optional"],
    art: <BookingScreen />,
  },
  {
    title: "We collect from your door",
    body: "You get a message when your driver is on the way, with their name and ID. At your door every box is scanned and photographed. You check the list on the driver's device and sign for it.",
    notes: ["We do the carrying", "Nothing leaves unscanned"],
    art: <PhotoFeature id="collect" sizes={STEP_SIZES} />,
  },
  {
    title: "Stored in its own bay",
    body: "At the facility each box is scanned in and given a shelf position. Your account then shows it as in storage, with its photographs, its code and its monthly rate.",
    notes: ["Monitored and access-controlled", "Climate and humidity managed"],
    art: <PhotoFeature id="racking" sizes={STEP_SIZES} />,
  },
  {
    title: "Ask for it back, any time",
    body: "Choose what you want in your account, the whole load or a single box, and pick a date and window. Each item is scanned out, scanned again at your door, and you sign for it.",
    notes: ["Next business day as standard", "Deliver to a different address if you have moved"],
    art: <OrderScreen />,
  },
];

export default function HowItWorksPage() {
  return (
    <>
      <JsonLd data={[breadcrumbJsonLd(TRAIL), faqJsonLd()]} />

      {/* Hero: the claim, and the whole process in four lines beside it. */}
      <PhotoHero
        photo="hero-how"
        trail={TRAIL}
        title="How door-to-door storage works"
        lead="No warehouse to drive to and no truck to hire. You book online, we fetch your things from your door, keep them safe in Cape Town, and bring them back when you ask."
        aside={
          <ol data-reveal className="rounded-2xl bg-surface-white p-2 text-navy-deep shadow-tactile-md">
            {STEPS.map(({ title }, i) => (
              <li key={title}>
                <a
                  href={`#step-${i + 1}`}
                  className="group flex min-h-[56px] items-center gap-4 rounded-xl px-4 py-2 hover:bg-mist"
                >
                  <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-navy-deep text-sm font-bold text-surface-white">
                    {i + 1}
                  </span>
                  <span className="flex-1 font-semibold">{title}</span>
                  <span aria-hidden="true" className="material-symbols-outlined text-accent-deep transition-transform group-hover:translate-y-0.5">
                    arrow_downward
                  </span>
                </a>
              </li>
            ))}
          </ol>
        }
      >
        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Button href="/pricing#calculator" arrow>
            Get a quote
          </Button>
          <Button href="/pricing" variant="on-dark">
            See prices
          </Button>
        </div>
      </PhotoHero>

      {/* The four steps, text and picture alternating sides. */}
      <Section>
        <div className="space-y-16 md:space-y-28">
          {STEPS.map(({ title, body, notes, art }, i) => (
            <div
              key={title}
              id={`step-${i + 1}`}
              className="grid scroll-mt-28 items-center gap-8 md:grid-cols-2 md:gap-16"
            >
              <div data-reveal className={i % 2 ? "md:order-2" : ""}>
                <p className="text-sm font-semibold text-accent-deep">Step {i + 1} of {STEPS.length}</p>
                <h2 className="mt-2 text-headline-h1 font-bold text-navy-deep">{title}</h2>
                <p className="mt-4 text-body-lead text-on-surface-variant">{body}</p>
                <ul className="mt-6 space-y-2.5">
                  {notes.map((note) => (
                    <li key={note} className="flex items-start gap-3 text-[15px] text-navy-deep">
                      <span aria-hidden="true" className="material-symbols-outlined mt-0.5 shrink-0 text-lg text-accent-deep">
                        check
                      </span>
                      {note}
                    </li>
                  ))}
                </ul>
              </div>
              <div className={i % 2 ? "md:order-1" : ""}>{art}</div>
            </div>
          ))}
        </div>
      </Section>

      {/* ── On collection day ── */}
      {/*
        The four steps are the shape of the service; this is the detail
        someone needs before they will actually book: who has to be home,
        what the team will and will not do, how long it takes.
      */}
      <Section tone="mist">
        <div className="grid gap-10 lg:grid-cols-[minmax(0,4fr)_minmax(0,8fr)] lg:gap-16">
          <div data-reveal className="lg:sticky lg:top-36 lg:self-start">
            <h2 className="text-headline-h1 font-bold text-navy-deep">
              What actually happens on collection day
            </h2>
            <p className="mt-4 text-body-lead text-on-surface-variant">
              No surprises at the door. This is the whole procedure, including the bits
              our team will not do.
            </p>
          </div>
          <ol className="relative">
            {COLLECTION_DAY.map(({ icon, title, body }, i) => (
              <li
                key={title}
                data-reveal
                className="relative flex gap-5 pb-8 last:pb-0"
              >
                {i < COLLECTION_DAY.length - 1 && (
                  <span aria-hidden="true" className="absolute left-6 top-14 h-[calc(100%-3.5rem)] w-px bg-outline-variant" />
                )}
                <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border border-outline-variant bg-surface-white">
                  <span aria-hidden="true" className="material-symbols-outlined text-2xl text-accent-deep">
                    {icon}
                  </span>
                </span>
                <div className="pt-0.5">
                  <h3 className="text-headline-h3 font-semibold text-navy-deep">{title}</h3>
                  <p className="mt-1.5 text-body-main text-on-surface-variant">{body}</p>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </Section>

      {/* ── How your things are tracked ── */}
      <Section tone="navy">
        <SectionHeading
          dark
          title="How you know we have not lost it"
          lead="Handing your belongings to a stranger is the hard part of this service. The answer is not a promise. It is a record written as things happen, which cannot be quietly rewritten afterwards."
        />
        <div className="grid items-start gap-12 lg:grid-cols-2 lg:gap-16">
          {/* The label is the mechanism; showing it beats describing it. */}
          <CustodyTrail dark />
          <div className="space-y-7">
            {TRACKING_POINTS.map(({ icon, title, body }) => (
              <IconPoint key={title} icon={icon} title={title} dark>
                {body}
              </IconPoint>
            ))}
            <Link
              href="/about"
              className="inline-flex items-center gap-1.5 font-semibold text-sky hover:underline"
            >
              See inside the facility
              <span aria-hidden="true" className="material-symbols-outlined text-lg">arrow_forward</span>
            </Link>
          </div>
        </div>
      </Section>

      {/* ── Getting it back ── */}
      <Section>
        <div className="grid items-center gap-12 lg:grid-cols-[minmax(0,5fr)_minmax(0,7fr)] lg:gap-16">
          <div className="order-2 lg:order-1">
            <StorageScreen />
          </div>
          <div className="order-1 lg:order-2">
            <SectionHeading
              title="Getting your things back out"
              lead="Storing is the easy half. This is the half you will use over and over."
              className="!mb-8"
            />
            <dl className="grid gap-x-10 sm:grid-cols-2">
              {RETRIEVAL_POINTS.map(({ title, body }) => (
                <div key={title} data-reveal className="border-t border-outline-variant py-5">
                  <dt className="font-semibold text-navy-deep">{title}</dt>
                  <dd className="mt-1.5 text-[15px] leading-relaxed text-on-surface-variant">{body}</dd>
                </div>
              ))}
            </dl>
          </div>
        </div>
      </Section>

      {/* ── What we will and will not take ── */}
      <Section tone="mist">
        <SectionHeading
          title="What we can and cannot store"
          lead="Worth two minutes now rather than a turned-away collection later. If a prohibited item turns up on the day we will arrange its return, and we may charge for the trip."
        />
        <div className="grid gap-gutter md:grid-cols-2">
          <div data-reveal className="rounded-2xl border border-outline-variant bg-surface-white p-6 sm:p-8">
            <h3 className="flex items-center gap-3 text-headline-h3 font-semibold text-navy-deep">
              <span aria-hidden="true" className="material-symbols-outlined text-2xl text-emerald-600">check_circle</span>
              Happily stored
            </h3>
            <ul className="mt-5 grid gap-x-6 gap-y-3 sm:grid-cols-2">
              {ACCEPTED_ITEMS.map((item) => (
                <li key={item} className="flex items-start gap-2.5 text-[15px] text-on-surface-variant">
                  <span aria-hidden="true" className="material-symbols-outlined mt-0.5 shrink-0 text-lg text-emerald-600">check</span>
                  {item}
                </li>
              ))}
            </ul>
          </div>

          <div data-reveal style={{ ["--i" as string]: 1 }} className="rounded-2xl border border-outline-variant bg-surface-white p-6 sm:p-8">
            <h3 className="flex items-center gap-3 text-headline-h3 font-semibold text-navy-deep">
              <span aria-hidden="true" className="material-symbols-outlined text-2xl text-error">do_not_disturb_on</span>
              We cannot take
            </h3>
            <ul className="mt-5 space-y-3">
              {PROHIBITED_ITEMS.map((item) => (
                <li key={item} className="flex items-start gap-2.5 text-[15px] text-on-surface-variant">
                  <span aria-hidden="true" className="material-symbols-outlined mt-0.5 shrink-0 text-lg text-error">close</span>
                  {item}
                </li>
              ))}
            </ul>
            <p className="mt-6 border-t border-outline-variant pt-5 text-sm text-on-surface-variant">
              {AT_OWN_RISK}
            </p>
          </div>
        </div>
      </Section>

      {/* ── Billing in plain terms ── */}
      <Section>
        <div className="grid gap-10 lg:grid-cols-[minmax(0,4fr)_minmax(0,8fr)] lg:gap-16">
          <div data-reveal>
            <h2 className="text-headline-h1 font-bold text-navy-deep">Billing, in plain terms</h2>
            <p className="mt-4 text-body-lead text-on-surface-variant">
              One invoice a month for what you have with us.
            </p>
            <Button href="/pricing#calculator" arrow className="mt-8">
              Get a quote
            </Button>
          </div>
          <dl className="grid gap-x-10 sm:grid-cols-2">
            {BILLING_POINTS.map(({ title, body }) => (
              <div key={title} data-reveal className="border-t border-outline-variant py-5">
                <dt className="font-semibold text-navy-deep">{title}</dt>
                <dd className="mt-1.5 text-[15px] leading-relaxed text-on-surface-variant">{body}</dd>
              </div>
            ))}
          </dl>
        </div>
      </Section>

      <FAQAccordion tone="mist" />

      <ClosingCta
        tone="white"
        title="See what your load would cost"
        body="Add your boxes and furniture to the calculator and get a monthly figure, plus the once-off collection fee."
      />
    </>
  );
}
