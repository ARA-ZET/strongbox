import type { Metadata } from "next";
import LegalPage, { type LegalSection } from "@/components/LegalPage";
import { CONTACT_EMAIL, HQ_ADDRESS_LINES } from "@/lib/constants";

import JsonLd from "@/components/JsonLd";
import { pageMeta, breadcrumbJsonLd } from "@/lib/seo";
export const metadata: Metadata = pageMeta({
  title: "Privacy Policy",
  description:
    "How StrongBox Valet Storage collects, uses, and protects your personal information under South Africa's POPIA.",
  path: "/privacy",
});

const sections: LegalSection[] = [
  {
    heading: "Who we are",
    body: [
      `StrongBox Valet Storage ("StrongBox", "we", "us") operates a collection, storage, and redelivery service in Cape Town, South Africa. Our registered address is ${HQ_ADDRESS_LINES.join(" ")}.`,
      "This policy explains what personal information we hold about you, why we hold it, and what you can ask us to do with it. It is written to meet our obligations under the Protection of Personal Information Act, 2013 (POPIA).",
    ],
  },
  {
    heading: "Information we collect",
    body: [
      "Account details you give us: your name, email address, phone number, and the collection and delivery addresses you ask us to serve.",
      "Inventory data: descriptions, dimensions, and photographs of the items you store, along with the QR code assigned to each box or loose item. Photographs are taken at collection so that both you and we have a record of the condition items arrived in.",
      "Service records: collection and delivery dates, the driver assigned to each job, your signature on handover, and any issue reports raised against a job.",
      "Billing data: your subscription tier and payment status. Card details are handled entirely by our payment processor and never reach StrongBox systems.",
      "Technical data: standard web server logs, and the device token used to send you push notifications if you install our app.",
    ],
  },
  {
    heading: "Why we use it",
    body: [
      "To perform the service you have contracted us for — collecting, cataloguing, storing, and returning your belongings.",
      "To tell you what is happening with your items: collection confirmations, delivery windows, and status changes.",
      "To bill you correctly and to keep the financial records the law requires us to keep.",
      "To investigate loss, damage, or a disputed handover, which is why photographic and signature records are kept for the life of the account.",
      "We do not sell your personal information, and we do not use your inventory photographs for marketing.",
    ],
  },
  {
    heading: "Who we share it with",
    body: [
      "Our drivers and operations staff see only the job data they need to complete a collection or delivery assigned to them.",
      "Our payment processor receives the information needed to take payment. Our cloud hosting and email providers process data on our instruction as operators under POPIA.",
      "We disclose information to a third party outside these cases only where the law requires it, or where you have asked us to.",
    ],
  },
  {
    heading: "How long we keep it",
    body: [
      "Inventory records, collection photographs, and signatures are kept for as long as you hold an account with us, and for five years after it closes — the period during which a claim about a stored item could still be brought.",
      "Billing records are kept for the period South African tax law requires.",
      "You can ask us to delete anything we are not legally obliged to retain.",
    ],
  },
  {
    heading: "Security",
    body: [
      "Our facility is access-controlled and monitored. Every box and loose item is barcoded so its location is known at all times.",
      "Data is held in encrypted cloud storage with access limited to staff who need it for their role. Access to client inventory is logged.",
      "If a breach affects your personal information, we will notify you and the Information Regulator as POPIA requires.",
    ],
  },
  {
    heading: "Your rights",
    body: [
      "You may ask us what personal information we hold about you and receive a copy of it.",
      "You may ask us to correct anything inaccurate, or to delete information we have no lawful reason to keep.",
      "You may object to receiving marketing messages at any time — every marketing email carries an unsubscribe link, and you can also just tell us.",
      `To exercise any of these rights, email ${CONTACT_EMAIL}. We will respond within 30 days. If you are not satisfied with our response, you may complain to the Information Regulator of South Africa.`,
    ],
  },
  {
    heading: "Cookies",
    body: [
      "This website uses only the cookies needed to make it work and to remember your preferences. We do not run third-party advertising trackers on it.",
    ],
  },
  {
    heading: "Changes to this policy",
    body: [
      "If we change how we handle your information we will update this page and change the date at the top. Material changes will also be sent to account holders by email.",
    ],
  },
];

export default function PrivacyPage() {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd([{ name: "Privacy Policy", path: "/privacy" }])} />
      <LegalPage
        title="Privacy Policy"
        updated="20 August 2026"
        intro="Your belongings are personal, and so is the information we hold in order to look after them. This page sets out exactly what we collect, why, and what you can ask us to do about it."
        sections={sections}
      />
    </>
  );
}
