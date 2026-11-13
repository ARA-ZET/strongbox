import { FAQ_ITEMS } from "@/lib/constants";
import Section from "@/components/ui/Section";

/**
 * The questions people ask before booking.
 *
 * Built on <details>, not on React state. The previous version only put an
 * answer in the page once its question was clicked, so the answers named in
 * the FAQ structured data were not in the HTML a crawler receives — and the
 * whole block did nothing without JavaScript. Native disclosure keeps every
 * answer in the document, works with the keyboard for free, and needs no
 * client code.
 *
 * Pass `items` for a page with its own questions (e.g. `/mini-moves`), and
 * give `faqJsonLd` the same list so the markup matches what is on screen.
 */
export default function FAQAccordion({
  tone = "white",
  items = FAQ_ITEMS,
  title = "Questions people ask first",
  lead = "Insurance, turnaround, packing materials and the small print.",
}: {
  tone?: "white" | "mist";
  items?: readonly { q: string; a: string }[];
  title?: string;
  lead?: string;
}) {
  return (
    <Section tone={tone} id="faq">
      <div className="grid gap-10 lg:grid-cols-[minmax(0,5fr)_minmax(0,7fr)] lg:gap-16">
        <div data-reveal className="lg:sticky lg:top-36 lg:self-start">
          <h2 className="text-headline-h1 font-bold text-navy-deep">{title}</h2>
          <p className="mt-4 text-body-lead text-on-surface-variant">{lead}</p>
        </div>
        <div data-reveal className="divide-y divide-outline-variant border-y border-outline-variant">
          {items.map((item) => (
            <details key={item.q} className="group">
              <summary className="flex cursor-pointer list-none items-center justify-between gap-4 py-5 text-left [&::-webkit-details-marker]:hidden">
                <h3 className="text-[17px] font-semibold text-navy-deep group-hover:text-accent-deep">
                  {item.q}
                </h3>
                <span
                  aria-hidden="true"
                  className="material-symbols-outlined shrink-0 text-accent-deep transition-transform duration-200 group-open:rotate-45"
                >
                  add
                </span>
              </summary>
              <p className="max-w-2xl pb-6 text-body-main text-on-surface-variant">{item.a}</p>
            </details>
          ))}
        </div>
      </div>
    </Section>
  );
}
