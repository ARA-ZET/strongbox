import type { Metadata } from "next";
import {
  CONTACT_EMAIL,
  CONTACT_PHONE_HREF,
  SOCIAL_LINKS,
  BOX_FROM,
  BOX_TYPES,
  FAQ_ITEMS,
  HQ_SUBURB,
  HQ_POSTCODE,
  HQ_GEO,
  SERVICE_AREAS,
  OPENING_HOURS,
} from "@/lib/constants";
import type { Article } from "@/lib/resources";

/**
 * One source of truth for everything a crawler reads.
 *
 * Before this module the canonical URL was declared once, in the root layout,
 * and Next merges `alternates` shallowly — so every page that did not restate
 * it inherited the homepage's. Eight of the fourteen routes were telling
 * Google they were duplicates of `/` and asking to be dropped from the index.
 * Building metadata through `pageMeta` makes the canonical impossible to
 * forget, because the path is a required argument.
 */
export const SITE_URL = "https://www.strongboxstorage.co.za";
export const SITE_NAME = "StrongBox Valet Storage";
export const LEGAL_NAME = "StrongBox Valet Storage";

/** Absolute URL for a site-relative path. `""` is the homepage. */
export const url = (path = ""): string => `${SITE_URL}${path}`;

type PageMetaInput = {
  title: string;
  description: string;
  /** Site-relative, leading slash, no trailing slash. `""` for the homepage. */
  path: string;
  /** Overrides the shared social card title, which defaults to `title`. */
  ogTitle?: string;
  type?: "website" | "article";
  /** ISO date, article pages only. */
  modifiedTime?: string;
};

/**
 * Page metadata with the canonical and the social card filled in together.
 *
 * `openGraph` is shallow-merged by Next in the same way `alternates` is, so a
 * page that sets only `title` kept the root layout's OG title — every link
 * shared to WhatsApp unfurled as the homepage regardless of which page was
 * sent. Restating `openGraph` per page is what actually fixes that.
 */
export function pageMeta({
  title,
  description,
  path,
  ogTitle,
  type = "website",
  modifiedTime,
}: PageMetaInput): Metadata {
  const canonical = url(path);
  return {
    title,
    description,
    alternates: { canonical },
    openGraph: {
      type,
      locale: "en_ZA",
      siteName: SITE_NAME,
      url: canonical,
      title: ogTitle ?? title,
      description,
      ...(modifiedTime ? { modifiedTime } : {}),
    },
    twitter: {
      card: "summary_large_image",
      title: ogTitle ?? title,
      description,
    },
  };
}

/* -------------------------------------------------------------------------
 * Structured data
 *
 * Emitted as plain <script type="application/ld+json"> via the `JsonLd`
 * component in `components/JsonLd.tsx`. Every builder returns a plain object
 * so the shapes stay diffable and testable.
 * ---------------------------------------------------------------------- */

/** Stable @id so every graph node can point at the one business. */
const BUSINESS_ID = `${SITE_URL}/#business`;
const ORG_ID = `${SITE_URL}/#organisation`;

/**
 * The trading entity. `SelfStorage` is the closest schema.org type Google
 * recognises for a storage operator; `MovingCompany` is added as a second
 * type because the collection-and-return half of the service is what people
 * actually search for.
 */
