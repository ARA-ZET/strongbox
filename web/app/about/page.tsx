import type { Metadata } from "next";
import FacilityProof from "@/components/FacilityProof";
import ClosingCta from "@/components/ClosingCta";
import JsonLd from "@/components/JsonLd";
import PhotoHero from "@/components/PhotoHero";
import Section from "@/components/ui/Section";
import SectionHeading from "@/components/ui/SectionHeading";
import IconPoint from "@/components/ui/IconPoint";
import CoverageMap from "@/components/visuals/CoverageMap";
import { REGIONS } from "@/lib/areas";
import {
  HQ_SUBURB,
  OPENING_HOURS_LINES,
  SERVICE_AREAS,
} from "@/lib/constants";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";

const TRAIL = [{ name: "About", path: "/about" }];

export const metadata: Metadata = pageMeta({
  title: "About StrongBox, Cape Town Door-to-Door Storage",
  description:
    "StrongBox is a Cape Town storage service that comes to you: one monitored facility in Kensington, collections across the metro, every box tracked.",
  path: "/about",
});

const VALUES = [
  {
    icon: "shield",
    title: "Know where everything is",
    body: "Every box is labelled, scanned and given a shelf position. If we cannot tell you where something is, we have failed at the one thing we are for.",
  },
  {
    icon: "hail",
    title: "You should not have to drive",
    body: "Collection and return happen at your door. No van hire, no warehouse visit, no afternoon lost to it.",
  },
  {
    icon: "visibility",
    title: "Say what it costs, and what it does not cover",
    body: "Prices are published and the same in every suburb. Insurance is not included, and we say so before you book.",
  },
];

export default function AboutPage() {
  /*
   * Facts, not figures. This band used to show customer counts and a star
   * rating that predated the service opening. What is here instead is true
   * today and stays true: where we are, how far we go, when we answer.
   */
  const facts = [
    { value: "1", label: `Facility, in ${HQ_SUBURB}` },
    { value: String(REGIONS.length), label: "Regions of the metro covered" },
    { value: `${Math.floor(SERVICE_AREAS.length / 10) * 10}+`, label: "Suburbs we collect from" },
    { value: "0", label: "Months of minimum term" },
  ];

  return (
    <>
      <JsonLd data={breadcrumbJsonLd(TRAIL)} />

      {/* Hero */}
      <PhotoHero
        photo="hero-about"
        trail={TRAIL}
        title="Storage built for how Cape Town lives"
        lead="Flats on the Seaboard, student accommodation near campus, family homes on the Flats and new estates up the West Coast. Every home runs out of space eventually, so we collect what you are not using and bring it back when you need it."
      />

      {/* Why we exist */}
      <Section>
        <div className="grid items-start gap-12 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:gap-16">
          <div data-reveal>
            <h2 className="text-headline-h1 font-bold text-navy-deep">Why we started</h2>
            <div className="mt-5 space-y-5 text-body-lead text-on-surface-variant">
              <p>
                Self-storage asks a lot of you. You rent a unit bigger than you need, hire
                a bakkie, carry everything in yourself, and then drive back every time
                you want one thing out of it.
              </p>
              <p>
                We thought the storage should do the travelling instead. You pay for the
                boxes and items you actually store, we fetch them from your door, and
                your account shows a photograph and a location for every one of them.
              </p>
            </div>
            <blockquote className="mt-8 border-l-4 border-accent pl-5">
              <p className="text-headline-h3 font-semibold text-navy-deep">
                We do the driving. You keep your space.
              </p>
            </blockquote>

            <dl className="mt-12 grid grid-cols-2 gap-x-8 gap-y-8 border-t border-outline-variant pt-8">
              {facts.map(({ value, label }) => (
                <div key={label} className="flex flex-col-reverse">
                  <dt className="mt-1 text-sm text-on-surface-variant">{label}</dt>
                  <dd className="text-display-bold font-bold text-navy-deep">{value}</dd>
                </div>
              ))}
            </dl>
            <p className="mt-8 text-sm text-on-surface-variant">
              Office hours: {OPENING_HOURS_LINES.join(", ")}.
            </p>
          </div>
          <CoverageMap />
        </div>
      </Section>

      <FacilityProof tone="mist" />

      {/* What we hold ourselves to */}
      <Section>
        <SectionHeading title="What we hold ourselves to" />
        <div className="grid gap-10 md:grid-cols-3">
          {VALUES.map(({ icon, title, body }, i) => (
            <div key={title} data-reveal style={{ ["--i" as string]: i }}>
              <IconPoint icon={icon} title={title}>
                {body}
              </IconPoint>
            </div>
          ))}
        </div>
      </Section>

      <ClosingCta
        title="Let us take it from here"
        body="Tell us what needs storing and we will price it in about a minute. No account needed to see the number."
        secondary={{ href: "/contact", label: "Talk to us" }}
      />
    </>
  );
}
