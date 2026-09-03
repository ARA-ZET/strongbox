import type { Metadata } from "next";
import Link from "next/link";
import Illustration from "@/components/graphics/Illustration";
import { ARTICLES, formatUpdated } from "@/lib/resources";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "Storage & Moving Guides",
  description:
    "Practical guides for moving, decluttering and storing in Cape Town — moving-out checklists, small-space decluttering, what self-storage really costs, and how to pack a box that lasts.",
  path: "/resources",
});

export default function ResourcesPage() {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Guides", path: "/resources" }])} />
      {/* Hero */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
          <div>
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Guides
            </span>
            <h1 className="text-display-bold font-bold text-navy-deep mb-4">
              Moving, decluttering and storing — written for Cape Town
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              What we have learned collecting and returning other people&apos;s
              belongings, written down. No email wall, no lead magnet.
            </p>
          </div>
          <Illustration name="questions" priority className="max-w-[340px] mx-auto" />
        </div>
      </section>

      {/* Index */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-gutter">
            {ARTICLES.map((article) => (
              <Link
                key={article.slug}
                href={`/resources/${article.slug}`}
                className="group bg-surface-white border border-outline-variant rounded-xl overflow-hidden shadow-tactile card-hover flex flex-col"
              >
                <div className="bg-mist p-8 flex items-center justify-center min-h-[12rem]">
                  <Illustration name={article.illustration} className="max-w-[220px]" />
                </div>
                <div className="p-8 flex flex-col flex-1">
                  <div className="flex flex-wrap items-center gap-3 mb-3">
                    <span className="bg-sky-tint text-accent-deep text-xs font-bold px-3 py-1 rounded-full">
                      {article.category}
                    </span>
                    <span className="text-xs text-on-surface-variant">
                      {article.readMinutes} min read · Updated {formatUpdated(article.updated)}
                    </span>
                  </div>
                  <h2 className="text-headline-h3 font-bold text-navy-deep mb-3">
                    {article.title}
                  </h2>
                  <p className="text-on-surface-variant text-body-main mb-6 flex-1">
                    {article.excerpt}
                  </p>
                  <span className="text-accent-deep font-body-strong inline-flex items-center gap-1">
                    Read the guide
                    <span className="material-symbols-outlined text-sm transition-transform group-hover:translate-x-1">
                      arrow_forward
                    </span>
                  </span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Tools cross-link */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="bg-surface-white rounded-xl border border-outline-variant p-10 md:p-14 flex flex-col md:flex-row items-center justify-between gap-8 shadow-tactile">
            <div>
              <h2 className="text-headline-h2 font-bold text-navy-deep mb-3">
                Past the reading, into the numbers
              </h2>
              <p className="text-on-surface-variant max-w-xl">
                Our calculators use the same rate card we quote from, so what you work
                out here is what you would be charged.
              </p>
            </div>
            <Link
              href="/tools"
              className="bg-accent text-on-accent px-8 py-4 rounded-xl font-body-strong hover:bg-accent-deep transition-colors shrink-0 inline-flex items-center gap-2"
            >
              Open the free tools
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
