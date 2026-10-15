import JsonLd from "@/components/JsonLd";
import { breadcrumbJsonLd } from "@/lib/seo";

// Metadata lives on page.tsx, which reads the live "from" price.

export default function LooseItemsLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Loose Items", path: "/loose-items" }])} />
      {children}
    </>
  );
}
