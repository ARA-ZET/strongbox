import PhotoFeature from "@/components/PhotoFeature";
import IconPoint from "@/components/ui/IconPoint";
import Section from "@/components/ui/Section";

const POINTS = [
  {
    icon: "videocam",
    title: "Monitored around the clock",
    desc: "CCTV coverage and access control on every door into the storage floor.",
  },
  {
    icon: "thermostat",
    title: "Climate and humidity managed",
    desc: "Kept in the range that protects timber, textiles, paper and electronics alike.",
  },
  {
    icon: "qr_code_2",
    title: "Barcoded to the shelf",
    desc: "Each box carries a QR code tied to your account, so retrieval is a scan, not a search.",
  },
];

/**
 * Things a visitor can verify for themselves on their first collection.
 *
 * This sits where a row of testimonials used to. The service has not opened
 * for bookings yet, so there are no customers to quote; what we can offer
 * instead is a list of checks that do not depend on taking our word for it.
 */
const CHECKS = [
  { title: "A photo of every box", body: "Taken at your door and kept in your account." },
  { title: "A code on every box", body: "One QR label each. Scan it with your phone camera to see the record." },
  { title: "A signature at each handover", body: "Yours at collection, and yours again when it comes back." },
  { title: "A monthly invoice, itemised", body: "One line per box or item stored. No term, no notice period." },
];

/**
 * "Where does my stuff actually go?" — answered before the price is discussed.
 *
 * Lives on both the homepage and the about page, so `tone` swaps the ground
 * between the mist and white bands each page alternates.
 */
export default function FacilityProof({
  tone = "light",
  checks = true,
}: {
  tone?: "light" | "mist";
  /** The "check it yourself" strip under the photo. */
  checks?: boolean;
}) {
  return (
    <Section tone={tone === "mist" ? "mist" : "white"}>
      <div className="grid items-center gap-10 md:grid-cols-2 md:gap-16">
        <div data-reveal>
          <h2 className="text-headline-h1 font-bold text-navy-deep">
            Watched, racked and accounted for
          </h2>
          <p className="mt-4 text-body-lead text-on-surface-variant">
            Every item that leaves your home is photographed, barcoded and given a shelf
            position. From then on its location is a matter of record, not of memory.
          </p>
          <div className="mt-8 space-y-6">
            {POINTS.map(({ icon, title, desc }) => (
              <IconPoint key={title} icon={icon} title={title}>
                {desc}
              </IconPoint>
            ))}
          </div>
        </div>
        <PhotoFeature
          id="racking"
          sizes="(min-width: 1280px) 568px, (min-width: 768px) 46vw, 100vw"
          ratio="aspect-[4/3] md:aspect-[5/6]"
        >
          <div className="absolute inset-x-4 bottom-4 flex items-center gap-3 rounded-xl bg-surface-white/95 p-4 shadow-tactile sm:inset-x-auto sm:left-5 sm:bottom-5 sm:max-w-[300px]">
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-sky-tint">
              <span aria-hidden="true" className="material-symbols-outlined text-xl text-accent-deep">
                qr_code_scanner
              </span>
            </span>
            <p className="text-sm leading-snug text-navy-deep">
              <span className="font-semibold">Scanned in, shelved, recorded.</span> Its bay is on
              your account the moment it lands.
            </p>
          </div>
        </PhotoFeature>
      </div>

      {checks && (
        <div className="mt-14 md:mt-20">
          <h3 data-reveal className="text-headline-h3 font-semibold text-navy-deep">
            What you can check for yourself
          </h3>
          <dl className="mt-6 grid gap-x-8 gap-y-6 border-t border-outline-variant pt-6 sm:grid-cols-2 lg:grid-cols-4">
            {CHECKS.map(({ title, body }, i) => (
              <div key={title} data-reveal style={{ ["--i" as string]: i }}>
                <dt className="font-semibold text-navy-deep">{title}</dt>
                <dd className="mt-1.5 text-[15px] leading-relaxed text-on-surface-variant">{body}</dd>
              </div>
            ))}
          </dl>
        </div>
      )}
    </Section>
  );
}
