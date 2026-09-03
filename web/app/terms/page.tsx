import type { Metadata } from "next";
import LegalPage, { type LegalSection } from "@/components/LegalPage";
import { CONTACT_EMAIL } from "@/lib/constants";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "Terms of Service",
  description:
    "The terms on which StrongBox Valet Storage collects, stores, and returns your belongings in Cape Town.",
  path: "/terms",
});

const sections: LegalSection[] = [
  {
    heading: "The agreement",
    body: [
      "These terms apply when you book a collection with StrongBox Valet Storage. Placing a booking means you accept them.",
      "We may update these terms. If a change affects an active subscription we will give you 30 days' notice by email, and you may cancel within that period without penalty.",
    ],
  },
  {
    heading: "What we do",
    body: [
      "We collect your belongings from an address you nominate, catalogue and photograph them, store them at our facility, and return them to a nominated address when you request them.",
      "Each box and loose item is assigned a QR code. Your digital inventory shows what we hold and the condition it was in on collection.",
    ],
  },
  {
    heading: "Pricing and billing",
    body: [
      "Storage is billed monthly in advance, priced by the boxes and loose items you have with us. Collection and delivery are charged per trip at the rate quoted when you book.",
      "There is no minimum term and no lock-in. Cancel at any time and we will return your items within two business days of the final collection charge being settled.",
      "If an account falls more than 30 days past due we may suspend deliveries until it is brought current. We will contact you before taking any further step.",
    ],
  },
  {
    heading: "What we will not store",
    body: [
      "You may not give us: perishable food, live animals or plants, firearms or ammunition, explosives, flammable or corrosive substances, illegal items, or anything that gives off an odour or attracts pests.",
      "We ask that you do not give us cash, jewellery, or irreplaceable documents. If you do, they are held entirely at your own risk and most household policies will not cover them in storage.",
      "If we discover a prohibited item we will contact you to arrange its immediate return, and may charge for the trip.",
    ],
  },
  {
    heading: "Collection and delivery",
    body: [
      "We will confirm a time window in advance. Someone aged 18 or over must be present to hand over or receive items and to sign for them.",
      "If nobody is present within the agreed window, we may charge a failed-trip fee and rebook.",
      "Our drivers will carry items to and from your door. They will not dismantle furniture, remove doors, or carry items where doing so is unsafe.",
    ],
  },
  {
    heading: "Insurance",
    body: [
      "We are a storage and transport service, not an insurer, and we do not provide or sell cover on your goods. Items are stored at your risk and it is your responsibility to insure them.",
      "In South Africa this ordinarily falls under your household contents policy. Most insurers will extend cover to goods held off-site in storage once they are told where the items are; some require it to be noted on the policy in writing. Please confirm the position with your insurer or broker before collection.",
      "Every box is photographed and barcoded to your account at collection. That record is available to you at any time and is what an insurer will normally ask for in support of a claim.",
    ],
  },
  {
    heading: "Our liability",
    body: [
      "We take reasonable care of the items in our custody, and nothing in these terms limits our liability where the law does not permit it to be limited.",
      "We are not liable for damage arising from how you packed an item, for inherent deterioration of the item itself, or for loss you could have avoided by declaring a prohibited or high-value item.",
      "Claims must be raised within seven days of delivery. The photographic record taken at collection is the reference point for the condition an item was in when we received it.",
    ],
  },
  {
    heading: "Access to your items",
    body: [
      "You request items back through your account. Standard turnaround is next business day for requests placed before 12:00; same-day delivery is available at an additional charge where capacity allows.",
      "We do not offer walk-in access to the facility. Everything comes to you.",
    ],
  },
  {
    heading: "Ending the agreement",
    body: [
      "You may cancel at any time. We will arrange a final delivery of everything we hold; the standard delivery charge applies.",
      "We may end the agreement on 30 days' notice, or immediately if you store a prohibited item or an account remains unpaid after we have contacted you about it. In either case we will return your belongings.",
    ],
  },
  {
    heading: "Governing law",
    body: [
      "These terms are governed by the laws of the Republic of South Africa, and the courts of the Western Cape have jurisdiction over any dispute arising from them.",
      `Before going to court, please raise the issue with us at ${CONTACT_EMAIL} — most things are resolved faster that way.`,
    ],
  },
];

export default function TermsPage() {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Terms of Service", path: "/terms" }])} />
      <LegalPage
        title="Terms of Service"
        updated="20 August 2026"
        intro="Plain terms for a simple service: we collect your things, we look after them, and we bring them back when you ask. This page sets out what that means for both of us."
        sections={sections}
      />
    </>
  );
}
