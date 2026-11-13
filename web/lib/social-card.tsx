import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

/**
 * The social card a shared link unfurls with — WhatsApp, Facebook, Slack.
 *
 * One layout for the site: wordmark, a small-caps line, the headline and a
 * row of chips. `app/opengraph-image.tsx` renders the site-wide card; a page
 * with its own audience (e.g. `/mini-moves`) adds an `opengraph-image.tsx`
 * to its segment that calls this with its own words, so a shared moves link
 * does not unfurl as the storage pitch.
 */
export const SOCIAL_CARD_SIZE = { width: 1200, height: 630 };

const NAVY_DEEP = "#0a1a33";
const NAVY = "#0f2a52";
const SKY = "#5ea6f5";
const ACCENT = "#1d6fe0";

/*
 * Inter is read from the repo rather than fetched at build time: the card
 * must render identically on any build host, including one without network
 * egress to fonts.gstatic.com. Without these the renderer falls back to its
 * built-in face, which carries no bold weight — the headline came out light.
 */
async function inter() {
  const dir = join(process.cwd(), "assets", "fonts");
  const [regular, bold] = await Promise.all([
    readFile(join(dir, "Inter-Regular.ttf")),
    readFile(join(dir, "Inter-Bold.ttf")),
  ]);
  return [
    { name: "Inter", data: regular, weight: 400 as const, style: "normal" as const },
    { name: "Inter", data: bold, weight: 700 as const, style: "normal" as const },
  ];
}

export async function socialCard({
  eyebrow,
  headline,
  chips,
}: {
  eyebrow: string;
  /** Two lines at most reads best; three still fits. */
  headline: string;
  chips: string[];
}) {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          background: NAVY_DEEP,
          padding: 72,
          fontFamily: "Inter",
        }}
      >
        {/* Wordmark */}
        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          <svg width="64" height="64" viewBox="0 0 64 64">
            <rect width="64" height="64" rx="14" fill={NAVY} />
            <path d="M14 26 H42 V48 H14 Z" fill={NAVY_DEEP} stroke={SKY} strokeWidth="2.5" />
            <path d="M14 26 L22 18 H50 L42 26 Z" fill={SKY} stroke={SKY} strokeWidth="2.5" />
            <path d="M42 26 L50 18 V40 L42 48 Z" fill={ACCENT} stroke={SKY} strokeWidth="2.5" />
            <path d="M28 26 V48" stroke={SKY} strokeWidth="2.5" />
          </svg>
          <div style={{ fontSize: 40, fontWeight: 700, color: "#ffffff" }}>StrongBox</div>
        </div>

        <div style={{ display: "flex", flexDirection: "column" }}>
          <div
            style={{
              fontSize: 26,
              letterSpacing: 4,
              textTransform: "uppercase",
              color: SKY,
              fontWeight: 700,
              marginBottom: 24,
            }}
          >
            {eyebrow}
          </div>
          <div
            style={{
              fontSize: 76,
              lineHeight: 1.1,
              fontWeight: 700,
              color: "#ffffff",
              maxWidth: 900,
            }}
          >
            {headline}
          </div>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          {chips.map((chip) => (
            <div
              key={chip}
              style={{
                display: "flex",
                fontSize: 26,
                color: "#ffffff",
                background: "rgba(255,255,255,0.10)",
                border: "1px solid rgba(255,255,255,0.18)",
                borderRadius: 999,
                padding: "12px 28px",
              }}
            >
              {chip}
            </div>
          ))}
        </div>
      </div>
    ),
    { ...SOCIAL_CARD_SIZE, fonts: await inter() }
  );
}
