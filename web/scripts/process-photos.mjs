#!/usr/bin/env node
/**
 * Turns the photographs in `assets/photos-src/` into what the site serves.
 *
 *   npm run photos            process new or changed sources
 *   npm run photos -- --force reprocess everything (after changing the grade)
 *
 * For every `assets/photos-src/{slot}.jpg` it writes
 * `public/photos/{slot}-{640,1280,1920}.{avif,jpg}`. The slot name is the file
 * name; `lib/photos.ts` maps slots to alt text, credit and framing.
 *
 * Every photo gets the same grade, which is what makes stock from different
 * photographers read as one set: a little less saturation, a touch of
 * contrast, and a soft-light wash of the brand navy that cools the whites and
 * deepens the shadows. Change the numbers in GRADE, then run with --force.
 *
 * `sharp` is not a direct dependency: Next installs it for image optimisation,
 * and this script only runs on a developer's machine, never in the build.
 */
import { readdirSync, statSync, mkdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SRC = path.join(ROOT, "assets/photos-src");
const OUT = path.join(ROOT, "public/photos");

/** Must match `PHOTO_WIDTHS` in `lib/photos.ts`. */
const WIDTHS = [640, 1280, 1920];

const GRADE = {
  saturation: 0.8,
  contrast: [1.05, -5], // sharp.linear(a, b): out = a * in + b
  wash: { r: 15, g: 42, b: 82, alpha: 0.4 }, // navy (tokens: navy) in soft-light
};

const force = process.argv.includes("--force");
mkdirSync(OUT, { recursive: true });

const sources = readdirSync(SRC).filter((f) => /\.(jpe?g|png|webp)$/i.test(f));
let done = 0;

for (const file of sources) {
  const slot = path.parse(file).name;
  const srcPath = path.join(SRC, file);
  const srcTime = statSync(srcPath).mtimeMs;

  const outputs = WIDTHS.flatMap((w) => ["avif", "jpg"].map((ext) => path.join(OUT, `${slot}-${w}.${ext}`)));
  const fresh = outputs.every((p) => {
    try {
      return statSync(p).mtimeMs >= srcTime;
    } catch {
      return false;
    }
  });
  if (fresh && !force) continue;

  for (const width of WIDTHS) {
    // Resize first so the wash layer is created at the final size.
    const resized = await sharp(srcPath)
      .rotate()
      .resize({ width, withoutEnlargement: true })
      .toBuffer({ resolveWithObject: true });
    const { width: w, height: h } = resized.info;

    const graded = sharp(resized.data)
      .modulate({ saturation: GRADE.saturation })
      .linear(...GRADE.contrast)
      .composite([
        { input: { create: { width: w, height: h, channels: 4, background: GRADE.wash } }, blend: "soft-light" },
      ]);

    await graded.clone().avif({ quality: 52, effort: 4 }).toFile(path.join(OUT, `${slot}-${width}.avif`));
    await graded.clone().jpeg({ quality: 74, mozjpeg: true, progressive: true }).toFile(path.join(OUT, `${slot}-${width}.jpg`));
  }
  done++;
  console.log(`graded ${slot}`);
}

console.log(`${done} processed, ${sources.length - done} unchanged.`);
