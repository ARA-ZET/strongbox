import type { Metadata } from "next";
import Link from "next/link";
import ClosingCta from "@/components/ClosingCta";
import FAQAccordion from "@/components/FAQAccordion";
import JsonLd from "@/components/JsonLd";
import PhotoFeature from "@/components/PhotoFeature";
import PhotoHero from "@/components/PhotoHero";
import Button from "@/components/ui/Button";
import IconPoint from "@/components/ui/IconPoint";
import Section from "@/components/ui/Section";
import SectionHeading from "@/components/ui/SectionHeading";
import { CONTACT_PHONE_DISPLAY, CONTACT_PHONE_HREF } from "@/lib/constants";
import {
  MOVES_PATH,
  MOVE_CONTACT_HREF,
  MOVE_PREP,
  MOVE_STEPS,
  MOVE_TYPES,
  MOVE_WHATSAPP_HREF,
  moveFaq,
} from "@/lib/moves";
import { getPrices } from "@/lib/prices";
import { ARTICLES } from "@/lib/resources";
import { breadcrumbJsonLd, faqJsonLd, movesServiceJsonLd, pageMeta, url } from "@/lib/seo";

const TRAIL = [{ name: "Mini moves", path: MOVES_PATH }];

/*
 * "Mini moves" is the product's name and what the page is called; "furniture
 * removals" is what Cape Town types into a search box, so the title carries
 * both. The description names the three move types, because the split move
 * is the reason to choose us over a man with a bakkie.
 */
export const metadata: Metadata = pageMeta({
  title: "Mini Moves & Furniture Removals in Cape Town",
  ogTitle: "Mini moves across Cape Town, with storage if you need it",
  description:
    "Small furniture moves across Cape Town: a few pieces, a room or a small flat. Home to home, into your own storage, or split with StrongBox storage.",
  path: MOVES_PATH,
  image: {
    url: url(`${MOVES_PATH}/opengraph-image`),
    alt: "StrongBox mini moves: small furniture moves across Cape Town",
  },
});

/** The guides that pair with a move. Looked up so a renamed guide stays right. */
const RELATED_GUIDES = ["moving-out-checklist", "semigrating-to-cape-town"]
  .map((slug) => ARTICLES.find((a) => a.slug === slug))
  .filter((a): a is (typeof ARTICLES)[number] => a !== undefined);

