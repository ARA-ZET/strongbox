import Link from "next/link";

/**
 * The visible trail that matches a page's `BreadcrumbList` markup.
 *
 * Google expects structured data to describe something a visitor can see;
 * the pages emitted the markup with no trail on screen. Pass the same array
 * given to `breadcrumbJsonLd` — Home is prepended here as it is there.
 */
export default function Breadcrumbs({
  trail,
  dark = false,
  className = "",
}: {
  trail: { name: string; path: string }[];
  dark?: boolean;
  className?: string;
}) {
  const items = [{ name: "Home", path: "/" }, ...trail];
  return (
    <nav aria-label="Breadcrumb" className={`mb-6 ${className}`}>
      <ol
        className={`flex flex-wrap items-center gap-x-2 gap-y-1 text-sm ${
          // On a photo hero the wash is lightest at the top, where this sits;
          // on-navy holds 4.5:1 there even over a white wall.
          dark ? "text-on-navy" : "text-on-surface-variant"
        }`}
      >
        {items.map((item, i) => {
          const last = i === items.length - 1;
          return (
            <li key={item.path} className="flex items-center gap-2">
              {last ? (
                <span aria-current="page" className={dark ? "font-medium text-surface-white" : "text-navy-deep"}>
                  {item.name}
                </span>
              ) : (
                <>
                  <Link
                    href={item.path}
                    className={`underline-offset-4 hover:underline ${
                      dark ? "hover:text-surface-white" : "hover:text-accent-deep"
                    }`}
                  >
                    {item.name}
                  </Link>
                  <span aria-hidden="true">/</span>
                </>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
