import type { MetadataRoute } from "next";
import { ARTICLES } from "@/lib/resources";
import { SITE_URL as BASE } from "@/lib/seo";

/**
 * Every public route, with the marketing pages ranked above the small print.
 * Keep in step with `components/Navbar.tsx` when a page is added; the guides
 * are generated from `lib/resources.ts` and need no edit here.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  const routes: [string, number, MetadataRoute.Sitemap[number]["changeFrequency"]][] = [
    ["", 1, "weekly"],
    ["/how-it-works", 0.9, "monthly"],
    ["/pricing", 0.9, "monthly"],
    ["/compare", 0.9, "monthly"],
    ["/loose-items", 0.8, "monthly"],
    ["/tools", 0.8, "monthly"],
    ["/tools/savings-calculator", 0.7, "monthly"],
    ["/resources", 0.7, "weekly"],
    ["/about", 0.6, "yearly"],
    ["/contact", 0.6, "yearly"],
    ["/privacy", 0.3, "yearly"],
    ["/terms", 0.3, "yearly"],
  ];

  return [
    ...routes.map(([path, priority, changeFrequency]) => ({
      url: `${BASE}${path}`,
      lastModified: now,
      changeFrequency,
      priority,
    })),
    // Guides carry their own `updated` date, which is more honest than
    // stamping every one of them with the build time.
    ...ARTICLES.map((article) => ({
      url: `${BASE}/resources/${article.slug}`,
      lastModified: new Date(article.updated),
      changeFrequency: "yearly" as const,
      priority: 0.6,
    })),
  ];
}
