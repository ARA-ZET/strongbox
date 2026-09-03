import type { MetadataRoute } from "next";
import { SITE_NAME } from "@/lib/seo";

/**
 * Installable-app metadata. Not a ranking factor on its own, but it is what
 * Lighthouse's PWA and "installable" checks read, and it controls how the
 * site looks when someone adds it to a phone home screen — which for a
 * service people re-open to book a collection is worth having.
 */
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: `${SITE_NAME} — Cape Town`,
    short_name: "StrongBox",
    description:
      "Valet storage in Cape Town. We collect your belongings, store them, and bring them back when you ask.",
    start_url: "/",
    display: "standalone",
    background_color: "#ffffff",
    theme_color: "#0a1a33",
    lang: "en-ZA",
    categories: ["business", "lifestyle", "utilities"],
    icons: [{ src: "/icon.svg", sizes: "any", type: "image/svg+xml" }],
  };
}
