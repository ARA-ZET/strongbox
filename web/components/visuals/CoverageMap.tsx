import Link from "next/link";
import { REGIONS } from "@/lib/areas";
import { HQ_GEO, HQ_SUBURB } from "@/lib/constants";

/**
 * Where we go, on a map of the metro.
 *
 * A schematic, not a survey: the coastline is a few dozen hand-placed points,
 * enough to make the Peninsula, Table Bay and False Bay recognisable. What is
 * accurate is the placing — each region's marker and the facility are
 * projected from real coordinates, so their positions relative to one another
 * are right.
 *
 * Markers are numbered rather than labelled. The regions crowd together
 * around the city and nine names will not fit there at phone size; the
 * numbers match the list `RegionList` renders beside the map.
 */

/** Rough centre of each region, [lng, lat]. Keyed by slug in `lib/areas.ts`. */
const CENTRES: Record<string, [number, number]> = {
  "atlantic-seaboard": [18.378, -33.925],
  "city-bowl": [18.418, -33.932],
  "southern-suburbs": [18.468, -33.99],
  "south-peninsula": [18.43, -34.125],
  "northern-suburbs": [18.64, -33.875],
  "blouberg-west-coast": [18.495, -33.79],
  "cape-flats": [18.545, -33.985],
  "mitchells-plain-khayelitsha": [18.645, -34.04],
  helderberg: [18.845, -34.085],
};

/** The land, clockwise from the north-west: west coast, Peninsula, False Bay. */
const COAST: [number, number][] = [
  [18.26, -33.4],
  [18.36, -33.58],
  [18.41, -33.66],
  [18.44, -33.73],
  [18.462, -33.8],
  [18.482, -33.85],
  [18.478, -33.885],
  [18.45, -33.905],
  [18.425, -33.902],
  [18.4, -33.898],
  [18.382, -33.915],
  [18.374, -33.94],
  [18.376, -33.958],
  [18.352, -33.985],
  [18.338, -34.01],
  [18.348, -34.04],
  [18.362, -34.05],
  [18.348, -34.07],
  [18.352, -34.1],
  [18.33, -34.14],
  [18.345, -34.17],
  [18.375, -34.205],
  [18.41, -34.26],
  [18.455, -34.32],
  [18.495, -34.357],
  [18.478, -34.3],
  [18.462, -34.24],
  [18.436, -34.195],
  [18.438, -34.14],
  [18.47, -34.108],
  [18.56, -34.086],
  [18.63, -34.076],
  [18.7, -34.073],
  [18.765, -34.078],
  [18.83, -34.115],
  [18.866, -34.16],
  [18.845, -34.21],
  [18.84, -34.27],
  [18.83, -34.4],
  [18.96, -34.4],
  [18.96, -33.4],
];

/* Projection. One degree of longitude at 34°S is about 0.83 of a degree of
 * latitude on the ground, so the two axes take different scales. */
const W = 360;
const LNG = [18.27, 18.93] as const;
const LAT = [-33.63, -34.39] as const;
const KX = W / (LNG[1] - LNG[0]);
const KY = KX / Math.cos((34 * Math.PI) / 180);
const H = Math.round((LAT[0] - LAT[1]) * KY);

const px = ([lng, lat]: readonly [number, number]): [number, number] => [
  Math.round((lng - LNG[0]) * KX * 10) / 10,
  Math.round((LAT[0] - lat) * KY * 10) / 10,
];

