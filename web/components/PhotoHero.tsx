import SitePhoto from "@/components/SitePhoto";
import Breadcrumbs from "@/components/ui/Breadcrumbs";
import { CONTAINER } from "@/components/ui/Section";
import type { PhotoId } from "@/lib/photos";

/**
 * The opening band of every page: a photograph edge to edge, a navy wash over
 * it, and the page's h1 in white on top.
 *
 * The wash is what makes white type safe on any photo. On phones the text
 * covers the whole frame, so the wash is heavy everywhere (≥70% navy). From
 * `md` the text sits in the left half, so the wash runs solid navy on the left
 * and thins to the right, where the photo is left to speak. Hero photos are
 * framed (`focus` in lib/photos.ts) with their subject on the right for that
 * reason.
 *
 * The photo is the page's LCP element, so it is fetched at high priority and
 * never lazily.
 */
export default function PhotoHero({
  photo,
  title,
  lead,
  eyebrow,
  trail,
  height = "page",
  aside,
  footer,
  children,
}: {
  photo: PhotoId;
  title: React.ReactNode;
  lead?: React.ReactNode;
  eyebrow?: string;
  /** Breadcrumb trail below Home — the same array given to breadcrumbJsonLd. */
  trail?: { name: string; path: string }[];
  /** `tall` for the homepage, `page` for every other page. */
  height?: "tall" | "page";
  /** A card in the right-hand column on large screens, below the copy on small. */
  aside?: React.ReactNode;
  /** Full-width row at the bottom of the hero, e.g. trust badges. */
  footer?: React.ReactNode;
  /** Actions and anything else that belongs under the lead. */
  children?: React.ReactNode;
}) {
  const tall = height === "tall";
  return (
    <section className="on-dark relative isolate overflow-hidden bg-navy-deep text-surface-white">
      <SitePhoto id={photo} priority sizes="100vw" className="hero-photo absolute inset-0 -z-20" />
      <div
        aria-hidden="true"
        className="absolute inset-0 -z-10 bg-gradient-to-t from-navy-deep via-navy-deep/80 to-navy-deep/70 md:bg-gradient-to-r md:from-navy-deep md:via-navy-deep/80 md:to-navy-deep/10"
      />
      {/* Grounds the bottom edge, where a footer row runs the full width. */}
      <div
        aria-hidden="true"
        className="absolute inset-x-0 bottom-0 -z-10 hidden h-1/2 bg-gradient-to-t from-navy-deep/85 to-transparent md:block"
      />

      <div
        className={`${CONTAINER} flex flex-col justify-center ${
          tall
            ? "min-h-[600px] pb-10 pt-10 md:min-h-[680px] md:pb-12 md:pt-14 lg:min-h-[min(calc(100svh-128px),800px)]"
            : "min-h-[400px] py-14 md:min-h-[460px] md:py-20"
        }`}
      >
        {trail && <Breadcrumbs trail={trail} dark />}

        <div
          className={
            aside
              ? "grid grid-cols-1 items-center gap-10 lg:grid-cols-[minmax(0,1fr)_minmax(0,420px)] lg:gap-16"
              : undefined
          }
        >
          <div className="max-w-2xl">
            {eyebrow && <p className="mb-4 text-sm font-semibold text-sky">{eyebrow}</p>}
            <h1 className="text-display-bold font-bold">{title}</h1>
            {lead && <div className="mt-5 max-w-xl text-body-lead text-on-navy">{lead}</div>}
            {children}
          </div>
          {aside}
        </div>

        {footer}
      </div>
    </section>
  );
}
