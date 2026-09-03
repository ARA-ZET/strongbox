import Link from "next/link";
import Illustration from "@/components/graphics/Illustration";
import { formatUpdated, type Article } from "@/lib/resources";
import { APP_URL } from "@/lib/constants";

/**
 * The single rendering path for every guide in `lib/resources.ts`.
 *
 * Body text is capped at ~65ch rather than the page's 1200px column — a
 * full-width line of prose is unreadable, whatever the design system says
 * about container widths.
 */
export default function ArticleLayout({ article }: { article: Article }) {
  return (
    <>
      {/* Header */}
      <section className="py-16 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <nav aria-label="Breadcrumb" className="mb-6">
            <Link
              href="/resources"
              className="inline-flex items-center gap-1 text-accent-deep font-body-strong text-sm hover:underline"
            >
              <span className="material-symbols-outlined text-base">arrow_back</span>
              Guides
            </Link>
          </nav>
          <div className="grid md:grid-cols-[minmax(0,1fr)_auto] gap-10 items-center">
            <div>
              <div className="flex flex-wrap items-center gap-3 mb-4">
                <span className="bg-sky-tint text-accent-deep text-xs font-bold px-3 py-1 rounded-full">
                  {article.category}
                </span>
                <span className="text-xs text-on-surface-variant">
                  {article.readMinutes} min read · Updated {formatUpdated(article.updated)}
                </span>
              </div>
              <h1 className="text-display-bold font-bold text-navy-deep mb-5 max-w-3xl">
                {article.title}
              </h1>
              <p className="text-on-surface-variant text-lg max-w-[65ch]">{article.excerpt}</p>
            </div>
            <Illustration
              name={article.illustration}
              priority
              className="max-w-[260px] mx-auto hidden md:block"
            />
          </div>
        </div>
      </section>

      {/* Body */}
      <article className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="max-w-[65ch]">
            <p className="text-on-surface text-lg leading-relaxed mb-12">{article.intro}</p>

            {article.sections.map((section) => (
              <section key={section.heading} className="mb-12">
                <h2 className="text-headline-h2 font-bold text-navy-deep mb-4">
                  {section.heading}
                </h2>
                {section.paragraphs.map((p, i) => (
                  <p key={i} className="text-on-surface-variant text-body-main mb-4">
                    {p}
                  </p>
                ))}
                {section.list && (
                  <ul className="space-y-3 mt-5">
                    {section.list.map((item) => (
                      <li key={item} className="flex gap-3 text-on-surface-variant text-body-main">
                        <span
                          aria-hidden="true"
                          className="material-symbols-outlined text-accent-deep shrink-0 text-xl"
                        >
                          check_circle
                        </span>
                        {item}
                      </li>
                    ))}
                  </ul>
                )}
              </section>
            ))}

            {article.related && article.related.length > 0 && (
              <aside className="mt-14 bg-mist rounded-xl p-8 border border-outline-variant">
                <h2 className="text-headline-h3 font-bold text-navy-deep mb-4">Read next</h2>
                <ul className="space-y-3">
                  {article.related.map(({ href, label }) => (
                    <li key={href}>
                      <Link
                        href={href}
                        className="text-accent-deep font-body-strong hover:underline inline-flex items-center gap-1"
                      >
                        {label}
                        <span className="material-symbols-outlined text-sm">arrow_forward</span>
                      </Link>
                    </li>
                  ))}
                </ul>
              </aside>
            )}
          </div>
        </div>
      </article>

      {/* CTA */}
      <section className="py-20 bg-navy-deep text-center">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h1 font-bold text-surface-white mb-4">
            Need somewhere to put it?
          </h2>
          <p className="text-on-navy-variant mb-10 max-w-xl mx-auto">
            We collect from your door, store it, and bring it back when you ask. Priced
            per box, cancel anytime.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/pricing#calculator"
              className="bg-accent text-on-accent px-10 py-4 rounded-xl font-body-strong hover:bg-accent-deep transition-colors inline-flex items-center justify-center gap-2"
            >
              Get a free quote
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
            <a
              href={`${APP_URL}/register`}
              className="border-2 border-surface-white/30 text-surface-white px-10 py-4 rounded-xl font-body-strong hover:bg-surface-white/10 transition-all"
            >
              Get started
            </a>
          </div>
        </div>
      </section>
    </>
  );
}
