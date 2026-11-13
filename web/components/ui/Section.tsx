/**
 * A full-bleed band with the content column inside it.
 *
 * One vertical rhythm for the whole site. Bands separate by ground colour
 * alone — the shaped dividers and their extra 72px of decoration are gone.
 */
type Tone = "white" | "mist" | "navy";

const TONES: Record<Tone, string> = {
  white: "bg-surface-white",
  mist: "bg-mist",
  navy: "bg-navy-deep text-surface-white on-dark",
};

const SPACE = {
  /** Heroes and closing bands. */
  sm: "py-12 md:py-16",
  md: "py-16 md:py-24",
} as const;

export default function Section({
  children,
  tone = "white",
  space = "md",
  id,
  className = "",
  innerClassName = "",
}: {
  children: React.ReactNode;
  tone?: Tone;
  space?: keyof typeof SPACE;
  id?: string;
  className?: string;
  innerClassName?: string;
}) {
  return (
    <section id={id} className={`${TONES[tone]} ${SPACE[space]} ${className}`}>
      <div className={`max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop ${innerClassName}`}>
        {children}
      </div>
    </section>
  );
}

/** The content column on its own, for bands that need a custom wrapper. */
export const CONTAINER = "max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop";
