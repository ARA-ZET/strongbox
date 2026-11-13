import { SOCIAL_CARD_SIZE, socialCard } from "@/lib/social-card";

/** The card a shared `/mini-moves` link unfurls with. */
export const alt = "StrongBox mini moves: small furniture moves across Cape Town";
export const size = SOCIAL_CARD_SIZE;
export const contentType = "image/png";

export default async function MiniMovesOpengraphImage() {
  return socialCard({
    eyebrow: "Mini Moves · Cape Town",
    headline: "Small moves across Cape Town, with storage if you need it.",
    chips: ["Home to home", "Into storage", "Or split the load"],
  });
}
