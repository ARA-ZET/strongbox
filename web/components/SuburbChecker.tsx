"use client";

import Link from "next/link";
import { useId, useState } from "react";
import { SUBURB_INDEX, normaliseSuburb } from "@/lib/areas";
import { WHATSAPP_HREF } from "@/lib/constants";

/** More than this and the list stops helping; ask for another letter instead. */
const MAX_SUGGESTIONS = 6;

/**
 * "Do you come to my suburb?" — the first question almost every caller asks,
 * answered before they have to ask it.
 *
 * Matching is local (the suburb list is static data), so there is no loading
 * or error state. A miss is never presented as a "no": the list is the
 * suburbs we run to regularly, not the edge of the service, so an unlisted
 * suburb gets a one-tap WhatsApp question with the suburb already filled in.
 */
export default function SuburbChecker({ className = "" }: { className?: string }) {
  const [query, setQuery] = useState("");
  const inputId = useId();
  const resultId = useId();

  const q = normaliseSuburb(query);
  const matches = q
    ? SUBURB_INDEX.filter(({ suburb }) => normaliseSuburb(suburb).includes(q))
    : [];
  const exact = matches.find(({ suburb }) => normaliseSuburb(suburb) === q);
  const hit = exact ?? (matches.length === 1 ? matches[0] : undefined);

  const whatsappAsk = `${WHATSAPP_HREF}?text=${encodeURIComponent(
    `Hi StrongBox, do you collect from ${query.trim()}?`
  )}`;

  return (
    <div className={className}>
      <label htmlFor={inputId} className="block font-body-strong text-navy-deep mb-2">
        Which suburb are you in?
      </label>
      <div className="relative">
        <span
          aria-hidden="true"
          className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant"
        >
          search
        </span>
        <input
          id={inputId}
          type="text"
          inputMode="search"
          autoComplete="address-level3"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="e.g. Table View, Gugulethu, Kalk Bay"
          aria-describedby={resultId}
          className="w-full h-14 bg-surface-white border border-outline-variant rounded-xl pl-12 pr-4 text-navy-deep placeholder:text-on-surface-variant/60 focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all"
        />
      </div>

      {/* Fixed minimum height so the page below does not jump as results change. */}
      <div id={resultId} aria-live="polite" className="mt-3 min-h-[96px]">
        {!q ? (
          <p className="text-sm text-on-surface-variant pt-1">
            We collect from {Math.floor(SUBURB_INDEX.length / 10) * 10}+ suburbs across the
            metro. Type yours to check.
          </p>
        ) : hit ? (
          <div className="flex items-start gap-3 bg-surface-white border border-emerald-200 rounded-xl p-4">
            <span
              aria-hidden="true"
              className="material-symbols-outlined material-symbols-filled text-emerald-600 shrink-0"
            >
              check_circle
            </span>
            <div className="min-w-0">
              <p className="font-body-strong text-navy-deep">
                Yes, we collect from {hit.suburb}.
              </p>
              <p className="text-sm text-on-surface-variant mb-2">{hit.region.summary}</p>
              <Link
                href={`/areas/${hit.region.slug}`}
                className="text-sm text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
              >
                Storage {hit.region.where}
                <span aria-hidden="true" className="material-symbols-outlined text-sm">
                  arrow_forward
                </span>
              </Link>
            </div>
          </div>
        ) : matches.length > 0 ? (
          <div>
            <p className="text-sm text-on-surface-variant mb-2">
              {matches.length > MAX_SUGGESTIONS ? "Keep typing, or pick one:" : "Did you mean:"}
            </p>
            <ul className="flex flex-wrap gap-2">
              {matches.slice(0, MAX_SUGGESTIONS).map(({ suburb }) => (
                <li key={suburb}>
                  <button
                    type="button"
                    onClick={() => setQuery(suburb)}
                    className="bg-surface-white border border-outline-variant rounded-full px-4 py-2 min-h-[40px] text-sm text-navy-deep hover:border-accent-deep hover:text-accent-deep transition-colors"
                  >
                    {suburb}
                  </button>
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <div className="flex items-start gap-3 bg-surface-white border border-outline-variant rounded-xl p-4">
            <span aria-hidden="true" className="material-symbols-outlined text-accent-deep shrink-0">
              help
            </span>
            <div className="min-w-0">
              <p className="font-body-strong text-navy-deep break-words">
                &ldquo;{query.trim()}&rdquo; isn&apos;t on our list yet.
              </p>
              <p className="text-sm text-on-surface-variant mb-2">
                We cover the whole metro, so the answer is usually still yes. Ask us and
                we will confirm.
              </p>
              <a
                href={whatsappAsk}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
              >
                Ask on WhatsApp
                <span aria-hidden="true" className="material-symbols-outlined text-sm">
                  arrow_forward
                </span>
              </a>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
