#!/usr/bin/env bash
#
# Re-download the marketing illustrations from unDraw and rebrand them.
# Run from `strongbox-web/`:  bash scripts/fetch-illustrations.sh
#
# Each entry is "local-name|source URL". The local name is what
# `components/graphics/Illustration.tsx` refers to, so renaming one here means
# updating `IllustrationName` and `RATIOS` there too.
set -euo pipefail

SOURCES=(
  "moving|https://cdn.undraw.co/illustrations/moving_2cfm.svg"
  "facility|https://cdn.undraw.co/illustration/logistics_8vri.svg"
  "package-arrived|https://cdn.undraw.co/illustrations/package-arrived_twqd.svg"
  "contact-us|https://cdn.undraw.co/illustration/contact-us_s4jn.svg"
  "questions|https://cdn.undraw.co/illustration/questions_52ic.svg"
  "team|https://cdn.undraw.co/illustrations/good-team_zww8.svg"
  "pricing|https://cdn.undraw.co/illustration/pricing-page_88g4.svg"
  "map-location|https://cdn.undraw.co/illustrations/location-review_nzql.svg"
  "heavy-lifting|https://cdn.undraw.co/illustration/heavy-lifting_d753.svg"
  "checklist|https://cdn.undraw.co/illustrations/checklist_bwxa.svg"
)

mkdir -p public/illustrations
for entry in "${SOURCES[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  curl -fsSL --max-time 60 -o "public/illustrations/${name}.svg" "$url"
  printf '  fetched %s\n' "$name"
done

python3 scripts/rebrand-illustrations.py public/illustrations
