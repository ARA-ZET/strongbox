import { PHOTOS, photoSrcSet, type Photo, type PhotoId } from "@/lib/photos";

/**
 * One photograph from `lib/photos.ts`, served as AVIF with a JPEG fallback at
 * three widths.
 *
 * The frame is the caller's. Give a `relative` wrapper its size (an aspect
 * class, or absolute insets) and pass `className="absolute inset-0"`: the
 * image then fills it with `object-cover` at the photo's own focal point. An
 * aspect class on the `<picture>` itself does not hold — the image's own
 * intrinsic height wins and the frame grows to the photo's ratio.
 *
 * `sizes` must describe that box, or phones download the 1920px file for a
 * 300px card.
 *
 * No `next/image`: the site serves plain `<img>` everywhere and the variants
 * are produced ahead of time by `npm run photos`, so there is nothing for the
 * runtime optimiser to do.
 */
export default function SitePhoto({
  id,
  sizes,
  priority = false,
  className = "",
  imgClassName = "",
}: {
  id: PhotoId;
  sizes: string;
  /** The page's LCP image: fetched first, never lazily. */
  priority?: boolean;
  className?: string;
  imgClassName?: string;
}) {
  const photo: Photo = PHOTOS[id];
  return (
    <picture className={className}>
      <source type="image/avif" srcSet={photoSrcSet(id, "avif")} sizes={sizes} />
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={`/photos/${id}-1280.jpg`}
        srcSet={photoSrcSet(id, "jpg")}
        sizes={sizes}
        alt={photo.alt}
        width={photo.size[0]}
        height={photo.size[1]}
        loading={priority ? "eager" : "lazy"}
        fetchPriority={priority ? "high" : "auto"}
        decoding={priority ? "sync" : "async"}
        style={photo.focus ? { objectPosition: photo.focus } : undefined}
        className={`h-full w-full object-cover ${imgClassName}`}
      />
    </picture>
  );
}
