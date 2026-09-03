import type { Config } from "tailwindcss";
import plugin from "tailwindcss/plugin";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        /* ── Navy family: dark grounds ── */
        "navy-deep": "#0a1a33",
        navy: "#0f2a52",
        "navy-soft": "#1b3e6f",

        /* ── Blue accent ──
         * `accent` is a fill colour: white on it is 4.77:1, so buttons pass
         * AA. As *text* it only clears AA on pure white — on `mist` it drops
         * to 4.45:1 — so links, prices and eyebrow labels on any light tint
         * use `accent-deep` (6.9:1 on white) instead.
         */
        accent: "#1d6fe0",
        "accent-deep": "#1557b5",
        /* Label colour on a solid `accent` fill. */
        "on-accent": "#ffffff",
        /* Icons and eyebrow labels on navy — 6.85:1 on `navy-deep`. */
        sky: "#5ea6f5",
        /* Icon wells, chips and quiet fills on white. */
        "sky-tint": "#e8f1fd",

        /* ── Surfaces ── */
        mist: "#f4f8fd",
        "surface-white": "#ffffff",
        "surface-container": "#e3ecf7",

        /* ── Text ── */
        "on-navy": "#dce9fa",
        "on-navy-variant": "#9fb8da",
        "on-surface": "#10203a",
        "on-surface-variant": "#4a5a72",

        outline: "#6b7f9c",
        "outline-variant": "#c3d2e6",
        error: "#ba1a1a",
        background: "#ffffff",
        surface: "#fcfdff",
      },
      borderRadius: {
        lg: "8px",
        xl: "12px",
        "2xl": "16px",
        "3xl": "24px",
        full: "9999px",
      },
      fontSize: {
        "display-bold": ["48px", { lineHeight: "1.1", letterSpacing: "-0.02em", fontWeight: "700" }],
        "headline-h1": ["36px", { lineHeight: "1.2", letterSpacing: "-0.01em", fontWeight: "700" }],
        "headline-h1-mobile": ["28px", { lineHeight: "1.2", fontWeight: "700" }],
        "headline-h2": ["28px", { lineHeight: "1.3", fontWeight: "600" }],
        "headline-h3": ["22px", { lineHeight: "1.4", fontWeight: "600" }],
        "body-main": ["16px", { lineHeight: "1.6", fontWeight: "400" }],
        "body-strong": ["16px", { lineHeight: "1.6", fontWeight: "600" }],
        "label-caps": ["12px", { lineHeight: "1", letterSpacing: "0.05em", fontWeight: "700" }],
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
      },
      maxWidth: {
        "container-max": "1200px",
        // The app bar deliberately overhangs the 1200px content column so the
        // navigation frames the page rather than sitting flush with it.
        "bar-max": "1440px",
      },
      spacing: {
        "margin-desktop": "48px",
        "margin-mobile": "16px",
        gutter: "24px",
      },
      boxShadow: {
        tactile: "0px 4px 20px rgba(10, 26, 51, 0.04)",
        "tactile-md": "0px 8px 30px rgba(10, 26, 51, 0.08)",
        "tactile-lg": "0px 10px 40px rgba(10, 26, 51, 0.08)",
      },
    },
  },
  plugins: [
    /*
     * `body-strong` and `label-caps` are weight-and-tracking styles, not sizes.
     * They live in `fontSize` above so `text-body-strong` renders the complete
     * type style, but the pages also reach for `font-body-strong` /
     * `font-label-caps` alongside an explicit size (`text-sm`, `text-xs`) when
     * they want the emphasis at a different scale. Those two class names have
     * no generated counterpart — `fontSize` keys only ever produce `text-*` —
     * so every one of those call sites silently rendered at regular weight.
     * Registering them here as weight-only utilities makes them behave as the
     * markup always assumed, without overriding the size sitting next to them.
     */
    plugin(({ addUtilities }) => {
      addUtilities({
        ".font-body-strong": { fontWeight: "600" },
        ".font-label-caps": { fontWeight: "700", letterSpacing: "0.05em" },
      });
    }),
  ],
};

export default config;
