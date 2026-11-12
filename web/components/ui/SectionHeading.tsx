/**
 * The heading block that opens a band.
 *
 * Left-aligned by default. The site used to centre every heading under a
 * small-caps label, on every band of every page, and the repetition is what
 * made it read as a template. The label is now optional and should be used
 * only where it tells the reader something the heading does not.
 */
export default function SectionHeading({
  title,
  lead,
  eyebrow,
  align = "left",
  dark = false,
  as: Tag = "h2",
  className = "",
}: {
  title: React.ReactNode;
  lead?: React.ReactNode;
  eyebrow?: string;
  align?: "left" | "center";
  /** Set on a navy band. */
  dark?: boolean;
  as?: "h1" | "h2";
  className?: string;
}) {
  const centred = align === "center";
  return (
    <div
      data-reveal
      className={`mb-10 md:mb-14 ${centred ? "text-center mx-auto" : ""} max-w-3xl ${className}`}
    >
      {eyebrow && (
        <p
          className={`text-[13px] font-semibold mb-3 ${
            dark ? "text-sky" : "text-accent-deep"
          }`}
        >
          {eyebrow}
        </p>
      )}
      <Tag
        className={`${Tag === "h1" ? "text-display-bold" : "text-headline-h1"} font-bold ${
          dark ? "text-surface-white" : "text-navy-deep"
        }`}
      >
        {title}
      </Tag>
      {lead && (
        <p
          className={`text-body-lead mt-4 ${centred ? "mx-auto" : ""} max-w-2xl ${
            dark ? "text-on-navy" : "text-on-surface-variant"
          }`}
        >
          {lead}
        </p>
      )}
    </div>
  );
}
