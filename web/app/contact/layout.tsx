import type { Metadata } from "next";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
/*
 * The contact page is a client component (it owns form state), and a client
 * component cannot export `metadata`. Without this layout the page inherited
 * the site-wide default title and description, so it was indexed as a generic
 * StrongBox page rather than as the contact page.
 */
export const metadata: Metadata = pageMeta({
  title: "Contact Us",
  description:
    "Speak to StrongBox Valet Storage in Cape Town. Call, email, or send us a message — our concierge team replies within 2 business hours.",
  path: "/contact",
});

export default function ContactLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Contact", path: "/contact" }])} />
      {children}
    </>
  );
}
