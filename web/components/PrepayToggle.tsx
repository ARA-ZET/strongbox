"use client";

import { PREPAY_TIERS, type PrepayTier } from "@/lib/constants";

/**
 * Segmented control for the prepay term, shared by both calculators.
 *
 * Rendered as a radiogroup rather than a row of buttons: the four options are
 * one mutually exclusive choice, so arrow keys should move between them and a
 * screen reader should announce "2 of 4", which is what native radio inputs
 * give for free.
 *
 * `tone` exists because the control appears on both a white card (the pricing
 * page) and a navy summary panel (the calculators' right-hand column), and a
 * single palette cannot serve both.
 */
export default function PrepayToggle({
  value,
  onChange,
  tone = "light",
  name = "prepay-term",
  className = "",
}: {
  value: PrepayTier;
  onChange: (tier: PrepayTier) => void;
  tone?: "light" | "dark";
  /** Distinguishes the radio group when two toggles share a page. */
  name?: string;
  className?: string;
}) {
  const dark = tone === "dark";

  return (
    <div
      role="radiogroup"
      aria-label="Prepay term"
      className={`flex flex-wrap gap-1 rounded-xl p-1 ${
        dark ? "bg-surface-white/10" : "bg-mist border border-outline-variant"
      } ${className}`}
    >
      {PREPAY_TIERS.map((tier) => {
        const active = tier.id === value.id;
        return (
          <label
            key={tier.id}
            className={`flex-1 min-w-[72px] cursor-pointer rounded-lg px-3 py-2 text-center transition-colors ${
              active
                ? "bg-accent text-on-accent"
                : dark
                  ? "text-on-navy-variant hover:bg-surface-white/10"
                  : "text-navy-deep hover:bg-surface-container"
            }`}
          >
            <input
              type="radio"
              name={name}
              value={tier.id}
              checked={active}
              onChange={() => onChange(tier)}
              className="sr-only"
            />
            <span className="block text-sm font-body-strong whitespace-nowrap">{tier.label}</span>
            <span
              className={`block text-xs ${
                active ? "text-on-accent/80" : dark ? "text-on-navy-variant/70" : "text-on-surface-variant"
              }`}
            >
              {tier.note}
            </span>
          </label>
        );
      })}
    </div>
  );
}
