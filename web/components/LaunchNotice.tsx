"use client";

import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import {
  APP_LAUNCH_LABEL,
  APP_LAUNCH_LABEL_SHORT,
  CONTACT_PHONE_DISPLAY,
  CONTACT_PHONE_HREF,
  WHATSAPP_HREF,
  daysUntilLaunch,
} from "@/lib/constants";

/**
 * "Our storage service will start from 1 December — N days to go", plus a
 * way to reach a person now. Visitors were already getting in touch before we
 * opened; this tells them when we do and that talking to us first is welcome,
 * so an early prospect is not lost. It names the storage service, not "the
 * app": customers read "app live" as a download date and were confused.
 *
 * The count is recomputed in the browser after mount: pages are cached, and a
 * number baked in at build time would drift. Once launch day arrives the
 * notice renders nothing.
 *
 * `tone` follows the ground it sits on; `compact` is the footer's one-liner,
 * which sits right under the phone number and so doesn't repeat it.
 *
 * The slim bar pinned under the navbar on every page is `LaunchBar`, below;
 * it defers to this full banner on the pages that carry one.
 */
export default function LaunchNotice({
  tone = "dark",
  compact = false,
  className = "",
}: {
  tone?: "dark" | "light";
  compact?: boolean;
  className?: string;
}) {
  const days = useDaysUntilLaunch();
  if (days <= 0) return null;

  const dark = tone === "dark";
  const countdown = `${days} ${days === 1 ? "day" : "days"} to go`;
  const link = dark
    ? "text-surface-white font-body-strong underline underline-offset-4 hover:text-sky"
    : "text-accent-deep font-body-strong underline underline-offset-4 hover:text-navy-deep";

  if (compact) {
    return (
      <p role="note" className={`text-sm text-on-navy-variant ${className}`}>
        <span className="flex items-center gap-2 text-surface-white font-body-strong">
          <span
            aria-hidden="true"
            className="material-symbols-outlined text-sky text-lg"
          >
            rocket_launch
          </span>
          {/* One wrapping text run, so the countdown flows after the date
              instead of being squeezed into its own column. */}
          <span>
            Storage service starts from{" "}
            <span className="whitespace-nowrap">{APP_LAUNCH_LABEL}</span>{" "}
            <span suppressHydrationWarning className="text-sky whitespace-nowrap">
              · {countdown}
            </span>
          </span>
        </span>
        <span className="block mt-1">
          Want to know how it works?{" "}
          <a href={CONTACT_PHONE_HREF} className={link}>
            Call
          </a>{" "}
          or{" "}
          <a
            href={WHATSAPP_HREF}
            target="_blank"
            rel="noopener noreferrer"
            className={link}
          >
            WhatsApp
          </a>{" "}
          us.
        </span>
      </p>
    );
  }

  return (
    <>
      <div
        data-launch-banner
        role="note"
        className={`grid gap-6 lg:gap-8 items-center lg:grid-cols-[auto_minmax(0,1fr)_auto] rounded-2xl border-2 p-6 md:p-8 ${
          dark
            ? "border-sky/40 bg-navy shadow-tactile-md"
            : "border-accent/30 bg-sky-tint"
        } ${className}`}
      >
        {/* The countdown is the first thing the eye lands on. */}
        <div className="flex lg:flex-col items-center justify-center gap-3 lg:gap-1 rounded-xl bg-accent text-on-accent px-6 py-4 lg:min-w-[140px] text-center">
          <span
            suppressHydrationWarning
            className="text-display-bold font-bold leading-none"
          >
            {days}
          </span>
          <span
            suppressHydrationWarning
            className="font-label-caps uppercase text-xs tracking-widest"
          >
            {days === 1 ? "day to go" : "days to go"}
          </span>
        </div>

        <div>
          <p
            className={`flex items-center gap-2 font-label-caps uppercase text-xs tracking-widest mb-2 ${
              dark ? "text-sky" : "text-accent-deep"
            }`}
          >
            <span
              aria-hidden="true"
              className="material-symbols-outlined text-lg"
            >
              rocket_launch
            </span>
            Launching soon
          </p>
          <p
            className={`text-headline-h3 md:text-headline-h2 font-bold mb-2 ${
              dark ? "text-surface-white" : "text-navy-deep"
            }`}
          >
            Our storage service will start from{" "}
            <span
              className={`whitespace-nowrap ${dark ? "text-sky" : "text-accent-deep"}`}
            >
              {APP_LAUNCH_LABEL}
            </span>
          </p>
          <p
            className={`text-body-main ${dark ? "text-on-navy" : "text-on-surface-variant"}`}
          >
            Want to understand how StrongBox works before then?{" "}
            <strong className={dark ? "text-surface-white" : "text-navy-deep"}>
              We&apos;re taking enquiries now
            </strong>{" "}
            — talk to us and we&apos;ll walk you through it.
          </p>
        </div>

        <div className="flex flex-col sm:flex-row lg:flex-col gap-3">
          <a
            href={CONTACT_PHONE_HREF}
            className="bg-accent text-on-accent h-[52px] px-6 rounded-xl font-body-strong flex items-center justify-center gap-2 hover:bg-accent-deep transition-colors whitespace-nowrap"
          >
            <span aria-hidden="true" className="material-symbols-outlined">
              call
            </span>
            Call {CONTACT_PHONE_DISPLAY}
          </a>
          <a
            href={WHATSAPP_HREF}
            target="_blank"
            rel="noopener noreferrer"
            className={`h-[52px] px-6 rounded-xl font-body-strong flex items-center justify-center gap-2 border-2 transition-colors whitespace-nowrap ${
              dark
                ? "border-surface-white/40 text-surface-white hover:bg-surface-white hover:text-navy-deep"
                : "border-accent-deep text-accent-deep hover:bg-accent-deep hover:text-on-accent"
            }`}
          >
            <span aria-hidden="true" className="material-symbols-outlined">
              chat
            </span>
            WhatsApp us
          </a>
        </div>
      </div>
    </>
  );
}

