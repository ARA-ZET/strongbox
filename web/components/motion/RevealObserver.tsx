"use client";

import { usePathname } from "next/navigation";
import { useEffect } from "react";

/**
 * The site's only motion script.
 *
 * Any element may carry `data-reveal`; the first time it scrolls into view
 * this marks it `data-revealed`, and `globals.css` does the rest. Keeping it
 * to one observer in the root layout means pages and drawings stay server
 * components — they opt in with an attribute, not a client wrapper.
 *
 * It re-scans on every route change, because the App Router swaps the page
 * under a layout that does not remount.
 */
export default function RevealObserver() {
  const pathname = usePathname();

  useEffect(() => {
    const pending = document.querySelectorAll<HTMLElement>(
      "[data-reveal]:not([data-revealed])"
    );
    if (pending.length === 0) return;

    // No observer support, or the page is embedded in a frame (a preview, a
    // screenshot tool) where intersection with the real viewport is not a
    // reliable signal: show everything rather than risk leaving it hidden.
    if (!("IntersectionObserver" in window) || window.self !== window.top) {
      pending.forEach((el) => el.setAttribute("data-revealed", ""));
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          entry.target.setAttribute("data-revealed", "");
          observer.unobserve(entry.target);
        }
      },
      // Fire slightly before the element is fully in, so it has finished
      // arriving by the time the reader's eye gets to it.
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );

    pending.forEach((el) => observer.observe(el));
    return () => observer.disconnect();
  }, [pathname]);

  return null;
}
