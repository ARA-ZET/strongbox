import type { Metadata } from "next";
import Link from "next/link";
import FAQAccordion from "@/components/FAQAccordion";
import SectionDivider from "@/components/graphics/SectionDivider";
import SitePhoto from "@/components/SitePhoto";
import { type PhotoId } from "@/lib/photos";
import { APP_URL } from "@/lib/constants";
import JsonLd from "@/components/JsonLd";
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

/**
 * One photograph per timeline step. These carry the whole page — the copy for
 * each step is three lines — so the four together are effectively the visual
 * argument for the service: you book it, we arrive, it is racked somewhere
 * real, you sign for it coming back.
 */
const STEP_ART: Record<number, PhotoId> = {
  1: "app-booking",
  2: "van-doorstep",
  3: "facility-aisle",
  4: "handover-signature",
};

export const metadata: Metadata = pageMeta({
  title: "How Valet Storage Works",
  description:
    "StrongBox collects your belongings from your home, stores them in our secure Kensington facility, and delivers them back on demand anywhere in Cape Town. No lifting, no driving, no stress.",
  path: "/how-it-works",
});

const steps = [
  {
    num: 1,
    title: "Get Your Quote",
    body: "Choose your plan based on how much space you need. Our transparent pricing means no hidden fees or surprise costs.",
    extra: (
      <div className="mt-6 flex gap-3">
        {["Small Bin", "Full Closet"].map((label) => (
          <div key={label} className="bg-mist rounded-xl px-4 py-3 text-sm font-body-strong text-navy-deep flex items-center gap-2">
            <span className="material-symbols-outlined text-accent-deep">package_2</span>
            {label}
          </div>
        ))}
      </div>
    ),
    side: "right",
  },
  {
    num: 2,
    title: "We Collect",
    body: "Our professional specialists arrive at your doorstep, help you load your items, and document everything for your digital inventory.",
    extra: null,
    side: "left",
  },
  {
    num: 3,
    title: "Stored Securely",
    body: "Your items are kept in our high-end, temperature-controlled facility. Each unit is monitored 24/7 with domestic-grade security.",
    extra: null,
    side: "right",
  },
  {
    num: 4,
    title: "Request Back Anytime",
    body: "Need your items back? Just tap 'Request Delivery' in our app. We'll bring your boxes back as soon as tomorrow morning.",
    extra: (
      <div className="mt-6 bg-mist rounded-xl p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="material-symbols-outlined text-navy-deep">local_shipping</span>
          <span className="font-body-strong text-navy-deep text-sm">Delivery Tomorrow</span>
        </div>
        <span className="bg-emerald-500 text-white text-xs font-bold px-3 py-1 rounded-full">
          Confirmed
        </span>
      </div>
    ),
    side: "left",
  },
];