/** Days to launch, recomputed in the browser so a cached page isn't stale. */
function useDaysUntilLaunch() {
  const [days, setDays] = useState(() => daysUntilLaunch());
  useEffect(() => setDays(daysUntilLaunch()), []);
  return days;
}

/** The navbar is `fixed` at this height (components/Navbar.tsx). */
const NAVBAR_HEIGHT = 72;

/**
 * Pages that render the full `<LaunchNotice />` banner. Keep in step with
 * where it is used (app/page.tsx, app/contact/page.tsx). Known up front, not
 * discovered in the DOM, so the server renders the right layout and nothing
 * jumps on load.
 */
// The homepage used to carry the full banner inside its hero, where it pushed
// the headline below the fold on phones. It now shows the slim bar like every
// other page.
const FULL_BANNER_PATHS = new Set(["/contact"]);

/**
 * The slim launch bar pinned under the navbar on every page: date,
 * countdown, call and WhatsApp in one row. Rendered once, by the root layout.
 *
 * - On most pages it is always shown, and a spacer the bar's height sits in
 *   the flow so it covers nothing. globals.css adds its height to the
 *   anchor-scroll offset; sticky side columns sit at `lg:top-36` to clear it.
 * - On pages with the full banner it stays tucked behind the navbar until the
 *   banner has scrolled up out of view, so the two never show at once.
 *
 * It stays mounted and slides, so showing it never shifts the page;
 * `invisible` takes it out of the tab order while hidden.
 */
