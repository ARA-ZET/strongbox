/**
 * The drawing kit.
 *
 * Every picture on the site is assembled from these few parts, drawn in one
 * hand: flat fills, a 2px outline, rounded joins, and the six colour roles
 * declared on `.viz` in `globals.css`. Because they share a kit, a van on the
 * homepage is the same van on the How It Works page, and a box is always the
 * same box.
 *
 * Parts are drawn from their own top-left corner; position them with `x`/`y`.
 */

export const INK = "var(--ink)";
export const PAPER = "var(--paper)";
export const TINT = "var(--tint)";
export const SOFT = "var(--soft)";
export const LINE = "var(--line)";
export const POP = "var(--pop)";
export const POP_SOFT = "var(--pop-soft)";

/** Shared outline. Spread onto any shape that should carry the house line. */
export const STROKE = {
  stroke: INK,
  strokeWidth: 2,
  strokeLinejoin: "round",
  strokeLinecap: "round",
} as const;

type At = { x?: number; y?: number };

const at = (x = 0, y = 0) => `translate(${x} ${y})`;

/**
 * A carton, seen slightly from above and to the right.
 *
 * `w`×`h` is the front face; the top and side faces are projected back by
 * `d`. The origin is the front face's top-left, so the top face rises above
 * `y` by `d * 0.5`.
 */
export function Carton({
  x,
  y,
  w = 60,
  h = 48,
  d = 16,
  label = true,
  tape = true,
  open = false,
  children,
}: At & {
  /** Drawn inside an open box: behind the front face, in front of the back. */
  children?: React.ReactNode;
  w?: number;
  h?: number;
  d?: number;
  /** The QR label on the front face. */
  label?: boolean;
  /** Packing tape over the top seam. */
  tape?: boolean;
  /** Flaps up, no tape. */
  open?: boolean;
}) {
  const dy = d * 0.5;
  const lw = Math.min(18, w * 0.3);
  return (
    <g transform={at(x, y)}>
      {/* side */}
      <path d={`M${w} 0 l${d} ${-dy} v${h} l${-d} ${dy} z`} fill={SOFT} {...STROKE} />
      {/* top */}
      {open ? (
        <>
          {/* inside of the box */}
          <path d={`M0 0 l${d} ${-dy} h${w} l${-d} ${dy} z`} fill={INK} opacity={0.18} />
          <path d={`M0 0 l${d} ${-dy} h${w} l${-d} ${dy} z`} fill="none" {...STROKE} />
          {/* back flap, standing */}
          <path d={`M${d} ${-dy} l4 ${-h * 0.3} h${w} l-4 ${h * 0.3} z`} fill={TINT} {...STROKE} />
          {children}
        </>
      ) : (
        <path d={`M0 0 l${d} ${-dy} h${w} l${-d} ${dy} z`} fill={TINT} {...STROKE} />
      )}
      {/* front */}
      <rect width={w} height={h} fill={PAPER} {...STROKE} />
      {open && (
        <path d={`M0 0 l-5 ${h * 0.24} h${w} l5 ${-h * 0.24} z`} fill={TINT} {...STROKE} />
      )}
      {tape && !open && (
        <>
          <path
            d={`M${w / 2 - 5} 0 l${d} ${-dy} h10 l${-d} ${dy} z`}
            fill={POP_SOFT}
            opacity={0.85}
          />
          <rect x={w / 2 - 5} width={10} height={h * 0.3} fill={POP_SOFT} opacity={0.85} />
        </>
      )}
      {label && (
        <g transform={at(w - lw - 6, h - lw - 6)}>
          <rect width={lw} height={lw} rx={1.5} fill={PAPER} stroke={INK} strokeWidth={1.25} />
          <MiniQr size={lw - 5} x={2.5} y={2.5} />
        </g>
      )}
    </g>
  );
}

/** Nine cells — enough to read as a QR code at thumbnail size. */
export function MiniQr({ x, y, size = 12 }: At & { size?: number }) {
  const c = size / 3;
  const on = [0, 2, 4, 6, 7];
  return (
    <g transform={at(x, y)}>
      {on.map((i) => (
        <rect
          key={i}
          x={(i % 3) * c}
          y={Math.floor(i / 3) * c}
          width={c * 0.82}
          height={c * 0.82}
          fill={INK}
        />
      ))}
    </g>
  );
}

/** The frame every drawing sits in: reserves the ratio, sets the scheme. */
export function Stage({
  children,
  ratio,
  dark = false,
  label,
  className = "",
}: {
  children: React.ReactNode;
  /** `width / height`, as a CSS aspect-ratio value: "4 / 3". */
  ratio: string;
  dark?: boolean;
  /**
   * What the picture shows, for screen readers and image search. Omit when
   * the copy beside it already says the same thing, and the drawing is then
   * hidden from assistive tech.
   */
  label?: string;
  className?: string;
}) {
  return (
    <div
      data-reveal="fade"
      style={{ aspectRatio: ratio }}
      className={`viz ${dark ? "viz-dark" : ""} relative w-full ${className}`}
      {...(label ? { role: "img", "aria-label": label } : { "aria-hidden": true })}
    >
      {children}
    </div>
  );
}
