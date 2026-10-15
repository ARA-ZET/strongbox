import type { Metadata } from "next";

import { pageMeta } from "@/lib/seo";
import { getPrices } from "@/lib/prices";
import LooseItemsView from "./LooseItemsView";

export async function generateMetadata(): Promise<Metadata> {
  const { looseItemFrom } = await getPrices();
  return pageMeta({
    title: "Loose Item Storage — Furniture, Bikes & Oversized Items",
    description: `StrongBox stores more than boxes. Beds, desks, bicycles, surfboards and appliances, priced by the exact cubic metres they occupy. From R${looseItemFrom}/month in Cape Town.`,
    path: "/loose-items",
  });
}

export default async function LooseItemsPage() {
  const { looseItems, looseItemCategories } = await getPrices();
  return <LooseItemsView looseItems={looseItems} looseItemCategories={looseItemCategories} />;
}
