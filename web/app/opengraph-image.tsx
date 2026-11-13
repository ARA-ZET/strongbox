import { getPrices } from "@/lib/prices";
import { SOCIAL_CARD_SIZE, socialCard } from "@/lib/social-card";

/*
 * The site-wide social card. `metadata.openGraph` pointed at `/og-image.jpg`,
 * which was never added to `public/` — so every link shared to WhatsApp,
 * Facebook or Slack unfurled with a broken image. Generating it here means the
 * card is always in sync with the brand and there is no binary to maintain.
 * The layout lives in `lib/social-card.tsx`, shared with per-page cards.
 */
export const alt = "StrongBox — Cape Town's valet storage service";
export const size = SOCIAL_CARD_SIZE;
export const contentType = "image/png";

export default async function OpengraphImage() {
  const { boxFrom } = await getPrices();
  return socialCard({
    eyebrow: "Valet Storage · Cape Town",
    headline: "We collect it, store it, and bring it back.",
    chips: ["Monitored facility", "No lock-in", `From R${boxFrom}/mo`],
  });
}
