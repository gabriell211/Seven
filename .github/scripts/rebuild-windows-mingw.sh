#!/usr/bin/env bash
set -euo pipefail

archive_sha='b0017401ec6b14eca6efc33008f48fd516cb309075623d7882f5b9fb69fad812'
windows_sha='1f1c99a8444b2e2bdc1d98be7207dc3623954298f2f759971f7da5c45cfccbcb'
old_archive_sha='5b18c8a0e647d2abcac3059160ed6f73ade753c06ba8af29e1bf0d3a5b5ec3a8'
old_windows_sha='205760f611a198ace66358ded62b620aa58ac24954e80efed1f804ce2a177863'

work="${RUNNER_TEMP:-/tmp}/seven-seed-sync"
rm -rf "$work"
mkdir -p "$work/native-seeds"
cat seed/native/final/v1/part*.b64 | tr -d '\r\n\t ' | base64 --decode > "$work/native-seeds.zip"
echo "$archive_sha  $work/native-seeds.zip" | sha256sum --check
unzip -q "$work/native-seeds.zip" -d "$work/native-seeds"
echo "$windows_sha  $work/native-seeds/seven-windows.exe" | sha256sum --check

ARCHIVE_SHA="$archive_sha" WINDOWS_SHA="$windows_sha" OLD_ARCHIVE_SHA="$old_archive_sha" OLD_WINDOWS_SHA="$old_windows_sha" python - <<'PY'
import os
from pathlib import Path

archive_sha = os.environ['ARCHIVE_SHA']
windows_sha = os.environ['WINDOWS_SHA']
old_archive_sha = os.environ['OLD_ARCHIVE_SHA']
old_windows_sha = os.environ['OLD_WINDOWS_SHA']

for name in ('.github/workflows/foundation.yml', '.github/workflows/readiness.yml'):
    path = Path(name)
    text = path.read_text()
    archive_count = text.count(old_archive_sha)
    windows_count = text.count(old_windows_sha)
    if archive_count < 1:
        raise SystemExit(f'{name}: old archive hash not found')
    if windows_count < 1:
        raise SystemExit(f'{name}: old Windows hash not found')
    text = text.replace(old_archive_sha, archive_sha)
    text = text.replace(old_windows_sha, windows_sha)
    path.write_text(text)
PY

git config user.name gabriell211
git config user.email 102088315+gabriell211@users.noreply.github.com
git add .github/workflows/foundation.yml .github/workflows/readiness.yml
git diff --cached --check
if git diff --cached --quiet; then
  exit 0
fi
git commit -m 'sync workflows with rebuilt Windows seed'
git push origin HEAD:gabriell211/production-readiness
