import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import SuburbChecker from "@/components/SuburbChecker";
import JsonLd from "@/components/JsonLd";
import { REGIONS, getRegion } from "@/lib/areas";
import { WHATSAPP_HREF } from "@/lib/constants";
import { getPrices } from "@/lib/prices";
import { pageMeta, breadcrumbJsonLd, regionServiceJsonLd } from "@/lib/seo";
import CoverageMap from "@/components/visuals/CoverageMap";
import PhotoHero from "@/components/PhotoHero";
import Button from "@/components/ui/Button";
import { REGION_PHOTO } from "@/lib/photos";

/** Next 15 hands route params in as a promise. */
type Params = { params: Promise<{ slug: string }> };

export function generateStaticParams() {
  return REGIONS.map(({ slug }) => ({ slug }));
}

export async function generateMetadata({ params }: Params): Promise<Metadata> {
  const { slug } = await params;
  const region = getRegion(slug);
  // A miss renders the 404, which must not be indexed under the requested URL.
  if (!region) return { title: "Area not found", robots: { index: false, follow: true } };

  const { boxFrom } = await getPrices();
  // Suburbs not already named in the region phrase, so Hout Bay is not said twice.
  const examples = region.suburbs.filter((s) => !region.where.includes(s)).slice(0, 3);
  return pageMeta({
    title: `${region.name} Storage, Cape Town`,
    description: `Door-to-door storage ${region.where}: ${examples.join(", ")} and more. We collect, store and return on request. From R${boxFrom} a box.`,
    path: `/areas/${region.slug}`,
  });
}

export default async function RegionPage({ params }: Params) {
  const { slug } = await params;
  const region = getRegion(slug);
  if (!region) notFound();

  const { boxFrom, pickupFrom } = await getPrices();
  const title = region.name;
  const others = REGIONS.filter((r) => r.slug !== region.slug);

  return (
    <>
      <JsonLd
        data={[
          regionServiceJsonLd(region, boxFrom),
          breadcrumbJsonLd([
            { name: "Areas We Serve", path: "/areas" },
            { name: title, path: `/areas/${region.slug}` },
          ]),
        ]}
      />

      {/* Hero */}
      <PhotoHero
        photo={REGION_PHOTO[region.slug] ?? "hero-areas"}
        trail={[
          { name: "Areas we serve", path: "/areas" },
          { name: title, path: `/areas/${region.slug}` },
        ]}
        title={<>Storage {region.where}, collected from your door</>}
        lead={
          <div className="space-y-4">
            {region.intro.map((p) => (
              <p key={p}>{p}</p>
            ))}
          </div>
        }
        aside={
          <aside className="rounded-2xl bg-surface-white p-7 text-on-surface shadow-tactile-md">
            <h2 className="font-body-strong text-navy-deep mb-4">
              Suburbs we collect from
            </h2>
            <ul className="flex flex-wrap gap-2 mb-6">
              {region.suburbs.map((s) => (
                <li
                  key={s}
                  className="bg-mist border border-outline-variant rounded-full px-3 py-1.5 text-sm text-navy-deep"
                >
                  {s}
                </li>
              ))}
            </ul>
            <dl className="grid grid-cols-2 gap-4 pt-5 border-t border-outline-variant">
              <div>
                <dt className="text-xs text-on-surface-variant uppercase tracking-wider mb-1">Storage</dt>
                <dd className="font-bold text-navy-deep">From R{boxFrom}<span className="text-sm font-normal text-on-surface-variant"> /box/mo</span></dd>
              </div>
              <div>
                <dt className="text-xs text-on-surface-variant uppercase tracking-wider mb-1">Collection</dt>
                <dd className="font-bold text-navy-deep">From R{pickupFrom}<span className="text-sm font-normal text-on-surface-variant"> once-off</span></dd>
              </div>
            </dl>
          </aside>
        }
      >
        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Button href="/pricing" arrow>
            Get a free quote
          </Button>
          <Button
            href={`${WHATSAPP_HREF}?text=${encodeURIComponent(`Hi StrongBox, I live ${region.where} and would like a quote.`)}`}
            variant="on-dark"
            external
          >
            WhatsApp us
          </Button>
        </div>
      </PhotoHero>

      {/* Why people here store */}
      <section className="py-14 md:py-20 bg-surface-white">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop">
          <h2 className="text-headline-h2 font-bold text-navy-deep mb-10">
            Why people {region.where} use StrongBox
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-gutter">
            {region.reasons.map(({ icon, title: reason, body }) => (
              <div key={reason} className="bg-surface-white rounded-xl p-8 border border-outline-variant shadow-tactile">
                <div className="w-11 h-11 rounded-lg bg-sky-tint flex items-center justify-center mb-5">
                  <span aria-hidden="true" className="material-symbols-outlined text-accent-deep text-2xl">{icon}</span>
                </div>
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-2">{reason}</h3>
                <p className="text-on-surface-variant text-body-main">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* On the day */}
      <section className="py-14 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12">
          <div>
            <h2 className="text-headline-h2 font-bold text-navy-deep mb-4">
              Collection day {region.where}
            </h2>
            <p className="text-on-surface-variant text-body-main mb-6">
              Book a morning, afternoon or evening window. We carry from your door, and
              photograph and scan every box in front of you before it leaves. Tell us these
              things when you book:
            </p>
            <Link
              href="/how-it-works"
              className="text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
            >
              The full collection and return process
              <span aria-hidden="true" className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
            {/* Moves serve the same suburbs; a suburb search is often a move search. */}
            <p className="mt-4 text-on-surface-variant text-body-main">
              Moving house rather than storing?{" "}
              <Link href="/mini-moves" className="text-accent-deep font-body-strong hover:underline">
                Mini moves {region.where}
              </Link>
              , home to home or part into storage.
            </p>
            <CoverageMap active={region.slug} className="mt-10 !mx-0 !max-w-[320px]" />
          </div>
          <ul className="space-y-4">
            {region.onTheDay.map((point) => (
              <li key={point} className="flex items-start gap-3 bg-surface-white rounded-xl border border-outline-variant p-5">
                <span aria-hidden="true" className="material-symbols-outlined text-accent-deep shrink-0">
                  check_circle
                </span>
                <span className="text-navy-deep text-body-main">{point}</span>
              </li>
            ))}
          </ul>
        </div>
      </section>

      {/* Elsewhere in the city */}
      <section className="py-14 md:py-20 bg-surface-white">
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-start">
          <div>
            <h2 className="text-headline-h3 font-bold text-navy-deep mb-5">
              Elsewhere in Cape Town
            </h2>
            <ul className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-3">
              {others.map((r) => (
                <li key={r.slug}>
                  <Link
                    href={`/areas/${r.slug}`}
                    className="text-accent-deep font-body-strong hover:underline"
                  >
                    Storage {r.where}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <div className="bg-mist rounded-xl border border-outline-variant p-6 md:p-8">
            <SuburbChecker />
          </div>
        </div>
      </section>
    </>
  );
}
