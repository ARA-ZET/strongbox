import type { Metadata } from "next";
import Link from "next/link";
import FullCalculator from "@/components/FullCalculator";
import ClosingCta from "@/components/ClosingCta";
import JsonLd from "@/components/JsonLd";
import Section from "@/components/ui/Section";
import SectionHeading from "@/components/ui/SectionHeading";
import BoxScale from "@/components/visuals/BoxScale";
import PhotoHero from "@/components/PhotoHero";
import SitePhoto from "@/components/SitePhoto";
import { APP_URL } from "@/lib/constants";
import { getPrices } from "@/lib/prices";
import { pageMeta, breadcrumbJsonLd, serviceJsonLd } from "@/lib/seo";

const TRAIL = [{ name: "Pricing", path: "/pricing" }];

export async function generateMetadata(): Promise<Metadata> {
  const { boxFrom } = await getPrices();
  return pageMeta({
    title: `Storage Prices in Cape Town, From R${boxFrom} a Box`,
    description: `Pay per box or item, per month, from R${boxFrom}. No contract, no minimum term and no paying for empty space. See every price and build your own quote.`,
    path: "/pricing",
  });
}

const INCLUDED = [
  { title: "Climate-managed storage", body: "Temperature and humidity kept in a range that suits furniture, fabric, paper and electronics." },
  { title: "A photo record of every box", body: "Taken at collection and kept in your account for as long as we hold the box." },
  { title: "A monitored facility", body: "CCTV and access control on every door into the storage floor." },
  { title: "Next-business-day returns", body: "Ask before 12:00 and it is back with you the next business day." },
];

