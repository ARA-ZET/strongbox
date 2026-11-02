import type { Metadata } from "next";
import Link from "next/link";
import SuburbChecker from "@/components/SuburbChecker";
import JsonLd from "@/components/JsonLd";
import { REGIONS } from "@/lib/areas";
import { HQ_SUBURB, SERVICE_AREAS, WHATSAPP_HREF } from "@/lib/constants";
import { getPrices } from "@/lib/prices";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";

export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    title: "Areas We Serve — Storage Collection Across Cape Town",
    description: `Door-to-door storage collection across Cape Town, from Bloubergstrand to Gordon's Bay and Sea Point to Khayelitsha. Check your suburb. From R${boxFrom}/box a month.`,
    path: "/areas",
  });
}

export default async function AreasPage() {
  const { boxFrom } = await getPrices();

  const facts = [
    { icon: "warehouse", title: `One facility, in ${HQ_SUBURB}`, body: "Monitored and climate-controlled. You never need to visit it." },
    { icon: "payments", title: "Same prices across the city", body: `From R${boxFrom} a box per month. The collection fee depends on the vehicle you need, not your suburb.` },
    { icon: "schedule", title: "Windows that suit you", body: "Morning, afternoon or evening collection, and returns the next business day." },
  ];

  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Areas We Serve", path: "/areas" }])} />

      {/* Hero — the checker is the page's primary action, so it sits in the first screen. */}
      <section className="py-14 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-10 items-center">
          <div>
            <span className="font-label-caps text-accent-deep tracking-widest uppercase text-xs mb-3 block">
              Areas We Serve
            </span>
            <h1 className="text-headline-h1 font-bold text-navy-deep mb-4">
              Storage collection across Cape Town
            </h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              We collect from {Math.floor(SERVICE_AREAS.length / 10) * 10}+ suburbs, from Atlantis to Gordon&apos;s
              Bay and from Sea Point to Khayelitsha. Everything is stored in one facility and
              comes back to your door when you ask for it.
            </p>
          </div>
          <div className="bg-surface-white rounded-xl shadow-tactile border border-outline-variant p-6 md:p-8">
            <SuburbChecker />
          </div>
        </div>
      </section>

      {/* Facts that hold everywhere — stated once here, not repeated per region. */}
      <section className="py-14 bg-surface-white">
        <ul className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid grid-cols-1 md:grid-cols-3 gap-gutter">
          {facts.map(({ icon, title, body }) => (
            <li key={title} className="flex items-start gap-4">
              <div className="w-11 h-11 rounded-lg bg-sky-tint flex items-center justify-center shrink-0">
                <span aria-hidden="true" className="material-symbols-outlined text-accent-deep">
                  {icon}
                </span>
              </div>
              <div>
                <h2 className="font-body-strong text-navy-deep mb-1">{title}</h2>
                <p className="text-sm text-on-surface-variant">{body}</p>
              </div>
            </li>
          ))}
        </ul>
      </section>

      {/* Regions */}
      <section className="py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h2 font-bold text-navy-deep mb-3">
            Find your part of the city
          </h2>
          <p className="text-on-surface-variant text-body-main max-w-2xl mb-10">
            Each area has its own kinds of homes and its own reasons for needing space.
            Choose yours to see how collection works there.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-gutter">
            {REGIONS.map((region) => (
              <Link
                key={region.slug}
                href={`/areas/${region.slug}`}
                className="group bg-surface-white rounded-xl border border-outline-variant shadow-tactile p-7 flex flex-col card-hover"
              >
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-2 group-hover:text-accent-deep transition-colors">
                  {region.name}
                </h3>
                <p className="text-sm text-on-surface-variant mb-4">{region.summary}</p>
                <p className="text-xs text-on-surface-variant/80 mb-5 leading-relaxed">
                  {region.suburbs.join(" · ")}
                </p>
                <span className="mt-auto text-sm text-accent-deep font-body-strong inline-flex items-center gap-1">
                  Storage {region.where}
                  <span aria-hidden="true" className="material-symbols-outlined text-sm">
                    arrow_forward
                  </span>
                </span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Close */}
      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <h2 className="text-headline-h3 font-bold text-navy-deep mb-1">
              Suburb not listed?
            </h2>
            <p className="text-on-surface-variant">
              The list shows where we go most often, not where we stop. Send us a message.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-3 shrink-0">
            <a
              href={WHATSAPP_HREF}
              target="_blank"
              rel="noopener noreferrer"
              className="border-2 border-navy-deep text-navy-deep h-[52px] px-6 rounded-xl font-body-strong flex items-center justify-center gap-2 hover:bg-navy-deep hover:text-surface-white transition-colors"
            >
              WhatsApp us
            </a>
            <Link
              href="/pricing"
              className="bg-accent text-on-accent h-[52px] px-6 rounded-xl font-body-strong flex items-center justify-center gap-2 hover:bg-accent-deep transition-colors"
            >
              Get a free quote
              <span aria-hidden="true" className="material-symbols-outlined">arrow_forward</span>
            </Link>
          </div>
        </div>
      </section>
    </>
  );
}
