/**
 * The label, and the record behind it.
 *
 * The chain-of-custody argument is abstract until you see the two halves
 * together: a code on the box, and the list of dated events that code has
 * collected. The events are the real ones the system writes — a scan at the
 * door, a signature, a scan into a bay, a scan out, a signature again.
 */

/** A 21×21 module pattern with the three finder squares a QR code has. */
function qrModules(): boolean[][] {
  const n = 21;
  const grid = Array.from({ length: n }, () => Array<boolean>(n).fill(false));
  // Deterministic filler — the same on the server and in the browser.
  let seed = 9942;
  const rand = () => {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  };
  for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) grid[y][x] = rand() > 0.52;

  const finder = (ox: number, oy: number) => {
    for (let y = -1; y <= 7; y++)
      for (let x = -1; x <= 7; x++) {
        const gx = ox + x;
        const gy = oy + y;
        if (gx < 0 || gy < 0 || gx >= n || gy >= n) continue;
        const ring = x === 0 || x === 6 || y === 0 || y === 6;
        const core = x >= 2 && x <= 4 && y >= 2 && y <= 4;
        const inside = x >= 0 && x <= 6 && y >= 0 && y <= 6;
        grid[gy][gx] = inside && (ring || core);
      }
  };
  finder(0, 0);
  finder(n - 7, 0);
  finder(0, n - 7);
  return grid;
}

const MODULES = qrModules();

export function QrLabel({ className = "" }: { className?: string }) {
  return (
    <div
      className={`relative w-full max-w-[250px] rounded-2xl bg-surface-white p-4 text-navy-deep shadow-tactile-lg ring-1 ring-navy-deep/10 ${className}`}
    >
      <div className="flex items-center gap-1.5 text-[13px] font-bold">
        <span className="material-symbols-outlined material-symbols-filled text-accent-deep !text-[18px]">package_2</span>
        StrongBox
      </div>
      <div className="relative mt-3 overflow-hidden rounded-lg">
        <svg viewBox="0 0 21 21" className="block w-full" shapeRendering="crispEdges">
          {MODULES.flatMap((row, y) =>
            row.map((on, x) => (on ? <rect key={`${x}-${y}`} x={x} y={y} width={1} height={1} className="fill-navy-deep" /> : null))
          )}
        </svg>
        {/* the scanner beam */}
        <span
          className="anim anim-scan pointer-events-none absolute inset-x-0 top-0 h-8 bg-gradient-to-b from-accent/0 via-accent/25 to-accent/60"
          style={{ ["--scan-travel" as string]: "186px" }}
        />
      </div>
      <p className="mt-3 text-center font-mono text-[15px] font-bold tracking-wider">SBX-9942-A1</p>
      <p className="text-center text-[11px] text-on-surface-variant">Winter bedding</p>
    </div>
  );
}

const EVENTS = [
  { icon: "qr_code_scanner", title: "Scanned at your door", meta: "Tue 8 Dec · 09:14 · 2 photos" },
  { icon: "draw", title: "Signed for at collection", meta: "Tue 8 Dec · 09:31" },
  { icon: "shelves", title: "Scanned into bay B-12", meta: "Tue 8 Dec · 11:02" },
  { icon: "local_shipping", title: "Scanned out for delivery", meta: "Mon 15 Mar · 08:20" },
  { icon: "task_alt", title: "Handed over and signed", meta: "Mon 15 Mar · 09:47 · 1 photo" },
];

export default function CustodyTrail({
  dark = false,
  className = "",
}: {
  dark?: boolean;
  className?: string;
}) {
  return (
    <div
      role="img"
      aria-label="A StrongBox QR label with the code SBX-9942-A1, beside the dated record of every scan and signature for that box"
      data-reveal
      className={`grid items-center gap-6 sm:grid-cols-[minmax(0,220px)_minmax(0,1fr)] ${className}`}
    >
      <QrLabel className="mx-auto" />
      <ol aria-hidden="true" className="relative">
        {EVENTS.map(({ icon, title, meta }, i) => (
          <li key={title} className="relative flex gap-3 pb-5 last:pb-0">
            {i < EVENTS.length - 1 && (
              <span className={`absolute left-[15px] top-8 h-[calc(100%-2rem)] w-px ${dark ? "bg-surface-white/20" : "bg-outline-variant"}`} />
            )}
            <span
              className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${
                dark ? "bg-surface-white/10 text-sky" : "bg-sky-tint text-accent-deep"
              }`}
            >
              <span className="material-symbols-outlined !text-[17px]">{icon}</span>
            </span>
            <span>
              <span className={`block text-sm font-semibold leading-snug ${dark ? "text-surface-white" : "text-navy-deep"}`}>
                {title}
              </span>
              <span className={`block text-xs ${dark ? "text-on-navy-variant" : "text-on-surface-variant"}`}>{meta}</span>
            </span>
          </li>
        ))}
      </ol>
    </div>
  );
}
