"use client";

import Link from "next/link";
import { useState } from "react";
import {
  CONTACT_PHONE_DISPLAY,
  CONTACT_PHONE_HREF,
  CONTACT_EMAIL,
  CONTACT_EMAIL_HREF,
  SOCIAL_LINKS,
} from "@/lib/constants";
import SocialIcon from "@/components/graphics/SocialIcon";
import { ARTICLES } from "@/lib/resources";

/**
 * Footer sitemap. Mirrors the shape of the site's four content surfaces —
 * the service, the tools, the comparison, the guides — so a visitor who
 * scrolls past the page they landed on can still find the rest.
 *
 * The guides column is generated from `lib/resources.ts`, so publishing an
 * article lists it here without a second edit.
 */
const COLUMNS: { heading: string; items: { href: string; label: string }[] }[] = [
  {
    heading: "Service",
    items: [
      { href: "/how-it-works", label: "How It Works" },
      { href: "/pricing", label: "Pricing" },
      { href: "/loose-items", label: "Loose Items" },
      { href: "/about", label: "About Us" },
    ],
  },
  {
    heading: "Free Tools",
    items: [
      { href: "/tools", label: "All Tools" },
      { href: "/tools/savings-calculator", label: "Cost Comparison" },
      { href: "/pricing#calculator", label: "Quote Builder" },
      { href: "/loose-items", label: "Loose Item Pricer" },
    ],
  },
  {
    heading: "Compare",
    items: [
      { href: "/compare", label: "All Options Compared" },
      { href: "/compare#table", label: "vs Self-Storage" },
      { href: "/resources/what-self-storage-really-costs", label: "What a Unit Really Costs" },
    ],
  },
  {
    heading: "Guides",
    items: [
      { href: "/resources", label: "All Guides" },
      ...ARTICLES.slice(0, 3).map((a) => ({ href: `/resources/${a.slug}`, label: a.title })),
    ],
  },
];

export default function Footer() {
  const [email, setEmail] = useState("");

  /*
   * There is no list backend yet, and a form that silently swallows the
   * address while flashing "subscribed" is worse than no form: the visitor
   * believes they signed up and never hears from us again. Handing the
   * address to the user's own mail client instead means the request actually
   * reaches a person. Swap this for the list provider's endpoint when one
   * exists — the markup does not need to change.
   */
  const subscribe = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;
    const subject = encodeURIComponent("Newsletter signup");
    const body = encodeURIComponent(`Please add ${email} to the StrongBox newsletter.`);
    window.location.href = `${CONTACT_EMAIL_HREF}?subject=${subject}&body=${body}`;
  };

  return (
    <footer className="bg-navy-deep border-t-4 border-accent w-full pt-16 pb-8">
      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-gutter mb-12">
        {/* Brand */}
        <div className="space-y-6">
          <div className="flex items-center gap-2 text-headline-h3 font-bold text-surface-white">
            <span className="material-symbols-outlined text-sky text-3xl material-symbols-filled">
              package_2
            </span>
            StrongBox
          </div>
          <p className="text-on-navy-variant text-body-main max-w-xs">
            Cape Town&apos;s premium valet storage solution. Secure, professional, and domestic-focused storage at your fingertips.
          </p>
          <div className="space-y-2">
            <a
              href={CONTACT_PHONE_HREF}
              className="flex items-center gap-2 text-surface-white hover:text-sky transition-colors text-sm font-body-strong"
            >
              <span className="material-symbols-outlined text-lg">call</span>
              {CONTACT_PHONE_DISPLAY}
            </a>
            <a
              href={CONTACT_EMAIL_HREF}
              className="flex items-center gap-2 text-surface-white hover:text-sky transition-colors text-sm font-body-strong"
            >
              <span className="material-symbols-outlined text-lg">mail</span>
              {CONTACT_EMAIL}
            </a>
          </div>
          <div className="flex gap-3">
            {SOCIAL_LINKS.filter((s) => s.href).map(({ platform, label, href }) => (
              <a
                key={platform}
                href={href}
                target="_blank"
                rel="noopener noreferrer"
                aria-label={label}
                title={label}
                className="w-10 h-10 rounded-lg bg-surface-white/10 flex items-center justify-center text-surface-white hover:bg-accent hover:text-on-accent transition-colors"
              >
                <SocialIcon platform={platform} />
              </a>
            ))}
          </div>
        </div>

        {/* Links */}
        <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-2 lg:grid-cols-4 gap-8 md:col-span-2 lg:col-span-2">
          {COLUMNS.map(({ heading, items }) => (
            <div key={heading}>
              <h4 className="text-surface-white font-body-strong mb-5 uppercase tracking-wider text-xs">
                {heading}
              </h4>
              <ul className="space-y-3">
                {items.map(({ href, label }) => (
                  <li key={href}>
                    <Link
                      href={href}
                      className="text-on-navy-variant hover:text-sky transition-colors text-body-main"
                    >
                      {label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Newsletter */}
        <div>
          <h4 className="text-surface-white font-body-strong mb-5 uppercase tracking-wider text-xs">
            Newsletter
          </h4>
          <p className="text-on-navy-variant text-sm mb-4">
            Get home organisation tips and seasonal offers.
          </p>
          <form className="flex gap-2" onSubmit={subscribe}>
            <label htmlFor="footer-newsletter-email" className="sr-only">
              Email address
            </label>
            <input
              id="footer-newsletter-email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Email address"
              className="bg-surface-white/10 border-0 rounded-lg px-4 py-3 flex-grow min-w-0 text-surface-white placeholder:text-on-navy-variant/70 focus:ring-2 focus:ring-sky outline-none text-sm"
            />
            <button
              type="submit"
              aria-label="Subscribe to the newsletter"
              className="bg-accent text-on-accent p-3 rounded-lg shrink-0 hover:opacity-90 transition-all"
            >
              <span className="material-symbols-outlined">send</span>
            </button>
          </form>
        </div>
      </div>

      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop pt-8 border-t border-surface-white/10 flex flex-col md:flex-row items-center justify-between gap-4">
        <p className="text-xs text-on-navy-variant/70 uppercase tracking-widest text-center md:text-left">
          © {new Date().getFullYear()} StrongBox Valet Storage. All rights reserved.
        </p>
        <ul className="flex flex-wrap justify-center gap-x-6 gap-y-2">
          {[
            { href: "/contact", label: "Contact" },
            { href: "/how-it-works#faq", label: "FAQ" },
            { href: "/privacy", label: "Privacy Policy" },
            { href: "/terms", label: "Terms of Service" },
          ].map(({ href, label }) => (
            <li key={href}>
              <Link
                href={href}
                className="text-xs text-on-navy-variant hover:text-sky transition-colors"
              >
                {label}
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </footer>
  );
}
