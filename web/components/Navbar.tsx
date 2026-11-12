"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { APP_URL, CONTACT_PHONE_DISPLAY, CONTACT_PHONE_HREF, CONTACT_EMAIL_HREF } from "@/lib/constants";

/**
 * Desktop bar. Six is the ceiling this layout holds — the earlier set already
 * had to defer the nav to `lg`. Home is reachable from the logo, and Loose
 * Items now sits under Pricing and the tools hub, so both come out of the bar
 * and stay in the mobile drawer and the footer.
 */
const links = [
  { href: "/how-it-works", label: "How it works" },
  { href: "/pricing", label: "Pricing" },
  { href: "/compare", label: "Compare" },
  { href: "/tools", label: "Free tools" },
  { href: "/resources", label: "Guides" },
  { href: "/about", label: "About" },
];

/** Everything in the bar, plus what the bar could not fit. */
const mobileLinks = [
  { href: "/", label: "Home" },
  ...links,
  { href: "/loose-items", label: "Loose items" },
  { href: "/areas", label: "Areas we serve" },
  { href: "/contact", label: "Contact" },
];

export default function Navbar() {
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);

  // A new page means the menu's job is done, however the visitor got there.
  useEffect(() => setMobileOpen(false), [pathname]);

  /*
   * While the menu is open: Escape closes it, and the page behind it does not
   * scroll. Without the lock, a swipe on the menu scrolled the page underneath
   * and the menu stayed pinned over content the visitor could no longer see.
   */
  useEffect(() => {
    if (!mobileOpen) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setMobileOpen(false);
    document.addEventListener("keydown", onKey);
    const { overflow } = document.body.style;
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = overflow;
    };
  }, [mobileOpen]);

  /*
   * Prefix match, so `/resources/moving-out-checklist` still highlights
   * "Guides". `/` is excluded because every path is prefixed by it.
   */
  const isActive = (href: string) =>
    href === "/" ? pathname === "/" : pathname === href || pathname.startsWith(`${href}/`);

  return (
    <nav aria-label="Main" className="fixed top-0 w-full h-[72px] bg-surface-white shadow-tactile z-50">
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
            Log in
          </a>
          <a
            href={`${APP_URL}/register`}
            className="hidden lg:inline whitespace-nowrap bg-accent text-on-accent px-5 py-2.5 xl:px-6 xl:py-3 rounded-xl text-sm font-semibold xl:text-body-strong hover:bg-accent-deep transition-colors"
          >
            Get started
          </a>

          {/* Hamburger — everything below lg */}
          <button
            className="lg:hidden flex h-11 w-11 items-center justify-center -mr-2 text-navy-deep"
            onClick={() => setMobileOpen(!mobileOpen)}
            aria-expanded={mobileOpen}
            aria-controls="mobile-menu"
            aria-label={mobileOpen ? "Close menu" : "Open menu"}
          >
            <span className="material-symbols-outlined text-3xl">
              {mobileOpen ? "close" : "menu"}
            </span>
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div
          id="mobile-menu"
          className="lg:hidden absolute top-[72px] left-0 w-full max-h-[calc(100dvh-72px)] overflow-y-auto overscroll-contain bg-surface-white shadow-tactile-md z-50 border-t border-outline-variant/40"
        >
          <div className="max-w-bar-max mx-auto py-4 px-5 flex flex-col">
            {mobileLinks.map(({ href, label }) => (
              <Link
                key={href}
                href={href}
                onClick={() => setMobileOpen(false)}
                aria-current={isActive(href) ? "page" : undefined}
                className={`text-body-strong flex min-h-[48px] items-center border-b border-outline-variant/30 ${
                  isActive(href) ? "text-accent-deep" : "text-navy-deep"
                }`}
              >
                {label}
              </Link>
            ))}
            <div className="flex flex-col gap-3 pt-5">
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
                Email us
              </a>
              <a
                href={`${APP_URL}/login`}
                className="text-center border border-navy-deep/25 text-navy-deep py-3 rounded-xl font-body-strong"
              >
                Log in
              </a>
              <a
                href={`${APP_URL}/register`}
                className="text-center bg-accent text-on-accent py-3 rounded-xl font-body-strong"
              >
                Get started
              </a>
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
