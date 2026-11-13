import type { BoxType } from "@/lib/prices";
import { Carton, Stage, INK, LINE, PAPER, TINT, STROKE } from "./kit";

/**
 * The box sizes, side by side and to scale, next to a dining chair.
 *
 * "45 litres" means nothing to most people; a box that comes up to the seat
 * of a chair does. Sizes are read from the live price list, so a size added
 * or renamed in the app shows up here.
 *
 * Scale: each box is drawn as a cube of its stated volume, so the picture is
 * a fair comparison of capacity rather than a drawing of exact dimensions —
 * the caption on the page says so.
 */

/** Pixels per centimetre. The chair is 88cm to the top of its back. */
const PX = 1.55;
const BASE = 176;

/** "Small Box (45L)" → 45. Null when the label carries no litre figure. */
const litres = (label: string): number | null => {
  const m = label.match(/(\d+)\s*L\b/i);
  return m ? Number(m[1]) : null;
};

/** Edge of a cube holding `l` litres, in cm. */
const edge = (l: number) => Math.cbrt(l * 1000);

export function boxEdgesCm(boxes: readonly BoxType[]): number[] {
  let last = 30;
  return boxes.map(({ label }) => {
    const l = litres(label);
    // A size with no litre figure (the XL box) is drawn one step up from the
    // size before it, which is how it is sold: "the next one up".
    last = l ? edge(l) : last * 1.12;
    return last;
  });
}

export default function BoxScale({
  boxes,
  dark = false,
  className = "",
}: {
  boxes: readonly BoxType[];
  dark?: boolean;
  className?: string;
}) {
  const edges = boxEdgesCm(boxes);
  const gap = 26;
  let cursor = 118;
  const placed = edges.map((cm) => {
    const side = cm * PX;
    const x = cursor;
    cursor += side + side * 0.32 + gap;
    return { x, side };
  });
  const width = Math.max(520, cursor + 4);

  return (
    <Stage
      dark={dark}
      ratio={`${width} / 204`}
      label={`The ${boxes.length} StrongBox box sizes drawn to scale beside a dining chair, smallest to largest`}
      className={className}
    >
      <svg viewBox={`0 0 ${width} 204`} className="absolute inset-0 h-full w-full" fontFamily="inherit">
        {/* floor */}
        <path d={`M0 ${BASE} H${width}`} stroke={LINE} strokeWidth={2} />

        {/* the chair: 45cm seat, 88cm back */}
        <g transform={`translate(22 ${BASE - 88 * PX})`}>
          <path d={`M6 0 q-4 0 -4 4 v${88 * PX - 4}`} fill="none" {...STROKE} strokeWidth={5} />
          <rect x={4} y={10} width={10} height={44} rx={3} fill={TINT} {...STROKE} />
          <path d={`M2 ${43 * PX} h60 q4 0 4 4 v${45 * PX - 4}`} fill="none" {...STROKE} strokeWidth={5} />
          <rect x={0} y={43 * PX - 5} width={66} height={10} rx={4} fill={PAPER} {...STROKE} />
        </g>
        {/* seat-height rule, so the eye has something to measure against */}
        <path d={`M100 ${BASE - 45 * PX} H${width - 8}`} stroke={LINE} strokeWidth={1.5} strokeDasharray="3 6" />
        <text x={104} y={BASE - 45 * PX - 7} fontSize={13} fill={INK} opacity={0.65}>
          Seat height, 45cm
        </text>

        {placed.map(({ x, side }, i) => (
          <g key={boxes[i].id}>
            <Carton x={x} y={BASE - side} w={side} h={side} d={side * 0.32} />
            <text
              x={x + side / 2}
              y={BASE + 21}
              textAnchor="middle"
              fontSize={15}
              fontWeight={600}
              fill={INK}
            >
              {litres(boxes[i].label) ? `${litres(boxes[i].label)}L` : "XL"}
            </text>
          </g>
        ))}
      </svg>
    </Stage>
  );
}
