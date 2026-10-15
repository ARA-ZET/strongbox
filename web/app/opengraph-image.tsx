import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";
import { getPrices } from "@/lib/prices";

/*
 * The site-wide social card. `metadata.openGraph` pointed at `/og-image.jpg`,
 * which was never added to `public/` — so every link shared to WhatsApp,
 * Facebook or Slack unfurled with a broken image. Generating it here means the
 * card is always in sync with the brand and there is no binary to maintain.
 */
export const alt = "StrongBox — Cape Town's valet storage service";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

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

export default async function OpengraphImage() {
  const { boxFrom: BOX_FROM } = await getPrices();
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
            Valet Storage · Cape Town
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
            We collect it, store it, and bring it back.
          </div>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
          {["Monitored facility", "No lock-in", `From R${BOX_FROM}/mo`].map((chip) => (
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
    { ...size, fonts: await inter() }
  );
}
