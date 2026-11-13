import Button from "@/components/ui/Button";
import Section from "@/components/ui/Section";
import { APP_URL } from "@/lib/constants";

/**
 * The band that closes a page.
 *
 * Every page ended on its own hand-built call to action — nine layouts, eight
 * button labels. The site now has two actions, named the same everywhere:
 * "Get a quote" (the calculator) and "Get started" (the app).
 */
export default function ClosingCta({
  title,
  body,
  tone = "mist",
  secondary = { href: `${APP_URL}/register`, label: "Get started" },
  primary = { href: "/pricing#calculator", label: "Get a quote" },
}: {
  title: string;
  body: string;
  /** The ground the panel sits on — match the band above the footer. */
  tone?: "mist" | "white";
  primary?: { href: string; label: string };
  secondary?: { href: string; label: string } | null;
}) {
  return (
    <Section tone={tone} space="sm">
      <div
        data-reveal
        className="on-dark flex flex-col gap-8 rounded-2xl bg-navy-deep px-6 py-10 sm:px-10 md:flex-row md:items-center md:justify-between md:px-14 md:py-14"
      >
        <div className="max-w-xl">
          <h2 className="text-headline-h1 font-bold text-surface-white">{title}</h2>
          <p className="mt-3 text-body-lead text-on-navy">{body}</p>
        </div>
        <div className="flex shrink-0 flex-col gap-3 sm:flex-row">
          <Button href={primary.href} arrow>
            {primary.label}
          </Button>
          {secondary && (
            <Button href={secondary.href} variant="on-dark">
              {secondary.label}
            </Button>
          )}
        </div>
      </div>
    </Section>
  );
}
