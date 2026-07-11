#!/usr/bin/env bash
# Build the browser demo into docs/ (GitHub Pages). Needs zig for C->wasm.
set -euo pipefail
cd "$(dirname "$0")/.."
MACHIN="${MACHIN:-machin}"
[ -f ml/models/fighter.json ] || { echo "ml/models/fighter.json missing — train first" >&2; exit 1; }
mkdir -p docs
cat ml/vendor/tinybrain.src src/fight.src web/fight_wasm.src | "$MACHIN" encode /dev/stdin > /tmp/fight_wasm.mfl
"$MACHIN" build /tmp/fight_wasm.mfl --target wasm -o docs/fight.wasm
cp web/index.html docs/index.html
cp ml/models/fighter.json docs/fighter.json
cp ml/models/fighter_rival.json docs/fighter_rival.json
ls -la docs/
echo "built docs/ — serve locally: python3 -m http.server -d docs 8342"
