/**
 * An icon, a short heading and a line of explanation, in a row.
 *
 * The site's most repeated unit. It used to be re-typed on every page with
 * slightly different sizes; this is the one version.
 */
export default function IconPoint({
  icon,
  title,
  children,
  dark = false,
  as: Tag = "div",
  heading: Heading = "h3",
}: {
  icon: string;
  title: string;
  children: React.ReactNode;
  dark?: boolean;
  as?: "div" | "li";
  heading?: "h2" | "h3" | "h4" | "p";
}) {
  return (
    <Tag className="flex items-start gap-4">
      <span
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${
          dark ? "bg-surface-white/10 text-sky" : "bg-sky-tint text-accent-deep"
        }`}
      >
        <span aria-hidden="true" className="material-symbols-outlined text-[22px]">
          {icon}
        </span>
      </span>
      <div>
        <Heading className={`font-semibold leading-snug ${dark ? "text-surface-white" : "text-navy-deep"}`}>
          {title}
        </Heading>
        <p className={`mt-1 text-[15px] leading-relaxed ${dark ? "text-on-navy-variant" : "text-on-surface-variant"}`}>
          {children}
        </p>
      </div>
    </Tag>
  );
}