export default async function PricingPage() {
  const prices = await getPrices();
  const { boxes, boxFrom, looseItemFrom, vehicles } = prices;
  return (
    <>
      <JsonLd data={[breadcrumbJsonLd(TRAIL), serviceJsonLd(boxes)]} />

      {/* Hero */}
      <PhotoHero
        photo="hero-pricing"
        trail={TRAIL}
        title="Storage prices in Cape Town"
        lead={
          <p>
            You pay per box or item, per month, from R{boxFrom}. There is no contract, no
            minimum term, and nothing to pay for space you are not using.
          </p>
        }
      >
        <a
          href="#calculator"
          className="mt-7 inline-flex items-center gap-1.5 font-semibold text-surface-white underline-offset-4 hover:underline"
        >
          Skip to the quote builder
          <span aria-hidden="true" className="material-symbols-outlined text-lg text-sky">arrow_downward</span>
        </a>
      </PhotoHero>

      {/* The rate card */}
      <Section>
        <SectionHeading
          title="What it costs"
          lead="Two kinds of charge: a monthly price for each thing we store, and a once-off fee each time a vehicle comes to you."
        />
        <div className="grid gap-12 lg:grid-cols-2 lg:gap-16">
          <div data-reveal>
            <BoxScale boxes={boxes} />
            <p className="mb-10 mt-3 text-xs text-on-surface-variant">
              Boxes drawn to scale by volume, beside a dining chair.
            </p>
            <table className="w-full text-left">
              <caption className="mb-4 text-left text-headline-h3 font-semibold text-navy-deep">
                Boxes, per month
              </caption>
              <thead className="sr-only">
                <tr>
                  <th scope="col">Size</th>
                  <th scope="col">Monthly price</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant border-y border-outline-variant">
                {boxes.map(({ id, label, desc, price }) => (
                  <tr key={id}>
                    <th scope="row" className="py-4 pr-4 font-normal">
                      <span className="block font-semibold text-navy-deep">{label}</span>
                      <span className="block text-sm text-on-surface-variant">{desc}</span>
                    </th>
                    <td className="whitespace-nowrap py-4 text-right text-lg font-bold text-navy-deep">
                      R{price}
                      <span className="text-sm font-normal text-on-surface-variant"> /mo</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div data-reveal style={{ ["--i" as string]: 1 }}>
            <table className="w-full text-left">
              <caption className="mb-4 text-left text-headline-h3 font-semibold text-navy-deep">
                Collection, once-off
              </caption>
              <thead className="sr-only">
                <tr>
                  <th scope="col">Vehicle</th>
                  <th scope="col">Fee per collection</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant border-y border-outline-variant">
                {vehicles.map(({ id, label, desc, price }) => (
                  <tr key={id}>
                    <th scope="row" className="py-4 pr-4 font-normal">
                      <span className="block font-semibold text-navy-deep">{label}</span>
                      <span className="block text-sm text-on-surface-variant">{desc}</span>
                    </th>
                    <td className="whitespace-nowrap py-4 text-right text-lg font-bold text-navy-deep">
                      R{price}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <p className="mt-3 text-sm text-on-surface-variant">
              The fee depends on the vehicle your load needs, not on your suburb.
            </p>
            {/*
              A collection fee is the closest thing on this page to a moving
              price, so this is where someone after a move is most likely to
              be reading. Moves are quoted per job and have no rate card.
            */}
            <p className="mt-4 flex items-start gap-2 rounded-xl border border-outline-variant bg-mist p-4 text-sm text-on-surface-variant">
              <span aria-hidden="true" className="material-symbols-outlined shrink-0 text-lg text-accent-deep">
                local_shipping
              </span>
              <span>
                <span className="font-semibold text-navy-deep">Moving rather than storing?</span>{" "}
                Mini moves, home to home or part into storage, are quoted per move.{" "}
                <Link href="/mini-moves" className="font-semibold text-accent-deep hover:underline">
                  See mini moves
                </Link>
              </span>
            </p>

            <div className="mt-12 overflow-hidden rounded-2xl border border-outline-variant bg-mist">
              <div className="relative aspect-[16/9]">
                <SitePhoto
                  id="hero-loose"
                  sizes="(min-width: 1280px) 568px, (min-width: 1024px) 46vw, 100vw"
                  className="absolute inset-0"
                />
              </div>
              <div className="p-6 sm:p-8">
                <h3 className="text-headline-h3 font-semibold text-navy-deep">
                  Things that do not fit in a box
                </h3>
                <p className="mt-2 text-body-main text-on-surface-variant">
                  Bicycles, surfboards, golf bags and single pieces of furniture are priced
                  individually, by the space each one takes up. From R{looseItemFrom} a month.
                </p>
                <Link
                  href="/loose-items"
                  className="mt-5 inline-flex items-center gap-1.5 font-semibold text-accent-deep hover:underline"
                >
                  See every loose-item price
                  <span aria-hidden="true" className="material-symbols-outlined text-lg">arrow_forward</span>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </Section>

      {/* Full calculator */}
      <Section tone="mist" id="calculator">
        <SectionHeading
          title="Build your quote"
          lead="Add what you want to store and the vehicle to fetch it. You see the monthly and once-off totals before you book anything."
        />
        <FullCalculator prices={prices} />
      </Section>

      {/* Included */}
      <Section>
        <div className="grid gap-10 lg:grid-cols-[minmax(0,4fr)_minmax(0,8fr)] lg:gap-16">
          <div data-reveal>
            <h2 className="text-headline-h1 font-bold text-navy-deep">Included with every box</h2>
            <p className="mt-4 text-body-lead text-on-surface-variant">
              None of these is an add-on or a higher tier.
            </p>
          </div>
          <div>
            <dl className="grid gap-x-10 sm:grid-cols-2">
              {INCLUDED.map(({ title, body }) => (
                <div key={title} data-reveal className="border-t border-outline-variant py-5">
                  <dt className="flex items-center gap-2 font-semibold text-navy-deep">
                    <span aria-hidden="true" className="material-symbols-outlined text-lg text-emerald-600">check_circle</span>
                    {title}
                  </dt>
                  <dd className="mt-1.5 text-[15px] leading-relaxed text-on-surface-variant">{body}</dd>
                </div>
              ))}
            </dl>

            {/*
              Stated where people evaluate the price, not only in the FAQ and
              the terms. Insurance is the one thing a prospect is likely to
              assume is bundled. It is not, and finding that out after
              collection day is the worst possible moment.
            */}
            <div data-reveal className="mt-8 flex items-start gap-4 rounded-2xl border border-outline-variant bg-mist p-6">
              <span aria-hidden="true" className="material-symbols-outlined shrink-0 text-accent-deep">info</span>
              <div>
                <h3 className="font-semibold text-navy-deep">
                  Insurance is not included. You insure your own goods.
                </h3>
                <p className="mt-1.5 text-sm leading-relaxed text-on-surface-variant">
                  We are a storage and transport service, not an insurer. In South Africa
                  your household contents policy is normally the right place for this, and
                  most insurers will extend it to goods held in storage once you tell them
                  where the items are. Have a word with your insurer or broker before
                  collection day. Every box is photographed and barcoded to your account,
                  so you have the record a claim would need.
                </p>
              </div>
            </div>
          </div>
        </div>
      </Section>

      <ClosingCta
        title="Happy with the number?"
        body="Create your account and the quote you built comes with you. If you would rather talk it through first, we are a call or a WhatsApp away."
        primary={{ href: `${APP_URL}/register`, label: "Get started" }}
        secondary={{ href: "/contact", label: "Talk to us" }}
      />
    </>
  );
}
