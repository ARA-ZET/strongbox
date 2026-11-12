import SitePhoto from "@/components/SitePhoto";
import { PHOTOS, type Photo, type PhotoId } from "@/lib/photos";

/**
 * A photograph inside a section: rounded, cropped to `ratio`, with the slot's
 * caption (if it has one) pinned to the corner.
 *
 * `children` are overlaid on the photo, for a stat or a note card; position
 * them yourself (the figure is `relative`).
 */
export default function PhotoFeature({
  id,
  sizes,
  ratio = "aspect-[4/3]",
  className = "",
  children,
}: {
  id: PhotoId;
  /** Describe the rendered width, e.g. "(min-width: 1024px) 560px, 100vw". */
  sizes: string;
  /** Tailwind aspect class for the frame. */
  ratio?: string;
  className?: string;
  children?: React.ReactNode;
}) {
  const { caption }: Photo = PHOTOS[id];
  return (
    <figure
      data-reveal="fade"
      className={`relative overflow-hidden rounded-2xl bg-navy-deep shadow-tactile ${ratio} ${className}`}
    >
      <SitePhoto id={id} sizes={sizes} className="absolute inset-0" />
      {caption && (
        <figcaption className="absolute right-3 top-3 rounded-full bg-navy-deep/75 px-2.5 py-1 text-[11px] font-medium text-surface-white">
          {caption}
        </figcaption>
      )}
      {children}
    </figure>
  );
}
