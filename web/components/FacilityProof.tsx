import SitePhoto from "@/components/SitePhoto";

const POINTS = [
  {
    icon: "videocam",
    title: "Monitored around the clock",
    desc: "CCTV coverage and access control on every door into the storage floor.",
  },
  {
    icon: "thermostat",
    title: "Climate and humidity managed",
    desc: "Kept in the range that protects timber, textiles, paper, and electronics alike.",
  },
  {
    icon: "qr_code_2",
    title: "Barcoded to the shelf",
    desc: "Each box carries a QR code tied to your account, so retrieval is a scan, not a search.",
  },
];

/**
 * "Behind the scenes" — the proof band that answers the unspoken objection
 * ("where does my stuff actually go?") before the price is discussed.
 *
 * Lives on both the homepage and the about page, so `tone` swaps the ground
 * between the mist and white bands each page alternates.
 */
export default function FacilityProof({
  tone = "light",
  className = "",
}: {
  tone?: "light" | "mist";
  className?: string;
}) {
  return (
    <section
      className={`py-24 ${tone === "mist" ? "bg-mist" : "bg-surface-white"} ${className}`}
    >
      <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
        <div className="grid md:grid-cols-2 gap-16 items-center">
          <SitePhoto id="facility-racking" className="md:order-2 shadow-tactile" />
          <div className="md:order-1">
            <span className="font-label-caps text-accent-deep uppercase tracking-widest text-xs mb-4 block">
              Inside the Facility
            </span>
            <h2 className="text-headline-h1 font-bold text-navy-deep mb-6">
              Watched, racked, and accounted for
            </h2>
            <p className="text-on-surface-variant text-body-main mb-8">
              Every item that leaves your home is photographed, barcoded, and given a
              shelf position before the van doors close. From that moment its location is
              a matter of record rather than of memory.
            </p>
            <div className="space-y-5">
              {POINTS.map(({ icon, title, desc }) => (
                <div key={title} className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-lg bg-sky-tint flex items-center justify-center shrink-0">
                    <span className="material-symbols-outlined text-accent-deep">{icon}</span>
                  </div>
                  <div>
                    <h3 className="font-body-strong text-navy-deep">{title}</h3>
                    <p className="text-on-surface-variant text-sm">{desc}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