export default async function MiniMovesPage() {
  const { boxFrom, vehicles } = await getPrices();
  const faq = moveFaq(boxFrom);
  const maxM3 = Math.max(0, ...vehicles.map((v) => v.capacityM3));

  /** Why split a move with us rather than with a removal company. */
  const splitPoints = [
    {
      icon: "qr_code_2",
      title: "Tracked from your door",
      body: "Each box and piece going into storage is photographed and scanned before it leaves, then given its own shelf position.",
    },
    {
      icon: "calendar_month",
      title: `From R${boxFrom} a box a month`,
      body: "Billed monthly for what we hold, priced per box or item, with no minimum term and no lock-in.",
    },
    {
      icon: "local_shipping",
      title: "Back when you are ready",
      body: "Ask in your account and it is delivered to your door, usually the next business day. One box or the lot.",
    },
    {
      icon: "receipt_long",
      title: "The extra stop is in the quote",
      body: "The storage stop adds to the price of the move, and you see it in your quote before anything is booked.",
    },
  ];

  return (
    <>
      <JsonLd
        data={[movesServiceJsonLd(MOVE_TYPES, MOVES_PATH), breadcrumbJsonLd(TRAIL), faqJsonLd(faq)]}
      />

      {/* ── Hero: the offer, and the three ways it can end ── */}
      <PhotoHero
        photo="hero-loose"
        trail={TRAIL}
        eyebrow="Small furniture removals, anywhere in the metro"
        title="Mini moves across Cape Town"
        lead="A few pieces of furniture, a room or a small flat, carried from your door. Take it to your new home, into a storage unit you already use, or split it: what fits goes to the new place, and the rest comes into storage with us."
        aside={
          <div data-reveal className="rounded-2xl bg-surface-white p-2 text-navy-deep shadow-tactile-md">
            <p className="px-4 pb-1 pt-3 text-sm font-semibold text-on-surface-variant">
              Three ways to move
            </p>
            <ul>
              {MOVE_TYPES.map(({ id, icon, name }) => (
                <li key={id}>
                  <a
                    href={`#${id}`}
                    className="group flex min-h-[56px] items-center gap-4 rounded-xl px-4 py-2 hover:bg-mist"
                  >
                    <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-sky-tint">
                      <span aria-hidden="true" className="material-symbols-outlined text-xl text-accent-deep">
                        {icon}
                      </span>
                    </span>
                    <span className="flex-1 font-semibold">{name}</span>
                    <span
                      aria-hidden="true"
                      className="material-symbols-outlined text-accent-deep transition-transform group-hover:translate-y-0.5"
                    >
                      arrow_downward
                    </span>
                  </a>
                </li>
              ))}
            </ul>
          </div>
        }
      >
        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Button href={MOVE_WHATSAPP_HREF} external arrow>
            Get a move quote
          </Button>
          <Button href={CONTACT_PHONE_HREF} variant="on-dark">
            <span aria-hidden="true" className="material-symbols-outlined text-xl">call</span>
            {CONTACT_PHONE_DISPLAY}
          </Button>
        </div>
        <p className="mt-6 flex items-start gap-2 text-sm text-on-navy">
          <span aria-hidden="true" className="material-symbols-outlined shrink-0 text-lg text-sky">
            location_on
          </span>
          <span>
            Quoted before you book, anywhere in the City of Cape Town.{" "}
            <Link href="/areas" className="text-surface-white underline underline-offset-4 hover:text-sky">
              Check your suburb
            </Link>
          </span>
        </p>
      </PhotoHero>

      {/* ── The three move types ── */}
      <Section>
        <SectionHeading
          title="Three ways to move, one team doing the lifting"
          lead="Every mini move starts at your door. Where it ends is up to you."
        />
        <div className="grid gap-gutter md:grid-cols-3">
          {MOVE_TYPES.map((move, i) => {
            const featured = "badge" in move;
            return (
              <article
                key={move.id}
                id={move.id}
                data-reveal
                style={{ ["--i" as string]: i }}
                className={`flex scroll-mt-28 flex-col rounded-2xl border bg-surface-white p-6 sm:p-8 ${
                  featured ? "border-accent ring-1 ring-accent" : "border-outline-variant"
                }`}
              >
                <div className="flex items-start justify-between gap-3">
                  <span className="flex h-11 w-11 items-center justify-center rounded-lg bg-sky-tint">
                    <span aria-hidden="true" className="material-symbols-outlined text-2xl text-accent-deep">
                      {move.icon}
                    </span>
                  </span>
                  {featured && (
                    <span className="rounded-full bg-sky-tint px-3 py-1 text-xs font-semibold text-accent-deep">
                      {move.badge}
                    </span>
                  )}
                </div>
                <p className="mt-5 text-sm font-semibold text-accent-deep">{move.tagline}</p>
                <h3 className="mt-1 text-headline-h3 font-semibold text-navy-deep">{move.name}</h3>
                <p className="mb-auto mt-3 text-body-main text-on-surface-variant">{move.body}</p>
                <p className="mt-6 border-t border-outline-variant pt-5 text-sm text-on-surface-variant">
                  <span className="font-semibold text-navy-deep">Best for: </span>
                  {move.bestFor}
                </p>
              </article>
            );
          })}
        </div>
      </Section>

      {/* ── What "mini" means ── */}
      {/*
        The size limit, stated plainly. The vehicles come from the live price
        list, so a fleet change reaches this page without an edit. Their
        collection fees are deliberately not shown: a move is quoted on more
        than the vehicle, and a storage fee here would read as a move price.
      */}
      <Section tone="mist">
        <div className="grid items-start gap-12 lg:grid-cols-2 lg:gap-16">
          <div data-reveal>
            <h2 className="text-headline-h1 font-bold text-navy-deep">
              If it goes in one trip, it is a mini move
            </h2>
            <p className="mt-4 text-body-lead text-on-surface-variant">
              A couch and a bed. A room. A student or bachelor flat. We send the vehicle the load
              needs{maxM3 > 0 ? `, up to ${maxM3} m³ in a single trip` : ""}.
            </p>
            <p className="mt-4 text-body-main text-on-surface-variant">
              A full house is a different job. It needs a bigger truck and a bigger crew than we
              send, and a removal company is the better choice. We will tell you that when you ask.
            </p>
            <p className="mt-4 text-body-main text-on-surface-variant">
              Mini moves run anywhere in the City of Cape Town, the same suburbs we collect from for
              storage.{" "}
              <Link href="/areas" className="font-semibold text-accent-deep hover:underline">
                See the areas we serve
              </Link>
            </p>
          </div>
          <div data-reveal style={{ ["--i" as string]: 1 }}>
            <h3 className="mb-4 text-headline-h3 font-semibold text-navy-deep">The vehicles we send</h3>
            <ul className="divide-y divide-outline-variant overflow-hidden rounded-2xl border border-outline-variant bg-surface-white">
              {vehicles.map(({ id, icon, label, desc }) => (
                <li key={id} className="flex items-center gap-4 p-5">
                  <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-sky-tint">
                    <span aria-hidden="true" className="material-symbols-outlined text-2xl text-accent-deep">
                      {icon}
                    </span>
                  </span>
                  <div>
                    <p className="font-semibold text-navy-deep">{label}</p>
                    <p className="text-sm text-on-surface-variant">{desc}</p>
                  </div>
                </li>
              ))}
            </ul>
            <p className="mt-3 text-sm text-on-surface-variant">
              Not sure which? Send us a list or a few photos and we will choose.
            </p>
          </div>
        </div>
      </Section>

      {/* ── How it works ── */}
      <Section>
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-20">
          <div>
            <SectionHeading
              title="How a mini move works"
              lead="From your first message to the last piece carried in."
              className="!mb-10"
            />
            <ol className="relative">
              {MOVE_STEPS.map(({ title, body }, i) => (
                <li
                  key={title}
                  data-reveal
                  style={{ ["--i" as string]: i }}
                  className="relative flex gap-5 pb-9 last:pb-0"
                >
                  {i < MOVE_STEPS.length - 1 && (
                    <span
                      aria-hidden="true"
                      className="absolute left-5 top-11 h-[calc(100%-2.75rem)] w-px bg-outline-variant"
                    />
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
          </div>
          <PhotoFeature
            id="collect"
            sizes="(min-width: 1280px) 560px, (min-width: 1024px) 46vw, 100vw"
          />
        </div>
      </Section>

      {/* ── The split move: where moves and storage meet ── */}
      <Section tone="navy">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div data-reveal>
            <p className="mb-3 text-[13px] font-semibold text-sky">Split moves</p>
            <h2 className="text-headline-h1 font-bold">Move what fits. Store the rest with us.</h2>
            <p className="mt-4 text-body-lead text-on-navy">
              Moving somewhere smaller, or into a place that is not ready yet, rarely means
              everything goes to the same address. On a split move one booking does both: what fits
              is carried into your new home, and the rest comes to our facility in Kensington.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Button href="/how-it-works" variant="inverse">
                How storage works
              </Button>
              <Button href="/pricing" variant="on-dark">
                Storage prices
              </Button>
            </div>
          </div>
          <div className="space-y-6">
            {splitPoints.map(({ icon, title, body }) => (
              <IconPoint key={title} icon={icon} title={title} dark>
                {body}
              </IconPoint>
            ))}
          </div>
        </div>
      </Section>

      {/* ── Preparation ── */}
      <Section tone="mist">
        <SectionHeading
          title="Before moving day"
          lead="Six things that keep the day on schedule, and the quote accurate."
        />
        <ul className="grid gap-x-10 gap-y-8 sm:grid-cols-2 lg:grid-cols-3">
          {MOVE_PREP.map(({ icon, title, body }, i) => (
            <li key={title} data-reveal style={{ ["--i" as string]: i % 3 }}>
              <IconPoint icon={icon} title={title}>
                {body}
              </IconPoint>
            </li>
          ))}
        </ul>
        {RELATED_GUIDES.length > 0 && (
          <div data-reveal className="mt-12 border-t border-outline-variant pt-8">
            <h3 className="font-semibold text-navy-deep">Planning the rest of the move?</h3>
            <ul className="mt-3 flex flex-col gap-2 sm:flex-row sm:flex-wrap sm:gap-x-8">
              {RELATED_GUIDES.map(({ slug, title }) => (
                <li key={slug}>
                  <Link
                    href={`/resources/${slug}`}
                    className="inline-flex items-center gap-1.5 font-semibold text-accent-deep hover:underline"
                  >
                    {title}
                    <span aria-hidden="true" className="material-symbols-outlined text-lg">
                      arrow_forward
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        )}
      </Section>

      {/* ── FAQ: rendered here and marked up from the same list ── */}
      <FAQAccordion
        items={faq}
        title="Questions about mini moves"
        lead="Prices, distance, dismantling and insurance."
      />

      <ClosingCta
        title="Tell us what is moving"
        body="Send both suburbs, the date and a list or a few photos. We will come back with a quote and a time window."
        primary={{ href: MOVE_WHATSAPP_HREF, label: "Get a move quote" }}
        secondary={{ href: MOVE_CONTACT_HREF, label: "Send the details" }}
      />
    </>
  );
}
