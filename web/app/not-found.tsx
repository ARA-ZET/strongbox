import Link from "next/link";
import Illustration from "@/components/graphics/Illustration";
import type { Metadata } from "next";
import { CONTACT_EMAIL_HREF } from "@/lib/constants";

/*
 * A 404 body served under a mistyped URL is not a page anyone should land on
 * from search. The status code alone usually keeps it out, but the explicit
 * directive covers the case where it is reached through a soft redirect.
 */
export const metadata: Metadata = { robots: { index: false, follow: true } };

/*
 * A branded 404. Next's built-in one is an unstyled black-on-white line with
 * no navigation, which on a marketing site means a mistyped or stale link
 * dead-ends the visitor instead of routing them somewhere useful.
 */
export default function NotFound() {
  return (
    <section className="py-20 md:py-28 bg-mist min-h-[70vh] flex items-center">
      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-12 items-center">
        <div>
          <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
            Error 404
          </span>
          <h1 className="text-display-bold font-bold text-navy-deep mb-4">
            We couldn&apos;t find that one
          </h1>
          <p className="text-on-surface-variant text-body-main max-w-lg mb-8">
            The page you were after has moved or never existed. Everything we do store
            is accounted for — this just isn&apos;t one of those things.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 mb-10">
            <Link
              href="/"
              className="bg-accent text-on-accent h-[56px] px-8 rounded-xl font-body-strong flex items-center justify-center gap-2 hover:opacity-90 transition-all"
            >
              Back to Home
              <span className="material-symbols-outlined">arrow_forward</span>
            </Link>
            <Link
              href="/pricing#calculator"
              className="border-2 border-navy-deep text-navy-deep h-[56px] px-8 rounded-xl font-body-strong flex items-center justify-center hover:bg-surface-white transition-all"
            >
              Get a Quote
            </Link>
          </div>

          <div className="flex flex-wrap gap-x-6 gap-y-2 text-sm">
            {[
              { href: "/how-it-works", label: "How It Works" },
              { href: "/pricing", label: "Pricing" },
              { href: "/loose-items", label: "Loose Items" },
              { href: "/about", label: "About" },
            ].map(({ href, label }) => (
              <Link
                key={href}
                href={href}
                className="text-accent-deep font-body-strong hover:underline"
              >
                {label}
              </Link>
            ))}
            <a
              href={CONTACT_EMAIL_HREF}
              className="text-accent-deep font-body-strong hover:underline"
            >
              Email Us
            </a>
          </div>
        </div>

        <Illustration name="map-location" priority className="max-w-[320px] mx-auto" />
      </div>
    </section>
  );
}
