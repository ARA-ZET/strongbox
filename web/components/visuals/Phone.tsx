/**
 * The client app, drawn in HTML.
 *
 * These are not screenshots — the app's own screens will change, and a stale
 * screenshot is worse than none. They are redrawn here from the real client
 * portal: the same tabs (Home, My Storage, Orders, Billing, Account), the same
 * status wording the app shows (`client_orders.dart`), the same SBX- codes.
 * If the app's wording changes, change it here too.
 */

const TABS = [
  { icon: "home", label: "Home" },
  { icon: "inventory_2", label: "Storage" },
  { icon: "local_shipping", label: "Orders" },
  { icon: "receipt_long", label: "Billing" },
];

export function PhoneFrame({
  children,
  activeTab,
  label,
  className = "",
}: {
  children: React.ReactNode;
  activeTab: string;
  /** What the screen shows, for screen readers. */
  label: string;
  className?: string;
}) {
  return (
    <div
      role="img"
      aria-label={label}
      data-reveal
      className={`relative mx-auto w-full max-w-[272px] rounded-[2.25rem] bg-navy-deep p-[7px] shadow-tactile-lg ring-1 ring-navy-deep/10 ${className}`}
    >
      <div aria-hidden="true" className="flex aspect-[9/18] flex-col overflow-hidden rounded-[1.85rem] bg-mist text-navy-deep">
        {/* status bar */}
        <div className="flex items-center justify-between bg-surface-white px-5 pt-2.5 pb-1 text-[10px] font-semibold">
          <span>9:41</span>
          <span className="h-[14px] w-14 rounded-full bg-navy-deep" />
          <span className="material-symbols-outlined material-symbols-filled !text-[13px]">signal_cellular_alt</span>
        </div>
        <div className="flex-1 overflow-hidden">{children}</div>
        {/* tab bar */}
        <div className="grid grid-cols-4 border-t border-outline-variant/60 bg-surface-white px-1 pt-1.5 pb-2">
          {TABS.map(({ icon, label: tab }) => {
            const active = tab === activeTab;
            return (
              <div key={tab} className="flex flex-col items-center gap-0.5">
                <span
                  className={`flex h-6 w-11 items-center justify-center rounded-full ${active ? "bg-sky-tint" : ""}`}
                >
                  <span
                    className={`material-symbols-outlined !text-[17px] ${
                      active ? "material-symbols-filled text-accent-deep" : "text-on-surface-variant"
                    }`}
                  >
                    {icon}
                  </span>
                </span>
                <span className={`text-[9px] ${active ? "font-semibold text-navy-deep" : "text-on-surface-variant"}`}>
                  {tab}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

const CHIP = {
  stored: "bg-emerald-100 text-emerald-800",
  moving: "bg-amber-100 text-amber-800",
  waiting: "bg-surface-container text-navy-deep",
} as const;

function Chip({ tone, children }: { tone: keyof typeof CHIP; children: React.ReactNode }) {
  return (
    <span className={`inline-flex items-center rounded-full px-2 py-[3px] text-[9px] font-semibold ${CHIP[tone]}`}>
      {children}
    </span>
  );
}

function ScreenTitle({ children, sub }: { children: React.ReactNode; sub?: string }) {
  return (
    <div className="bg-surface-white px-4 pt-2 pb-3">
      <p className="text-[15px] font-bold leading-tight">{children}</p>
      {sub && <p className="mt-0.5 text-[10px] text-on-surface-variant">{sub}</p>}
    </div>
  );
}

/** My Storage — what you have with us, each with its code and where it is. */
export function StorageScreen({ className = "" }: { className?: string }) {
  const units = [
    { name: "Bedding", code: "SBX-9942-A1", tone: "stored", status: "In storage", icon: "bed" },
    { name: "Books", code: "SBX-9942-B4", tone: "stored", status: "In storage", icon: "menu_book" },
    { name: "Bicycle", code: "SBX-3107-C2", tone: "moving", status: "In transit", icon: "pedal_bike" },
    { name: "Kitchen", code: "SBX-5521-A7", tone: "waiting", status: "Awaiting pickup", icon: "inventory_2" },
  ] as const;
  return (
    <PhoneFrame
      activeTab="Storage"
      label="The My Storage screen in the StrongBox app, listing four stored items with their codes and statuses"
      className={className}
    >
      <ScreenTitle sub="4 items · 3 billed this month">My Storage</ScreenTitle>
      <div className="flex gap-1.5 px-4 py-2.5">
        {["All", "In storage", "On the move"].map((f, i) => (
          <span
            key={f}
            className={`rounded-full px-2.5 py-1 text-[9px] font-semibold ${
              i === 0 ? "bg-navy-deep text-surface-white" : "bg-surface-white text-on-surface-variant border border-outline-variant/70"
            }`}
          >
            {f}
          </span>
        ))}
      </div>
      <ul className="space-y-2 px-4">
        {units.map(({ name, code, tone, status, icon }) => (
          <li key={code} className="flex items-center gap-2.5 rounded-xl bg-surface-white p-2.5 shadow-tactile">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-sky-tint">
              <span className="material-symbols-outlined !text-[18px] text-accent-deep">{icon}</span>
            </span>
            <span className="min-w-0 flex-1">
              <span className="block truncate text-[11px] font-semibold leading-tight">{name}</span>
              <span className="block whitespace-nowrap font-mono text-[9px] text-on-surface-variant">{code}</span>
            </span>
            <Chip tone={tone}>{status}</Chip>
          </li>
        ))}
      </ul>
    </PhoneFrame>
  );
}

/** Book the pickup — date, window, address. */
export function BookingScreen({ className = "" }: { className?: string }) {
  return (
    <PhoneFrame
      activeTab="Orders"
      label="The pickup booking screen in the StrongBox app, with a date, a morning window and an address chosen"
      className={className}
    >
      <ScreenTitle sub="6 boxes · 1 bicycle">Book your pickup</ScreenTitle>
      <div className="space-y-2.5 px-4 pt-3">
        <div className="rounded-xl bg-surface-white p-3 shadow-tactile">
          <p className="text-[9px] font-semibold text-on-surface-variant">Date</p>
          <div className="mt-1.5 grid grid-cols-5 gap-1 text-center">
            {[
              ["Mon", "7"],
              ["Tue", "8"],
              ["Wed", "9"],
              ["Thu", "10"],
              ["Fri", "11"],
            ].map(([d, n], i) => (
              <span
                key={d}
                className={`rounded-lg py-1.5 ${i === 2 ? "bg-accent text-on-accent" : "bg-mist"}`}
              >
                <span className="block text-[8px] opacity-80">{d}</span>
                <span className="block text-[12px] font-bold leading-tight">{n}</span>
              </span>
            ))}
          </div>
        </div>
        <div className="rounded-xl bg-surface-white p-3 shadow-tactile">
          <p className="text-[9px] font-semibold text-on-surface-variant">Time window</p>
          <div className="mt-1.5 space-y-1">
            {[
              ["Morning", "08:00 – 12:00"],
              ["Afternoon", "12:00 – 17:00"],
              ["Evening", "17:00 – 20:00"],
            ].map(([w, t], i) => (
              <div
                key={w}
                className={`flex items-center justify-between rounded-lg border px-2.5 py-1.5 text-[10px] ${
                  i === 0 ? "border-accent-deep bg-sky-tint font-semibold" : "border-outline-variant/70"
                }`}
              >
                <span>{w}</span>
                <span className="text-on-surface-variant">{t}</span>
              </div>
            ))}
          </div>
        </div>
        <div className="flex items-center gap-2 rounded-xl bg-surface-white p-3 shadow-tactile">
          <span className="material-symbols-outlined !text-[16px] text-accent-deep">location_on</span>
          <span className="text-[10px]">12 Main Road, Sea Point</span>
        </div>
        <div className="rounded-xl bg-accent py-2.5 text-center text-[11px] font-semibold text-on-accent">
          Book pickup
        </div>
      </div>
    </PhoneFrame>
  );
}

/** One order, mid-delivery — the timeline the app shows. */
export function OrderScreen({ className = "" }: { className?: string }) {
  const steps = [
    { label: "Requested", at: "Mon 09:12", done: true },
    { label: "Confirmed", at: "Mon 10:40", done: true },
    { label: "Driver on the way", at: "Tue 08:55", done: true },
    { label: "Driver arrived", at: "", done: false },
    { label: "Delivered", at: "", done: false },
  ];
  return (
    <PhoneFrame
      activeTab="Orders"
      label="An order screen in the StrongBox app showing a delivery of two items with the driver on the way"
      className={className}
    >
      <ScreenTitle sub="Tue 8 · Morning window">Delivery · 2 items</ScreenTitle>
      <div className="space-y-2.5 px-4 pt-3">
        <div className="flex items-center justify-between rounded-xl bg-surface-white p-3 shadow-tactile">
          <span className="text-[10px] text-on-surface-variant">Status</span>
          <Chip tone="moving">On the way</Chip>
        </div>
        <ol className="rounded-xl bg-surface-white p-3 shadow-tactile">
          {steps.map(({ label, at, done }, i) => (
            <li key={label} className="relative flex gap-2.5 pb-3 last:pb-0">
              {i < steps.length - 1 && (
                <span
                  className={`absolute left-[6px] top-3.5 h-full w-px ${done && steps[i + 1]?.done ? "bg-accent" : "bg-outline-variant"}`}
                />
              )}
              <span
                className={`relative z-10 mt-0.5 flex h-[13px] w-[13px] shrink-0 items-center justify-center rounded-full ${
                  done ? "bg-accent" : "border-2 border-outline-variant bg-surface-white"
                }`}
              >
                {done && <span className="material-symbols-outlined !text-[9px] text-on-accent">check</span>}
              </span>
              <span className="flex flex-1 items-baseline justify-between gap-2">
                <span className={`text-[10.5px] ${done ? "font-semibold" : "text-on-surface-variant"}`}>{label}</span>
                <span className="text-[9px] text-on-surface-variant">{at}</span>
              </span>
            </li>
          ))}
        </ol>
        <div className="flex items-center gap-2.5 rounded-xl bg-surface-white p-3 shadow-tactile">
          <span className="flex h-8 w-8 items-center justify-center rounded-full bg-sky-tint">
            <span className="material-symbols-outlined !text-[16px] text-accent-deep">badge</span>
          </span>
          <span>
            <span className="block text-[10.5px] font-semibold leading-tight">Your driver</span>
            <span className="block font-mono text-[9px] text-on-surface-variant">E-ID DRV-Q2N7HC</span>
          </span>
        </div>
      </div>
    </PhoneFrame>
  );
}
