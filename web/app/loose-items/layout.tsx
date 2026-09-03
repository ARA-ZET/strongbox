import type { Metadata } from "next";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
/*
 * Client component below (category filtering owns state), so its metadata has
 * to live here — see `app/contact/layout.tsx` for the same reason.
 */
export const metadata: Metadata = pageMeta({
  title: "Loose Item Storage — Furniture, Bikes & Oversized Items",
  description:
    "StrongBox stores more than boxes. Beds, desks, bicycles, surfboards and appliances, priced by the exact cubic metres they occupy. From R75/month in Cape Town.",
  path: "/loose-items",
});

export default function LooseItemsLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Loose Items", path: "/loose-items" }])} />
      {children}
    </>
  );
}
