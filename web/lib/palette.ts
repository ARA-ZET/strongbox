/**
 * Brand colour tokens, mirrored from `tailwind.config.ts`.
 *
 * Tailwind classes cover everything an element can be styled with, but SVG
 * artwork needs the raw values for `fill` / `stroke` on individual paths.
 * Keep this in sync with the `colors` block in the Tailwind config.
 */
export const PALETTE = {
  /** Dark section ground, footer, calculator summary panels. */
  navyDeep: "#0a1a33",
  /** Cards and framed art sitting on `navyDeep`. */
  navy: "#0f2a52",
  /** Borders and hover states on a dark ground. */
  navySoft: "#1b3e6f",
  /**
   * The CTA blue. Used as a *fill* — white on it clears AA (4.77:1). As text
   * it only clears AA on pure white, so anything set on `mist` or another
   * tint reaches for `accentDeep` instead.
   */
  accent: "#1d6fe0",
  /** Links and emphasis text on light grounds; button hover. 6.9:1 on white. */
  accentDeep: "#1557b5",
  /** Icons and eyebrow labels on navy. 6.85:1 on `navyDeep`. */
  sky: "#5ea6f5",
  /** Icon wells, chips, quiet fills on white. */
  skyTint: "#e8f1fd",
  /** Alternating page section background. */
  mist: "#f4f8fd",
  white: "#ffffff",
  outlineVariant: "#c3d2e6",
} as const;

export type PaletteTone = keyof typeof PALETTE;