export default function HowItWorksPage() {
  return (
    <>
      <JsonLd
        data={[
          breadcrumbJsonLd([{ name: "How It Works", path: "/how-it-works" }]),
          faqJsonLd(),
        ]}
      />
      {/* Hero */}
      {/*
        Two columns rather than the centred block this was: every other
        content hero on the site (pricing, compare, loose items, tools,
        guides) is text-left / image-right, and a lone centred one read as a
        different page template. The CTAs left-align with the copy for the
        same reason.
      */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="inline-block bg-accent/20 text-accent-deep text-label-caps font-bold uppercase tracking-widest px-4 py-2 rounded-full mb-6 text-xs">
              Concierge Experience
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-6">
              How Valet Storage Works
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl mb-10">
              Say goodbye to industrial warehouses and weekend truck rentals. We bring your storage unit to your door, professionalise the packing, and return your items whenever you need them.
            </p>
            <div className="flex flex-col sm:flex-row gap-4">
              <a
                href={`${APP_URL}/register`}
                className="bg-accent text-on-accent h-[56px] px-8 rounded-xl font-body-strong flex items-center justify-center gap-2 hover:bg-accent-deep transition-colors"
              >
                Get Started Free
                <span className="material-symbols-outlined">arrow_forward</span>
              </a>
              <Link
                href="/pricing"
                className="border-2 border-navy-deep text-navy-deep h-[56px] px-8 rounded-xl font-body-strong flex items-center justify-center hover:bg-surface-white transition-colors"
              >
                View Pricing
              </Link>
            </div>
          </div>

          <SitePhoto id="how-it-works-hero" className="shadow-tactile" />
        </div>
      </section>

      {/* Timeline */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="relative">
            {/* Vertical line */}
            <div className="hidden md:block absolute left-1/2 top-0 bottom-0 w-0.5 bg-accent-deep/30 -translate-x-1/2" />

            <div className="space-y-24">
              {steps.map((step, idx) => {
                const isRight = idx % 2 === 0;
                return (
                  <div key={step.num} className="relative grid md:grid-cols-2 gap-12 items-center">
                    {/* Number badge (desktop centre) */}
                    <div className="hidden md:flex absolute left-1/2 -translate-x-1/2 w-12 h-12 rounded-full bg-accent text-on-accent font-bold text-lg items-center justify-center shadow-tactile-md z-10">
                      {step.num}
                    </div>

                    {/* Mobile number */}
                    <div className="md:hidden flex items-center gap-3 mb-2">
                      <div className="w-10 h-10 rounded-full bg-accent text-on-accent font-bold flex items-center justify-center">
                        {step.num}
                      </div>
                      <span className="text-label-caps text-accent-deep uppercase tracking-widest font-bold text-xs">
                        Step {step.num}
                      </span>
                    </div>

                    {/* Content — alternating sides */}
                    <div className={isRight ? "md:order-1" : "md:order-2"}>
                      <p className="text-label-caps text-accent-deep uppercase tracking-widest font-bold text-xs mb-3">
                        {step.num}. {step.title}
                      </p>
                      <h2 className="text-headline-h2 font-bold text-navy-deep mb-4">{step.title}</h2>
                      <p className="text-on-surface-variant text-body-main">{step.body}</p>
                      {step.extra}
                    </div>

                    {/* Visual side */}
                    <div className={isRight ? "md:order-2" : "md:order-1"}>
                      <SitePhoto id={STEP_ART[step.num]} className="shadow-tactile" />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </section>

      {/* ── On collection day ── */}
      {/*
        The four-step timeline above is the shape of the service; this is the
        detail someone needs before they will actually book — who has to be
        home, what the team will and will not do, how long it takes.
      */}
      <section className="py-24 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              The Detail
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              What actually happens on collection day
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              No surprises at the door. This is the whole procedure, including the
              bits our team will not do.
            </p>
          </div>
          {/*
            Image beside the text rather than a card grid: the six points are
            a sequence a reader works down, and a picture of the thing being
            described holds them there while they do it. The photo sticks so
            it stays in view for the whole list on a tall screen.
          */}
          <div className="grid lg:grid-cols-[minmax(0,440px)_minmax(0,1fr)] gap-12 items-start">
            <div className="lg:sticky lg:top-28">
              <SitePhoto id="collection-day" className="shadow-tactile" />
            </div>

            <ol className="space-y-8">
              {COLLECTION_DAY.map(({ icon, title, body }, i) => (
                <li key={title} className="flex items-start gap-5">
                  <div className="relative shrink-0">
                    <div className="w-12 h-12 rounded-lg bg-surface-white border border-outline-variant flex items-center justify-center shadow-tactile">
                      <span className="material-symbols-outlined text-accent-deep text-2xl">
                        {icon}
                      </span>
                    </div>
                    <span className="absolute -top-2 -left-2 w-6 h-6 rounded-full bg-accent text-on-accent text-xs font-bold flex items-center justify-center">
                      {i + 1}
                    </span>
                  </div>
                  <div>
                    <h3 className="text-headline-h3 font-bold text-navy-deep mb-1.5">{title}</h3>
                    <p className="text-on-surface-variant text-body-main">{body}</p>
                  </div>
                </li>
              ))}
            </ol>
          </div>
        </div>
      </section>

      {/* ── How your things are tracked ── */}
      <section className="py-24 bg-navy-deep text-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            {/* The label is the mechanism; showing it beats describing it. */}
            <SitePhoto id="custody-label" tone="dark" className="md:order-1" />

            <div className="md:order-2">
              <span className="font-label-caps text-sky uppercase tracking-widest text-xs mb-4 block">
                Chain Of Custody
              </span>
              <h2 className="text-headline-h1 font-bold mb-6">
                How you know we haven&apos;t lost it
              </h2>
              <p className="text-on-navy text-body-main mb-8">
                Handing your belongings to a stranger is the hard part of this service.
                The answer is not a promise — it is a record that is written as things
                happen and cannot be quietly rewritten afterwards.
              </p>
              <div className="space-y-6 mb-8">
                {TRACKING_POINTS.map(({ icon, title, body }) => (
                  <div key={title} className="flex items-start gap-4">
                    <div className="bg-surface-white/10 p-2.5 rounded-lg shrink-0">
                      <span className="material-symbols-outlined text-sky">{icon}</span>
                    </div>
                    <div>
                      <h3 className="font-body-strong mb-1">{title}</h3>
                      <p className="text-on-navy-variant text-sm">{body}</p>
                    </div>
                  </div>
                ))}
              </div>

              <Link
                href="/about"
                className="text-sky font-body-strong hover:underline inline-flex items-center gap-1"
              >
                See inside the facility
                <span className="material-symbols-outlined text-sm">arrow_forward</span>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* ── Getting it back ── */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              Coming Back
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              Getting your things back out
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              Storing is the easy half. This is the half you will use over and over.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-gutter">
            {RETRIEVAL_POINTS.map(({ icon, title, body }) => (
              <div key={title} className="bg-mist rounded-xl p-8 border border-outline-variant">
                <div className="w-11 h-11 rounded-lg bg-surface-white flex items-center justify-center mb-5 shadow-tactile">
                  <span className="material-symbols-outlined text-accent-deep text-2xl">{icon}</span>
                </div>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-2">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── What we will and will not take ── */}
      <section className="py-24 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              The Rules
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              What we can and cannot store
            </h2>
            <p className="text-on-surface-variant max-w-2xl mx-auto">
              Worth two minutes now rather than a turned-away collection later. If a
              prohibited item turns up on the day we will arrange its return, and we
              may charge for the trip.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-gutter">
            <div className="bg-surface-white rounded-xl p-8 md:p-10 border border-outline-variant shadow-tactile">
              <div className="flex items-center gap-3 mb-6">
                <span className="material-symbols-outlined text-emerald-600 text-3xl" aria-hidden="true">
                  check_circle
                </span>
                <h3 className="text-headline-h3 font-bold text-navy-deep">Happily stored</h3>
              </div>
              <ul className="grid sm:grid-cols-2 gap-x-6 gap-y-3">
                {ACCEPTED_ITEMS.map((item) => (
                  <li key={item} className="flex items-start gap-2.5 text-on-surface-variant text-body-main">
                    <span
                      aria-hidden="true"
                      className="material-symbols-outlined text-emerald-600 text-lg shrink-0"
                    >
                      check
                    </span>
                    {item}
                  </li>
                ))}
              </ul>
            </div>

            <div className="bg-surface-white rounded-xl p-8 md:p-10 border border-outline-variant shadow-tactile">
              <div className="flex items-center gap-3 mb-6">
                <span className="material-symbols-outlined text-error text-3xl" aria-hidden="true">
                  do_not_disturb_on
                </span>
                <h3 className="text-headline-h3 font-bold text-navy-deep">We cannot take</h3>
              </div>
              <ul className="space-y-3 mb-6">
                {PROHIBITED_ITEMS.map((item) => (
                  <li key={item} className="flex items-start gap-2.5 text-on-surface-variant text-body-main">
                    <span
                      aria-hidden="true"
                      className="material-symbols-outlined text-error text-lg shrink-0"
                    >
                      close
                    </span>
                    {item}
                  </li>
                ))}
              </ul>
              <p className="text-sm text-on-surface-variant pt-5 border-t border-outline-variant">
                {AT_OWN_RISK}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ── Billing in plain terms ── */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              The Money
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-3">
              Billing, in plain terms
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-gutter">
            {BILLING_POINTS.map(({ icon, title, body }) => (
              <div key={title} className="border-t-2 border-accent pt-6">
                <span className="material-symbols-outlined text-accent-deep text-3xl mb-3">
                  {icon}
                </span>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-2">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
          <div className="text-center mt-12">
            <Link
              href="/pricing#calculator"
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:bg-accent-deep transition-colors inline-flex items-center gap-2"
            >
              Work out what yours would cost
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <FAQAccordion />

      <SectionDivider from="mist" to="navyDeep" variant="angle" />

      {/* CTA */}
      <section className="py-20 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h1 font-bold text-surface-white mb-4">Start Storing Today</h2>
          <p className="text-on-navy-variant mb-10 max-w-xl mx-auto">
            Join Cape Town&apos;s most trusted valet storage service.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href={`${APP_URL}/register`}
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:opacity-90 transition-all inline-flex items-center gap-2"
            >
              Book Now
              <span className="material-symbols-outlined">arrow_forward</span>
            </a>
            <Link
              href="/pricing"
              className="border-2 border-surface-white/30 text-surface-white px-10 py-4 rounded-xl font-body-strong hover:bg-surface-white/10 transition-all"
            >
              View Pricing
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