export function LaunchBar() {
  const days = useDaysUntilLaunch();
  const pathname = usePathname();
  const deferToBanner = FULL_BANNER_PATHS.has(pathname);

  // True once the full banner has scrolled up behind the navbar. Scrolling
  // *down* towards it (banner still below the viewport) does not count.
  const [scrolledPast, setScrolledPast] = useState(false);
  useEffect(() => {
    setScrolledPast(false);
    if (!deferToBanner) return;
    const banner = document.querySelector("[data-launch-banner]");
    if (!banner) return;
    const observer = new IntersectionObserver(
      ([entry]) =>
        setScrolledPast(
          !entry.isIntersecting && entry.boundingClientRect.top < NAVBAR_HEIGHT,
        ),
      { rootMargin: `-${NAVBAR_HEIGHT}px 0px 0px 0px` },
    );
    observer.observe(banner);
    return () => observer.disconnect();
  }, [pathname, deferToBanner, days]);

  if (days <= 0) return null;
  const visible = !deferToBanner || scrolledPast;

  return (
    <>
      {!deferToBanner && (
        <div aria-hidden="true" className="h-14 launch-bar-spacer" />
      )}
      <div
        data-launch-bar
        aria-hidden={!visible}
        className={`fixed top-[72px] inset-x-0 z-40 bg-navy-deep border-b-2 border-accent shadow-tactile-md transition-[transform,visibility] duration-300 motion-reduce:transition-none ${
          visible ? "translate-y-0" : "-translate-y-full invisible"
        }`}
      >
        <div className="max-w-container-max mx-auto px-5 sm:px-6 md:px-margin-desktop h-14 flex items-center gap-2 sm:gap-3">
          {/* The icon font sets its own `display`, so `hidden` goes on a wrapper. */}
          <span aria-hidden="true" className="hidden sm:flex shrink-0">
            <span className="material-symbols-outlined text-sky text-xl">
              rocket_launch
            </span>
          </span>
          <p className="flex-1 min-w-0 flex items-center gap-x-2 sm:gap-x-3 text-sm text-surface-white">
            {/* Below lg the full sentence doesn't fit beside the buttons, so
                it becomes two short lines (the bar is tall enough) and the
                date is never cut off. */}
            <span className="min-w-0 leading-tight lg:leading-normal lg:truncate">
              <span className="hidden lg:inline">
                Our storage service will start from{" "}
              </span>
              <span className="lg:hidden">Storage starts from</span>
              <strong className="text-sky block lg:inline">
                <span className="hidden sm:inline">{APP_LAUNCH_LABEL}</span>
                <span className="sm:hidden">{APP_LAUNCH_LABEL_SHORT}</span>
              </strong>
            </span>
            <span
              suppressHydrationWarning
              className="shrink-0 rounded-full bg-accent text-on-accent px-2.5 py-0.5 text-xs font-body-strong"
            >
              {days} {days === 1 ? "day" : "days"}
              <span className="hidden sm:inline"> to go</span>
            </span>
          </p>
          <a
            href={CONTACT_PHONE_HREF}
            aria-label={`Call ${CONTACT_PHONE_DISPLAY}`}
            className="shrink-0 bg-accent text-on-accent h-10 px-3 md:px-4 rounded-lg text-sm font-body-strong flex items-center gap-2 hover:bg-accent-deep transition-colors"
          >
            <span
              aria-hidden="true"
              className="material-symbols-outlined text-lg"
            >
              call
            </span>
            <span className="hidden md:inline whitespace-nowrap">
              Call {CONTACT_PHONE_DISPLAY}
            </span>
          </a>
          <a
            href={WHATSAPP_HREF}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="WhatsApp us"
            className="shrink-0 border border-surface-white/40 text-surface-white h-10 px-3 md:px-4 rounded-lg text-sm font-body-strong flex items-center gap-2 hover:bg-surface-white hover:text-navy-deep transition-colors"
          >
            <span
              aria-hidden="true"
              className="material-symbols-outlined text-lg"
            >
              chat
            </span>
            <span className="hidden md:inline whitespace-nowrap">WhatsApp</span>
          </a>
        </div>
      </div>
    </>
  );
}
