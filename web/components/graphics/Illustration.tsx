/**
 * Brand-recoloured spot illustrations, served from `public/illustrations/`.
 *
 * The artwork comes from unDraw and is remapped onto the StrongBox palette at
 * download time (see `scripts/rebrand-illustrations.py`), so an illustration
 * dropped anywhere on the site already sits in the navy/blue system rather
 * than arriving in unDraw's indigo. The source SVGs keep only their `viewBox`,
 * which is what `RATIOS` below mirrors — the wrapper decides the rendered size
 * and the intrinsic ratio reserves the space so nothing shifts as art loads.
 */

export type IllustrationName =
  | "moving"
  | "facility"
  | "package-arrived"
  | "contact-us"
  | "questions"
  | "team"
  | "pricing"
  | "map-location"
  | "heavy-lifting"
  | "checklist";

/** Intrinsic `width / height` per illustration, read from its viewBox. */
const RATIOS: Record<IllustrationName, [number, number]> = {
  moving: [841, 405],
  facility: [800, 406],
  "package-arrived": [883, 801],
  "contact-us": [960, 462],
  questions: [960, 677],
  team: [901, 508],
  pricing: [799, 618],
  "map-location": [490, 471],
  "heavy-lifting": [960, 557],
  checklist: [800, 541],
};

export default function Illustration({
  name,
  alt = "",
  className = "",
  priority = false,
}: {
  name: IllustrationName;
  /**
   * Left empty by default: most of these are decorative reinforcement beside
   * copy that already says the same thing, and a screen reader gains nothing
   * from narrating them. Pass a description only where the art carries
   * information the surrounding text does not.
   */
  alt?: string;
  className?: string;
  /** Set on above-the-fold art so it is not lazily deferred. */
  priority?: boolean;
}) {
  const [w, h] = RATIOS[name];
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={`/illustrations/${name}.svg`}
      alt={alt}
      width={w}
      height={h}
      loading={priority ? "eager" : "lazy"}
      // Matches SitePhoto: eager alone leaves the fetch in the low-priority
      // bucket, and these sit beside the h1 in every page hero.
      fetchPriority={priority ? "high" : "auto"}
      decoding="async"
      aria-hidden={alt === "" ? true : undefined}
      role={alt === "" ? "presentation" : undefined}
      className={`w-full h-auto ${className}`}
    />
  );
}
