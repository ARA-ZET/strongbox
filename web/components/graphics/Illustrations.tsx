import { PALETTE } from "@/lib/palette";

/**
 * Line-art spot illustrations for the marketing site.
 *
 * These are the two pieces that sit on dark ground: the hero panel and the
 * CTA watermark, where the full-colour illustrations in `public/illustrations`
 * cannot go (their navy shapes vanish into a navy background). Everything on a
 * light section uses `Illustration` instead.
 *
 * All strokes use `currentColor`, so the surrounding element's text colour
 * drives the drawing — `text-navy-deep` on light sections, `text-sky`
 * on navy ones. The `accent` prop highlights one focal element (azure by default).
 */

type ArtProps = {
  className?: string;
  accent?: string;
  /**
   * The background the art sits on. Solid shapes are filled with it so nearer
   * objects occlude farther ones — without it the drawings read as overlapping
   * wireframes. Must match the surrounding panel's background colour.
   */
  surface?: string;
};

/**
 * Rough perceptual lightness of a `#rrggbb` colour, 0–1. Accent tints need to
 * be laid on far more heavily over a navy panel than over a white one to read
 * as the same blue; anything non-hex is treated as light.
 */
function lightness(hex: string): number {
  const match = /^#?([0-9a-f]{6})$/i.exec(hex);
  if (!match) return 1;
  const n = parseInt(match[1], 16);
  const r = (n >> 16) & 255;
  const g = (n >> 8) & 255;
  const b = n & 255;
  return (0.299 * r + 0.587 * g + 0.114 * b) / 255;
}

function Art({
  viewBox,
  className = "",
  children,
}: {
  viewBox: string;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <svg
      viewBox={viewBox}
      role="presentation"
      aria-hidden="true"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={`w-full h-auto ${className}`}
    >
      {children}
    </svg>
  );
}

/**
 * A carton in cabinet projection: front face, top face pushed back by `o`,
 * and the right side face. `accent` tints the box to mark it as the focal one.
 */
function Carton({
  x,
  y,
  w,
  h,
  o,
  accent,
  surface,
}: {
  x: number;
  y: number;
  w: number;
  h: number;
  o: number;
  accent?: string;
  surface: string;
}) {
  const front = `M${x} ${y} H${x + w} V${y + h} H${x} Z`;
  const top = `M${x} ${y} L${x + o} ${y - o} H${x + w + o} L${x + w} ${y} Z`;
  const side = `M${x + w} ${y} L${x + w + o} ${y - o} V${y + h - o} L${x + w} ${y + h} Z`;
  const dark = lightness(surface) < 0.5;

  return (
    <g>
      {/* Opaque base hides whatever this carton sits in front of */}
      <g stroke="none">
        <path d={front} fill={surface} />
        <path d={top} fill={surface} />
        <path d={side} fill={surface} />
        {accent && (
          <>
            <path d={top} fill={accent} opacity={dark ? 0.55 : 0.26} />
            <path d={side} fill={accent} opacity={dark ? 0.32 : 0.15} />
          </>
        )}
      </g>
      <path d={front} />
      <path d={top} />
      <path d={side} />
      {/* lid seam across the top face */}
      <path d={`M${x + w / 2} ${y} L${x + w / 2 + o} ${y - o}`} strokeWidth={1.5} />
      {/* packing tape down the front */}
      <path d={`M${x + w / 2} ${y} V${y + h}`} strokeWidth={1.5} strokeDasharray="7 7" />
    </g>
  );
}

/** Scannable label — the detail that says "tracked inventory", not "cardboard". */
function QrTag({
  x,
  y,
  size,
  accent,
  surface,
}: {
  x: number;
  y: number;
  size: number;
  accent: string;
  surface: string;
}) {
  const eye = size * 0.24;
  const pad = size * 0.14;
  return (
    <g strokeWidth={1.5}>
      <rect x={x} y={y} width={size} height={size} rx={4} fill={surface} />
      <rect x={x + pad} y={y + pad} width={eye} height={eye} />
      <rect x={x + size - pad - eye} y={y + pad} width={eye} height={eye} />
      <rect x={x + pad} y={y + size - pad - eye} width={eye} height={eye} />
      <path
        d={`M${x + size - pad - eye} ${y + size - pad - eye / 2} h${eye * 0.7} M${
          x + size - pad - eye
        } ${y + size - pad} h${eye}`}
        stroke={accent}
      />
    </g>
  );
}

/** Hero art: a tracked stack of cartons. */
export function StackedBoxesArt({
  className,
  accent = PALETTE.accent,
  surface = PALETTE.white,
}: ArtProps) {
  return (
    <Art viewBox="0 0 400 340" className={className}>
      {/* Drawn bottom-up so each carton occludes the one it rests on */}
      <Carton x={70} y={210} w={170} h={90} o={42} surface={surface} />
      <Carton x={92} y={124} w={130} h={68} o={34} accent={accent} surface={surface} />
      <Carton x={110} y={64} w={88} h={46} o={24} surface={surface} />
      <QrTag x={94} y={230} size={44} accent={accent} surface={surface} />
      {/* shine marks */}
      <g stroke={accent} strokeWidth={2}>
        <path d="M258 46 L272 32" />
        <path d="M276 66 L296 60" />
        <path d="M250 24 L254 8" />
      </g>
      <path d="M30 308 H370" strokeWidth={1.5} strokeDasharray="4 10" opacity={0.6} />
    </Art>
  );
}



/** Return delivery: the van on its way back to the client. */
export function DeliveryVanArt({
  className,
  accent = PALETTE.accent,
  surface = PALETTE.white,
}: ArtProps) {
  return (
    <Art viewBox="0 0 400 260" className={className}>
      {/* speed lines */}
      <g strokeWidth={1.8} opacity={0.7}>
        <path d="M12 108 H40" />
        <path d="M4 134 H32" />
        <path d="M16 160 H40" />
      </g>

      {/* cab (behind the cargo body at their shared edge) */}
      <path
        d="M248 112 H286 L322 150 H340 A10 10 0 0 1 350 160 V170 A8 8 0 0 1 342 178 H248 Z"
        fill={surface}
      />
      <path d="M291 122 H304 L326 146 H291 Z" strokeWidth={1.5} />

      {/* cargo body */}
      <rect x={112} y={78} width={26} height={10} rx={3} strokeWidth={1.5} fill={surface} />
      <rect x={52} y={88} width={196} height={90} rx={8} fill={surface} />
      <path d="M72 88 V178" strokeWidth={1.5} opacity={0.6} />

      {/* livery: a box mark on the side panel */}
      <g stroke={accent}>
        <rect x={96} y={110} width={62} height={50} rx={4} fill={accent} fillOpacity={0.16} />
        <path d="M96 126 H158" strokeWidth={1.5} />
        <path d="M127 110 V160" strokeWidth={1.5} strokeDasharray="6 6" />
      </g>

      {/* wheels */}
      <g>
        <circle cx={110} cy={196} r={18} fill={surface} />
        <circle cx={110} cy={196} r={7} fill={accent} stroke={accent} />
        <circle cx={300} cy={196} r={18} fill={surface} />
        <circle cx={300} cy={196} r={7} fill={accent} stroke={accent} />
      </g>

      <path d="M20 214 H380" strokeWidth={1.5} strokeDasharray="4 10" opacity={0.6} />
    </Art>
  );
}

