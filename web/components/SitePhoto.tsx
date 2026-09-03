import { PHOTOS, type PhotoId, type PhotoSlot } from "@/lib/photos";

/**
 * One photographic slot on the site.
 *
 * Until `src` is set on the slot in `lib/photos.ts`, this renders a labelled
 * placeholder carrying the art direction for the shot — at the exact aspect
 * ratio the real photograph will occupy, so dropping the picture in later
 * changes nothing about the layout around it.
 *
 * The placeholder is deliberately obvious. A grey box that merely looks like
 * a slow-loading image is the one thing that could plausibly reach production
 * unnoticed; a dashed frame stamped "PHOTO PLACEHOLDER" cannot.
 *
 * No `next/image`: the project serves plain `<img>` everywhere (see
 * `graphics/Illustration.tsx`) and has no image optimiser configured, so this
 * stays consistent with the rest of the site.
 */
export default function SitePhoto({
  id,
  className = "",
  tone = "light",
  rounded = "rounded-xl",
}: {
  id: PhotoId;
  className?: string;
  /** `dark` for placement on a navy ground, so the frame stays legible. */
  tone?: "light" | "dark";
  /** Override when the frame needs different corners to its container. */
  rounded?: string;
}) {
  /*
   * Widened to `PhotoSlot` on the way out of the map. `PHOTOS` is declared
   * `as const satisfies …` so the ids stay literal for `PhotoId`, but that
   * also narrows each entry to its own exact shape — and the optional fields
   * are then invisible on the entries that happen not to carry them.
   */
  const photo: PhotoSlot = PHOTOS[id];
  const [w, h] = photo.ratio;
  const aspect = { aspectRatio: `${w} / ${h}` };
  const src = photo.src;

  if (src) {
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={src}
        alt={photo.alt}
        width={photo.size[0]}
        height={photo.size[1]}
        loading={photo.priority ? "eager" : "lazy"}
        /*
         * `eager` only removes the lazy-load delay; it does not lift the image
         * out of the low-priority bucket the preload scanner puts images in.
         * The hero photo is the LCP element on most pages, so it needs the
         * explicit priority bump to be fetched ahead of below-fold assets.
         */
        fetchPriority={photo.priority ? "high" : "auto"}
        decoding="async"
        style={aspect}
        className={`w-full h-full object-cover ${rounded} ${className}`}
      />
    );
  }

  const dark = tone === "dark";

  return (
    <div
      role="img"
      aria-label={`Photograph placeholder — ${photo.alt}`}
      style={aspect}
      className={`relative w-full overflow-hidden border-2 border-dashed flex items-center justify-center ${rounded} ${
        dark
          ? "bg-navy border-surface-white/25"
          : "bg-mist border-outline-variant"
      } ${className}`}
    >
      {/* Diagonal hatch — reads as "nothing here yet" at any size. */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage: `repeating-linear-gradient(45deg, ${
            dark ? "rgba(255,255,255,0.045)" : "rgba(10,26,51,0.045)"
          } 0 10px, transparent 10px 20px)`,
        }}
      />

      <div className="relative z-10 text-center px-5 py-6 max-w-[42ch]">
        <span
          className={`inline-block font-label-caps uppercase tracking-widest text-[10px] px-2.5 py-1 rounded-full mb-3 ${
            dark ? "bg-surface-white/15 text-on-navy" : "bg-sky-tint text-accent-deep"
          }`}
        >
          Photo placeholder
        </span>

        {/*
          Wrapped rather than given `block` directly: `globals.css` sets
          `.material-symbols-outlined { display: inline-block }` outside any
          layer, so it wins over the utility and the icon sits on the chip's
          line instead of below it.
        */}
        <div className="mb-2">
          <span
            aria-hidden="true"
            className={`material-symbols-outlined text-3xl ${
              dark ? "text-sky" : "text-accent-deep"
            }`}
          >
            photo_camera
          </span>
        </div>

        {/* The brief. Small enough not to shout, large enough to actually brief. */}
        <p
          className={`text-xs leading-relaxed mb-3 ${
            dark ? "text-on-navy" : "text-on-surface-variant"
          }`}
        >
          {photo.brief}
        </p>

        <p
          className={`text-[10px] font-mono leading-relaxed ${
            dark ? "text-on-navy-variant" : "text-on-surface-variant/80"
          }`}
        >
          public/photos/{id}.jpg
          <br />
          {photo.size[0]}&thinsp;×&thinsp;{photo.size[1]} · {w}:{h}
        </p>
      </div>
    </div>
  );
}
