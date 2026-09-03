import Link from "next/link";
import { CONTACT_EMAIL, CONTACT_EMAIL_HREF } from "@/lib/constants";

export type LegalSection = { heading: string; body: string[] };

/**
 * Shared frame for the policy pages. They are long-form prose rather than
 * marketing, so they get a single measured column and none of the site's
 * full-bleed section colour — the point is that they are readable, and that
 * a visitor checking the small print finds a real page instead of a 404.
 */
export default function LegalPage({
  title,
  updated,
  intro,
  sections,
}: {
  title: string;
  updated: string;
  intro: string;
  sections: LegalSection[];
}) {
  return (
    <>
      <section className="py-16 bg-navy-deep">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <Link
            href="/"
            className="inline-flex items-center gap-1 text-on-navy-variant hover:text-sky transition-colors text-sm font-body-strong mb-6"
          >
            <span className="material-symbols-outlined text-base">arrow_back</span>
            Back to StrongBox
          </Link>
          <h1 className="text-headline-h1 font-bold text-surface-white mb-3">{title}</h1>
          <p className="text-on-navy-variant text-sm">Last updated {updated}</p>
        </div>
      </section>

      <section className="py-16 bg-surface-white">
        <div className="max-w-3xl mx-auto px-6 md:px-margin-desktop">
          <p className="text-on-surface-variant text-body-main mb-12">{intro}</p>

          <div className="space-y-10">
            {sections.map(({ heading, body }, i) => (
              <div key={heading}>
                <h2 className="text-headline-h3 font-bold text-navy-deep mb-4">
                  <span className="text-accent-deep mr-2">{i + 1}.</span>
                  {heading}
                </h2>
                <div className="space-y-4">
                  {body.map((para) => (
                    <p key={para} className="text-on-surface-variant text-body-main">
                      {para}
                    </p>
                  ))}
                </div>
              </div>
            ))}
          </div>

          <div className="mt-14 bg-mist rounded-xl p-8">
            <h2 className="text-headline-h3 font-bold text-navy-deep mb-3">Questions?</h2>
            <p className="text-on-surface-variant text-body-main mb-4">
              If anything here is unclear, or you want to exercise a right described
              above, write to us and a person will answer.
            </p>
            <a
              href={CONTACT_EMAIL_HREF}
              className="inline-flex items-center gap-2 text-accent-deep font-body-strong hover:underline"
            >
              <span className="material-symbols-outlined text-lg">mail</span>
              {CONTACT_EMAIL}
            </a>
          </div>
        </div>
      </section>
    </>
  );
}
