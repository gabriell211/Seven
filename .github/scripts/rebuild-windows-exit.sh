#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-windows-exit"
rm -rf "$work"
mkdir -p "$work"

git show 7038b8e2412c6c42da756a362726c2272aac88e3:.github/scripts/rebuild-windows-args.sh > "$work/rebuild-windows-args.sh"
python .github/scripts/patch-windows-entry.py inject-base "$work/rebuild-windows-args.sh"
bash "$work/rebuild-windows-args.sh"
