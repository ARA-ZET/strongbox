import type { Metadata } from "next";
import Link from "next/link";
import SectionDivider from "@/components/graphics/SectionDivider";
import SitePhoto from "@/components/SitePhoto";
import FacilityProof from "@/components/FacilityProof";
import { TRUST_STATS } from "@/lib/constants";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "About StrongBox — Cape Town's Most Trusted Storage Partner",
  description:
    "StrongBox was born in Cape Town to modernise valet storage. Security-first, fully transparent, and domestically focused — we do the driving so you keep your space.",
  path: "/about",
});

const values = [
  {
    icon: "shield",
    title: "Security First",
    body: "Every item is barcoded, tracked, and stored in our climate-controlled, 24/7 monitored facility. Your peace of mind is our foundation.",
  },
  {
    icon: "hail",
    title: "Total Convenience",
    body: "We manage the logistics from your doorstep to our vault. No heavy lifting, no traffic, no warehouse trips required.",
  },
  {
    icon: "visibility",
    title: "Full Transparency",
    body: "Manage your storage via your digital dashboard. See photos of every box and request returns with a single click.",
  },
];

export default function AboutPage() {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "About", path: "/about" }])} />
      {/* Hero */}
      <section className="py-28 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h1 className="text-display-bold font-bold text-surface-white mb-6">
            Cape Town&apos;s Most Trusted Storage Partner
          </h1>
          <p className="text-on-navy-variant text-body-main max-w-2xl mx-auto">
            Reclaiming your living space with Cape Town&apos;s premier concierge valet storage solution. Sophisticated, secure, and seamlessly handled.
          </p>
        </div>
      </section>

      <SectionDivider from="navyDeep" to="mist" variant="wave" />

      {/* Our Story */}
      <section className="py-24 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            <div>
              <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
                Born in the Mother City
              </span>
              <h2 className="text-headline-h1 font-bold text-navy-deep mb-6">Our Story</h2>
              <p className="text-on-surface-variant text-body-main mb-5">
                StrongBox began with a simple observation: urban living in Cape Town is spectacular, but space is a finite luxury. We realised that traditional self-storage was an industrial, inconvenient chore that didn&apos;t fit the modern Capetonian lifestyle.
              </p>
              <p className="text-on-surface-variant text-body-main mb-5">
                We envisioned a service that acts as an &ldquo;Extended Closet&rdquo; — a natural, premium extension of your home where your belongings are cared for with the same meticulous attention you&apos;d give them yourself. Since our founding, we&apos;ve focused on combining high-end concierge service with military-grade security.
              </p>
              <blockquote className="border-l-4 border-accent-deep pl-5 py-2">
                <p className="text-accent-deep font-body-strong italic text-lg">
                  &ldquo;We do the driving. You keep your space.&rdquo;
                </p>
              </blockquote>
            </div>
            <SitePhoto id="team-portrait" className="shadow-tactile" />
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {TRUST_STATS.map(({ value, label }) => (
              <div key={label} className="bg-mist rounded-xl p-8 text-center shadow-tactile">
                <p className="text-display-bold font-bold text-navy-deep mb-2">{value}</p>
                <p className="text-label-caps text-accent-deep uppercase tracking-widest font-bold text-xs">
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <FacilityProof tone="mist" />

      {/* Values */}
      <section className="py-24 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="text-center mb-14">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-3 block">
              What We Stand For
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep">Our Core Values</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter">
            {values.map(({ icon, title, body }) => (
              <div key={title} className="bg-mist rounded-xl p-8 shadow-tactile card-hover text-center">
                <div className="w-16 h-16 rounded-full bg-accent/10 flex items-center justify-center mx-auto mb-5">
                  <span className="material-symbols-outlined text-accent-deep text-3xl">{icon}</span>
                </div>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-3">{title}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <SectionDivider from="white" to="navyDeep" variant="wave" />

      {/* CTA */}
      <section className="py-20 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h1 font-bold text-surface-white mb-4">
            Let us take it from here
          </h2>
          <p className="text-on-navy-variant mb-10 max-w-xl mx-auto">
            Tell us what needs storing and we&apos;ll price it in about a minute — no
            account required to see the number.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/pricing#calculator"
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:opacity-90 transition-all inline-flex items-center justify-center gap-2"
            >
              Get a Free Quote
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
            <Link
              href="/contact"
              className="border-2 border-surface-white/30 text-surface-white px-10 py-4 rounded-xl font-body-strong hover:bg-surface-white/10 transition-all"
            >
              Talk to Our Team
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
