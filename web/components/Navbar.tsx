"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { APP_URL, CONTACT_PHONE_DISPLAY, CONTACT_PHONE_HREF, CONTACT_EMAIL_HREF } from "@/lib/constants";

/**
 * Desktop bar. Six is the ceiling this layout holds — the earlier set already
 * had to defer the nav to `lg`. Home is reachable from the logo, and Loose
 * Items now sits under Pricing and the tools hub, so both come out of the bar
 * and stay in the mobile drawer and the footer.
 */
const links = [
  { href: "/how-it-works", label: "How It Works" },
  { href: "/pricing", label: "Pricing" },
  { href: "/compare", label: "Compare" },
  { href: "/tools", label: "Free Tools" },
  { href: "/resources", label: "Guides" },
  { href: "/about", label: "About" },
];

/** Everything in the bar, plus what the bar could not fit. */
const mobileLinks = [
  { href: "/", label: "Home" },
  ...links,
  { href: "/loose-items", label: "Loose Items" },
  { href: "/contact", label: "Contact" },
];

export default function Navbar() {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);

  /*
   * Prefix match, so `/resources/moving-out-checklist` still highlights
   * "Guides". `/` is excluded because every path is prefixed by it.
   */
  const isActive = (href: string) =>
    href === "/" ? pathname === "/" : pathname === href || pathname.startsWith(`${href}/`);

  return (
    <nav className="fixed top-0 w-full h-[72px] bg-surface-white shadow-tactile z-50">
      {/*
        Three-column grid rather than justify-between. The nav column is sized
        to its content and the two 1fr side columns split the remainder evenly,
        which centres the links on the bar itself rather than merely between
        the logo and the actions (those two clusters are different widths). The
        container is 1440px against the page's 1200px content column, so the
        navigation overhangs the content on both sides.
      */}
      <div className="grid grid-cols-[1fr_auto_1fr] items-center gap-6 xl:gap-10 h-full max-w-bar-max mx-auto px-6 md:px-margin-desktop">
        {/* Logo */}
        {/*
          Each cluster is pinned to its column. Without an explicit col-start
          the hidden nav (display:none below lg) drops out of the grid and the
          actions auto-place into the middle column instead of the right one.
        */}
        <Link
          href="/"
          className="col-start-1 flex items-center gap-2 justify-self-start text-headline-h3 font-bold text-navy-deep"
        >
          <span className="material-symbols-outlined text-accent-deep text-3xl material-symbols-filled">
            package_2
          </span>
          StrongBox
        </Link>

        {/*
          Desktop nav appears at lg, not md: six links plus the action cluster
          overflow a 768–1023px bar, and they stay compact until xl so the
          centred column never collides with the logo or the CTA.
        */}
        <div className="col-start-2 hidden lg:flex justify-center gap-4 xl:gap-7 items-center min-w-0">
          {links.map(({ href, label }) => {
            const active = isActive(href);
            return (
              <Link
                key={href}
                href={href}
                aria-current={active ? "page" : undefined}
                className={`relative py-2 text-sm font-semibold xl:text-body-strong whitespace-nowrap transition-colors duration-200 ${
                  active ? "text-accent-deep" : "text-navy-deep hover:text-accent-deep"
                }`}
              >
                {label}
                {/* Absolute underline so active links don't change row height */}
                {active && (
                  <span className="absolute left-0 right-0 -bottom-0.5 h-0.5 rounded-full bg-accent-deep" />
                )}
              </Link>
            );
          })}
        </div>

        {/* Actions */}
        <div className="col-start-3 flex items-center justify-end gap-3 lg:gap-4">
          <a
            href={CONTACT_PHONE_HREF}
            className="hidden 2xl:flex items-center gap-1.5 whitespace-nowrap text-navy-deep hover:text-accent-deep transition-colors text-sm font-semibold"
          >
            <span className="material-symbols-outlined text-lg">call</span>
            {CONTACT_PHONE_DISPLAY}
          </a>
          <a
            href={`${APP_URL}/login`}
            className="hidden lg:inline whitespace-nowrap text-navy-deep text-sm font-semibold xl:text-body-strong hover:text-accent-deep transition-colors"
          >
            Log In
          </a>
          <a
            href={`${APP_URL}/register`}
            className="hidden lg:inline whitespace-nowrap bg-accent text-on-accent px-5 py-2.5 xl:px-6 xl:py-3 rounded-xl text-sm font-semibold xl:text-body-strong hover:opacity-90 active:scale-95 transition-all"
          >
            Get Started Free
          </a>

          {/* Hamburger — everything below lg */}
          <button
            className="lg:hidden p-2 -mr-2 text-navy-deep"
            onClick={() => setMobileOpen(!mobileOpen)}
            aria-expanded={mobileOpen}
            aria-label="Toggle menu"
          >
            <span className="material-symbols-outlined text-3xl">
              {mobileOpen ? "close" : "menu"}
            </span>
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="lg:hidden absolute top-[72px] left-0 w-full bg-surface-white shadow-tactile-md z-50">
          <div className="max-w-bar-max mx-auto py-6 px-6 flex flex-col gap-4">
            {mobileLinks.map(({ href, label }) => (
              <Link
                key={href}
                href={href}
                onClick={() => setMobileOpen(false)}
                className={`text-body-strong py-2 border-b border-outline-variant/30 ${
                  isActive(href) ? "text-accent-deep" : "text-navy-deep"
                }`}
              >
                {label}
              </Link>
            ))}
            <div className="flex flex-col gap-3 pt-2 border-t border-outline-variant/30 mt-2">
              <a
                href={CONTACT_PHONE_HREF}
                className="flex items-center justify-center gap-2 text-navy-deep py-2 font-body-strong"
              >
                <span className="material-symbols-outlined text-lg">call</span>
                {CONTACT_PHONE_DISPLAY}
              </a>
              <a
                href={CONTACT_EMAIL_HREF}
                className="flex items-center justify-center gap-2 text-navy-deep py-2 font-body-strong"
              >
                <span className="material-symbols-outlined text-lg">mail</span>
                Email Us
              </a>
              <a
                href={`${APP_URL}/login`}
                className="text-center border border-navy-deep text-navy-deep py-3 rounded-xl font-body-strong"
              >
                Log In
              </a>
              <a
                href={`${APP_URL}/register`}
                className="text-center bg-accent text-on-accent py-3 rounded-xl font-body-strong"
              >
                Get Started Free
              </a>
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
