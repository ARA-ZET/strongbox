#!/usr/bin/env node
/**
 * StrongBox app-icon generator.
 *
 *   (cd web && npm ci)   # once — rasterises with web's `sharp`
 *   node packages/brand/build.mjs
 *
 * The website's favicon, web/app/icon.svg, is the source. This rasterises it
 * into the Flutter app's launcher icons so the app's browser tab and home
 * screen icon match the site's:
 *   - app/web/favicon.png + app/web/icons/*.png  (Flutter web favicon, PWA)
 *   - app/ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
 *   - app/android/app/src/main/res/mipmap-*\/ic_launcher.png
 *
 * The in-app logo is not generated: it is the site's navbar logo (Material
 * Symbols `package_2`, filled), drawn by app/lib/core/widgets/brand_logo.dart.
 */
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const source = readFileSync(resolve(repoRoot, "web/app/icon.svg"), "utf8");

let sharp;
try {
  sharp = createRequire(resolve(repoRoot, "web/package.json"))("sharp");
} catch {
  console.error("sharp not found — run `npm ci` in web/ first.");
  process.exit(1);
}

/**
 * The favicon at a pixel size. `square` drops the plate's corner radius for
 * iOS and maskable icons, where the OS applies its own mask.
 */
function svgAt(size, square) {
  let svg = source.replace("<svg ", `<svg width="${size}" height="${size}" `);
  if (square) svg = svg.replace(/(<rect\b[^>]*?)\s+rx="[^"]*"/, "$1");
  return Buffer.from(svg);
}

const icons = [
  // Flutter web — rounded plate on transparent, like the site favicon.
  { out: "app/web/favicon.png", size: 32 },
  { out: "app/web/icons/Icon-192.png", size: 192 },
  { out: "app/web/icons/Icon-512.png", size: 512 },
  // Maskable — full bleed; the glyph sits inside the 80% safe zone.
  { out: "app/web/icons/Icon-maskable-192.png", size: 192, square: true },
  { out: "app/web/icons/Icon-maskable-512.png", size: 512, square: true },
  // Android legacy launcher icons.
  ...[
    ["mdpi", 48],
    ["hdpi", 72],
    ["xhdpi", 96],
    ["xxhdpi", 144],
    ["xxxhdpi", 192],
  ].map(([dpi, size]) => ({ out: `app/android/app/src/main/res/mipmap-${dpi}/ic_launcher.png`, size })),
];

// iOS — square and opaque (App Store rejects alpha); iOS applies the mask.
const iosDir = "app/ios/Runner/Assets.xcassets/AppIcon.appiconset";
const iosContents = JSON.parse(readFileSync(resolve(repoRoot, iosDir, "Contents.json"), "utf8"));
const seen = new Set();
for (const img of iosContents.images) {
  if (!img.filename || seen.has(img.filename)) continue;
  seen.add(img.filename);
  const size = Math.round(parseFloat(img.size) * parseFloat(img.scale));
  icons.push({ out: `${iosDir}/${img.filename}`, size, square: true, opaque: true });
}

const plate = source.match(/<rect\b[^>]*\bfill="([^"]+)"/)?.[1] ?? "#0a1a33";

for (const icon of icons) {
  let img = sharp(svgAt(icon.size, icon.square));
  if (icon.opaque) img = img.flatten({ background: plate });
  await img.png().toFile(resolve(repoRoot, icon.out));
  console.log(`  wrote ${icon.out} (${icon.size}px)`);
}
