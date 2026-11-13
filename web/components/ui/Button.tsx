import Link from "next/link";

/**
 * The site's one button.
 *
 * Every page used to hand-write its own class string, which is how the site
 * ended up with 48px, 52px and 56px buttons, square and pill corners, and
 * three different hover behaviours. One component, four looks, two sizes.
 */
type Variant = "primary" | "secondary" | "on-dark" | "inverse";
type Size = "md" | "lg";

const BASE =
  "inline-flex items-center justify-center gap-2 rounded-xl font-semibold whitespace-nowrap transition-colors duration-200 active:translate-y-px";

const VARIANTS: Record<Variant, string> = {
  /** The main action. Accent fill, white label (4.77:1). */
  primary: "bg-accent text-on-accent hover:bg-accent-deep",
  /** Second action on a light ground. */
  secondary:
    "border border-navy-deep/25 text-navy-deep bg-surface-white hover:border-navy-deep hover:bg-mist",
  /** Second action on navy. */
  "on-dark":
    "border border-surface-white/35 text-surface-white hover:bg-surface-white hover:text-navy-deep hover:border-surface-white",
  /** Main action on an accent or navy panel. */
  inverse: "bg-surface-white text-navy-deep hover:bg-sky-tint",
};

const SIZES: Record<Size, string> = {
  md: "h-12 px-5 text-[15px]",
  lg: "h-14 px-7 text-base",
};

export default function Button({
  href,
  children,
  variant = "primary",
  size = "lg",
  arrow = false,
  className = "",
  external = false,
}: {
  href: string;
  children: React.ReactNode;
  variant?: Variant;
  size?: Size;
  /** Trailing arrow, for the action that moves the visitor forward. */
  arrow?: boolean;
  className?: string;
  /** Open in a new tab — WhatsApp, maps. */
  external?: boolean;
}) {
  const cls = `${BASE} ${VARIANTS[variant]} ${SIZES[size]} ${className}`;
  const body = (
    <>
      {children}
      {arrow && (
        <span aria-hidden="true" className="material-symbols-outlined text-xl">
          arrow_forward
        </span>
      )}
    </>
  );

  // Anything that is not a site-relative path leaves the Next router: the app
  // lives on its own origin, and tel:/mailto:/wa.me are not routes at all.
  if (!href.startsWith("/")) {
    return (
      <a
        href={href}
        className={cls}
        {...(external ? { target: "_blank", rel: "noopener noreferrer" } : {})}
      >
        {body}
      </a>
    );
  }
  return (
    <Link href={href} className={cls}>
      {body}
    </Link>
  );
}
