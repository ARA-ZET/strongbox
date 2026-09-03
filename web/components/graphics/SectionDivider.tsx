import { PALETTE, type PaletteTone } from "@/lib/palette";

/**
 * Shaped boundary between two full-bleed sections, so the page reads as a
 * flowing composition rather than a stack of coloured rectangles.
 *
 * The divider paints `from` as its own background and cuts the `to` colour
 * out of it, so it must be rendered *between* the two sections it joins and
 * both tones must match the neighbouring section backgrounds.
 */
export type DividerVariant = "angle" | "wave";

const PATHS: Record<DividerVariant, string> = {
  // Straight diagonal — the calmest transition.
  angle: "M0 96 L1440 0 L1440 96 Z",
  // Soft double curve.
  wave:
    "M0 48 C240 100 420 4 720 34 C1000 62 1220 6 1440 40 L1440 96 L0 96 Z",
};

/**
 * Rendered heights. `md` is the default and suits transitions deep in the
 * page, where the reader has already committed to scrolling. `sm` is for the
 * boundary immediately below the hero: there, 72px of pure decoration is
 * 72px of the first screen not spent on telling the visitor anything.
 */
const HEIGHTS = {
  sm: "h-[28px] md:h-[44px]",
  md: "h-[40px] md:h-[72px]",
} as const;

export default function SectionDivider({
  from,
  to,
  variant = "angle",
  flip = false,
  size = "md",
  className = "",
}: {
  from: PaletteTone;
  to: PaletteTone;
  variant?: DividerVariant;
  /** Mirror horizontally, so alternating dividers don't all lean the same way. */
  flip?: boolean;
  size?: keyof typeof HEIGHTS;
  className?: string;
}) {
  return (
    <div
      aria-hidden="true"
      className={`w-full leading-none ${className}`}
      style={{ backgroundColor: PALETTE[from] }}
    >
      <svg
        viewBox="0 0 1440 96"
        preserveAspectRatio="none"
        className={`block w-full ${HEIGHTS[size]} ${flip ? "-scale-x-100" : ""}`}
      >
        <path d={PATHS[variant]} fill={PALETTE[to]} />
      </svg>
    </div>
  );
}