export function localBusinessJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": ["SelfStorage", "MovingCompany"],
    "@id": BUSINESS_ID,
    name: SITE_NAME,
    legalName: LEGAL_NAME,
    url: SITE_URL,
    image: url("/opengraph-image"),
    logo: url("/icon.svg"),
    description:
      "Valet storage in Cape Town. We collect your belongings from your door, store them in our monitored Kensington facility, and return them on request.",
    telephone: CONTACT_PHONE_HREF.replace("tel:", ""),
    email: CONTACT_EMAIL,
    priceRange: `From R${BOX_FROM} per month`,
    currenciesAccepted: "ZAR",
    // One facility. `areaServed` below is what carries the rest of the metro —
    // inventing branch addresses to chase suburb searches is what gets a
    // Google Business Profile suspended.
    address: {
      "@type": "PostalAddress",
      addressLocality: HQ_SUBURB,
      addressRegion: "Western Cape",
      postalCode: HQ_POSTCODE,
      addressCountry: "ZA",
    },
    geo: {
      "@type": "GeoCoordinates",
      latitude: HQ_GEO.lat,
      longitude: HQ_GEO.lng,
    },
    areaServed: SERVICE_AREAS.map((name) => ({
      "@type": "Place",
      name: `${name}, Cape Town`,
    })),
    openingHoursSpecification: OPENING_HOURS.map(({ days, opens, closes }) => ({
      "@type": "OpeningHoursSpecification",
      dayOfWeek: days,
      opens,
      closes,
    })),
    sameAs: SOCIAL_LINKS.filter((s) => s.href).map((s) => s.href),
    parentOrganization: { "@id": ORG_ID },
  };
}

export function organizationJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    "@id": ORG_ID,
    name: SITE_NAME,
    url: SITE_URL,
    logo: url("/icon.svg"),
    email: CONTACT_EMAIL,
    telephone: CONTACT_PHONE_HREF.replace("tel:", ""),
    sameAs: SOCIAL_LINKS.filter((s) => s.href).map((s) => s.href),
  };
}

export function websiteJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "@id": `${SITE_URL}/#website`,
    name: SITE_NAME,
    url: SITE_URL,
    inLanguage: "en-ZA",
    publisher: { "@id": ORG_ID },
  };
}

/**
 * Only emit this on pages that visibly render `FAQ_ITEMS`. Google treats FAQ
 * markup on a page with no matching answers on screen as a mismatch, and the
 * root layout was shipping it on every route including the legal pages.
 */
export function faqJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: FAQ_ITEMS.map(({ q, a }) => ({
      "@type": "Question",
      name: q,
      acceptedAnswer: { "@type": "Answer", text: a },
    })),
  };
}

/**
 * Breadcrumbs. Home is prepended for you — pass only the trail below it, in
 * order, ending with the current page.
 */
export function breadcrumbJsonLd(trail: { name: string; path: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: [{ name: "Home", path: "" }, ...trail].map((item, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: item.name,
      item: url(item.path),
    })),
  };
}

export function articleJsonLd(article: Article) {
  const canonical = url(`/resources/${article.slug}`);
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    "@id": `${canonical}#article`,
    headline: article.title,
    description: article.excerpt,
    inLanguage: "en-ZA",
    // The guides carry no per-author byline, so the publisher is the author.
    author: { "@id": ORG_ID },
    publisher: { "@id": ORG_ID },
    dateModified: article.updated,
    datePublished: article.updated,
    mainEntityOfPage: { "@type": "WebPage", "@id": canonical },
    articleSection: article.category,
    timeRequired: `PT${article.readMinutes}M`,
  };
}

/**
 * The service itself, with the box tiers as offers. Prices are the monthly
 * storage rate; the one-off collection fee is quoted separately and is
 * deliberately not folded in here.
 */
export function serviceJsonLd() {
  return {
    "@context": "https://schema.org",
    "@type": "Service",
    serviceType: "Valet storage",
    provider: { "@id": BUSINESS_ID },
    areaServed: { "@type": "City", name: "Cape Town" },
    hasOfferCatalog: {
      "@type": "OfferCatalog",
      name: "StrongBox storage plans",
      itemListElement: BOX_TYPES.map((box) => ({
        "@type": "Offer",
        name: box.label,
        description: box.desc,
        price: box.price,
        priceCurrency: "ZAR",
        availability: "https://schema.org/InStock",
        priceSpecification: {
          "@type": "UnitPriceSpecification",
          price: box.price,
          priceCurrency: "ZAR",
          unitCode: "MON",
          billingIncrement: 1,
        },
      })),
    },
  };
}
