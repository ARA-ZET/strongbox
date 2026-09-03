import { OPTIONS, type ComparisonRow } from "@/lib/comparison";

/**
 * Four-column comparison, rendered two ways from one dataset.
 *
 * Above `md` it is a real `<table>`. Below it, a four-column table is
 * unreadable at any font size that is also legible, so each option becomes a
 * card listing every attribute — same content, same source of truth, no
 * horizontal scroll and no 9px text.
 *
 * The StrongBox column is tinted only on rows where `weWin` is true. Tinting
 * every row would be the thing the page is trying not to be.
 */
export default function ComparisonTable({ rows }: { rows: ComparisonRow[] }) {
  return (
    <>
      {/* ── Desktop: table ── */}
      <div className="hidden md:block overflow-x-auto rounded-xl border border-outline-variant bg-surface-white shadow-tactile">
        <table className="w-full border-collapse text-sm">
          <caption className="sr-only">
            StrongBox compared with self-storage, DIY storage and removal company storage
          </caption>
          <thead>
            <tr>
              <th scope="col" className="w-[18%] p-5 text-left align-bottom">
                <span className="sr-only">Attribute</span>
              </th>
              {OPTIONS.map((opt) => (
                <th
                  key={opt.id}
                  scope="col"
                  className={`p-5 text-left align-bottom ${
                    opt.isUs ? "bg-navy-deep text-surface-white rounded-t-xl" : ""
                  }`}
                >
                  <span
                    className={`block font-body-strong text-base ${
                      opt.isUs ? "text-surface-white" : "text-navy-deep"
                    }`}
                  >
                    {opt.label}
                  </span>
                  <span
                    className={`block text-xs mt-1 font-normal ${
                      opt.isUs ? "text-on-navy-variant" : "text-on-surface-variant"
                    }`}
                  >
                    {opt.blurb}
                  </span>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, i) => (
              <tr key={row.label} className={i % 2 === 1 ? "bg-mist" : ""}>
                <th scope="row" className="p-5 text-left align-top border-t border-outline-variant">
                  <span className="block font-body-strong text-navy-deep">{row.label}</span>
                  {row.detail && (
                    <span className="block text-xs text-on-surface-variant mt-1 font-normal">
                      {row.detail}
                    </span>
                  )}
                </th>
                {OPTIONS.map((opt) => {
                  const highlight = opt.isUs && row.weWin;
                  return (
                    <td
                      key={opt.id}
                      className={`p-5 align-top border-t border-outline-variant ${
                        opt.isUs
                          ? highlight
                            ? "bg-sky-tint text-navy-deep font-body-strong"
                            : "bg-sky-tint/40 text-navy-deep"
                          : "text-on-surface-variant"
                      }`}
                    >
                      {highlight && (
                        <span
                          aria-hidden="true"
                          className="material-symbols-outlined text-accent-deep text-base mr-1 align-text-bottom"
                        >
                          check_circle
                        </span>
                      )}
                      {row.values[opt.id]}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Mobile: one card per option ── */}
      <div className="md:hidden space-y-4">
        {OPTIONS.map((opt) => (
          <div
            key={opt.id}
            className={`rounded-xl overflow-hidden border ${
              opt.isUs ? "border-accent shadow-tactile-md" : "border-outline-variant"
            }`}
          >
            <div className={`p-5 ${opt.isUs ? "bg-navy-deep" : "bg-mist"}`}>
              <p
                className={`font-body-strong text-base ${
                  opt.isUs ? "text-surface-white" : "text-navy-deep"
                }`}
              >
                {opt.label}
              </p>
              <p
                className={`text-xs mt-1 ${
                  opt.isUs ? "text-on-navy-variant" : "text-on-surface-variant"
                }`}
              >
                {opt.blurb}
              </p>
            </div>
            <dl className="bg-surface-white divide-y divide-outline-variant">
              {rows.map((row) => (
                <div key={row.label} className="p-5">
                  <dt className="font-label-caps uppercase tracking-widest text-xs text-on-surface-variant mb-1">
                    {row.label}
                  </dt>
                  <dd
                    className={`text-sm ${
                      opt.isUs && row.weWin
                        ? "text-navy-deep font-body-strong"
                        : "text-on-surface-variant"
                    }`}
                  >
                    {row.values[opt.id]}
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        ))}
      </div>
    </>
  );
}
