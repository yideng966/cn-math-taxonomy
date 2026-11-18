#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
SITE_ORIGIN="${SITE_ORIGIN:-https://math.20250424.xyz}"

mkdir -p "$DIST/data"
cp "$ROOT/index.html" "$ROOT/sw.js" "$ROOT/manifest.webmanifest" "$DIST/"
cp -a "$ROOT/assets" "$ROOT/explore" "$ROOT/diagnose" \
  "$ROOT/children" "$ROOT/goods" "$ROOT/wrongbook" "$DIST/"
rm -f "$DIST/diagnose/README.md"
cp "$ROOT/data/topics.json" "$ROOT/data/dependencies.json" \
  "$ROOT/data/cn-curriculum-standards.json" "$ROOT/data/questions.json" \
  "$ROOT/data/id-aliases.json" "$DIST/data/"

node "$ROOT/scripts/gen-kp-pages.mjs" --out "$DIST"

# Upstream's generated pages and metadata use its own domain and telemetry URL.
find "$DIST" -type f \( -name '*.html' -o -name '*.js' -o -name '*.xml' -o -name '*.txt' \) \
  -exec sed -i \
    "s#https://math.pansgo.com#${SITE_ORIGIN}#g;s#https://math-pansgo-stats.xiaokunfeng310.workers.dev/collect##g" \
    {} +

if grep -q 'math-pansgo-stats.xiaokunfeng310.workers.dev' "$DIST/assets/stats-config.js"; then
  echo 'Upstream telemetry URL remains in the build output' >&2
  exit 1
fi