/** A closed path through the points, corners eased so it reads as a coast. */
function smooth(points: [number, number][]): string {
  const p = points.map(px);
  const mid = (a: [number, number], b: [number, number]) => [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
  const first = mid(p[p.length - 1], p[0]);
  let d = `M${first[0]} ${first[1]}`;
  for (let i = 0; i < p.length; i++) {
    const m = mid(p[i], p[(i + 1) % p.length]);
    d += ` Q${p[i][0]} ${p[i][1]} ${m[0]} ${m[1]}`;
  }
  return `${d} Z`;
}

const LAND = smooth(COAST);
const HQ = px([HQ_GEO.lng, HQ_GEO.lat]);

export default function CoverageMap({
  active,
  dark = false,
  className = "",
}: {
  /** Region slug to pick out — on that region's own page. */
  active?: string;
  dark?: boolean;
  className?: string;
}) {
  return (
    <div
      data-reveal="fade"
      className={`viz ${dark ? "viz-dark" : ""} relative mx-auto w-full max-w-[380px] ${className}`}
    >
      <svg
        viewBox={`0 0 ${W} ${H}`}
        className="block h-auto w-full rounded-[20px] ring-1 ring-outline-variant"
        role="img"
        aria-label={`Schematic map of Cape Town showing the ${REGIONS.length} regions StrongBox collects from and the facility in ${HQ_SUBURB}`}
        fontFamily="inherit"
      >
        <defs>
          <clipPath id="map-frame">
            <rect width={W} height={H} rx={20} />
          </clipPath>
        </defs>
        <g clipPath="url(#map-frame)">
          {/* sea */}
          <rect width={W} height={H} fill="var(--tint)" />
          {/* land */}
          <path d={LAND} fill="var(--paper)" stroke="var(--line)" strokeWidth={2} strokeLinejoin="round" />

          {/* a line from the facility to every region: one hub, whole metro */}
          {REGIONS.map((r) => {
            const c = CENTRES[r.slug];
            if (!c) return null;
            const [x, y] = px(c);
            return (
              <path
                key={r.slug}
                d={`M${HQ[0]} ${HQ[1]} L${x} ${y}`}
                stroke="var(--pop)"
                strokeWidth={r.slug === active ? 2.5 : 1.5}
                strokeDasharray="2 7"
                strokeLinecap="round"
                opacity={active && r.slug !== active ? 0.3 : 0.75}
                className="anim anim-route"
              />
            );
          })}

          {/* sea names, set quietly */}
          <text x={28} y={H * 0.2} fontSize={10} fill="var(--ink)" opacity={0.45} letterSpacing={2}>
            TABLE BAY
          </text>
          <text x={W * 0.5} y={H * 0.74} fontSize={10} fill="var(--ink)" opacity={0.45} letterSpacing={2}>
            FALSE BAY
          </text>
        </g>

        {/* the facility */}
        <g>
          <circle cx={HQ[0]} cy={HQ[1]} r={9} fill="var(--pop)" opacity={0.5} className="anim anim-halo" />
          <rect x={HQ[0] - 8} y={HQ[1] - 8} width={16} height={16} rx={4} fill="var(--ink)" />
          <path
            d={`M${HQ[0] - 4} ${HQ[1] - 1.5} l4 -2 l4 2 v5 l-4 2 l-4 -2 z`}
            fill="none"
            stroke="var(--paper)"
            strokeWidth={1.4}
            strokeLinejoin="round"
          />
        </g>

        {/* the regions */}
        {REGIONS.map((r, i) => {
          const c = CENTRES[r.slug];
          if (!c) return null;
          const [x, y] = px(c);
          const on = r.slug === active;
          return (
            <Link key={r.slug} href={`/areas/${r.slug}`} aria-label={`Storage ${r.where}`}>
              {/* a hit area a thumb can find */}
              <circle cx={x} cy={y} r={18} fill="transparent" />
              <circle
                cx={x}
                cy={y}
                r={on ? 13 : 11}
                fill={on ? "var(--pop)" : "var(--paper)"}
                stroke={on ? "var(--pop)" : "var(--ink)"}
                strokeWidth={2}
              />
              <text
                x={x}
                y={y + 4}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={on ? "var(--paper)" : "var(--ink)"}
              >
                {i + 1}
              </text>
            </Link>
          );
        })}
      </svg>
      <p className={`mt-3 flex items-center gap-2 text-xs ${dark ? "text-on-navy-variant" : "text-on-surface-variant"}`}>
        <span className="inline-block h-3 w-3 rounded-[3px] bg-navy-deep" aria-hidden="true" />
        Our facility, {HQ_SUBURB}. Map is schematic, not to survey.
      </p>
    </div>
  );
}

/**
 * The numbered list that goes with the map. Rendered separately so each page
 * can place it where its layout wants it.
 */
export function RegionList({
  active,
  className = "",
}: {
  active?: string;
  className?: string;
}) {
  return (
    <ol className={`divide-y divide-outline-variant/70 border-y border-outline-variant/70 ${className}`}>
      {REGIONS.map((r, i) => {
        const on = r.slug === active;
        return (
          <li key={r.slug}>
            <Link
              href={`/areas/${r.slug}`}
              aria-current={on ? "page" : undefined}
              className="group flex min-h-[52px] items-center gap-3.5 py-2.5"
            >
              <span
                className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-full border-2 text-xs font-bold ${
                  on
                    ? "border-accent bg-accent text-on-accent"
                    : "border-navy-deep text-navy-deep group-hover:border-accent-deep group-hover:text-accent-deep"
                }`}
              >
                {i + 1}
              </span>
              <span className="min-w-0 flex-1">
                <span className="block font-semibold text-navy-deep group-hover:text-accent-deep">{r.name}</span>
                <span className="block truncate text-sm text-on-surface-variant">{r.summary}</span>
              </span>
              <span aria-hidden="true" className="material-symbols-outlined text-accent-deep text-xl transition-transform group-hover:translate-x-1">
                arrow_forward
              </span>
            </Link>
          </li>
        );
      })}
    </ol>
  );
}
