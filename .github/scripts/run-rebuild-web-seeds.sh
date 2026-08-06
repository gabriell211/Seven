#!/usr/bin/env bash
set -euo pipefail

fixed="${RUNNER_TEMP:-/tmp}/rebuild-web-seeds-fixed.sh"
cp .github/scripts/rebuild-web-seeds.sh "$fixed"

FIXED_SCRIPT="$fixed" python - <<'PY'
import os
import re
from pathlib import Path

path = Path(os.environ["FIXED_SCRIPT"])
text = path.read_text()

# The rebuild script generates a Python program which then writes C source.
# Raw interpolation is required so C escapes survive both Python layers.
needle = "patch = f'''"
if needle not in text:
    raise SystemExit("web patch block not found")
text = text.replace(needle, "patch = rf'''", 1)

# Keep the transition seed compatible with its deliberately small C import set.
text = text.replace("SIZE_MAX/2", "((size_t)-1)/2")
text = text.replace("UINT32_MAX", "0xffffffffu")
text = re.sub(r"\bint32_t\b", "int", text)

old_ident = "static int seven_web_ident(int c){return isalnum((unsigned char)c)||c=='_';}"
new_ident = """static int seven_web_ascii_alnum(int c){return (c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9');}
static int seven_web_espaco(int c){return c==' '||c=='\\t'||c=='\\r'||c=='\\n';}
static int seven_web_ident(int c){return seven_web_ascii_alnum(c)||c=='_';}"""
if old_ident not in text:
    raise SystemExit("web identifier helper target not found")
text = text.replace(old_ident, new_ident, 1)
text = text.replace("isspace((unsigned char)*p)", "seven_web_espaco((unsigned char)*p)")

# The rebuild commits only seed data. Workflow hashes are updated in a normal,
# reviewable commit after the generated values are known.
workflow_stage = "git add seed/native/final/v1/part*.b64 seed/native/final/v1/SHA256SUMS .github/workflows/foundation.yml .github/workflows/readiness.yml .github/workflows/web.yml"
seed_stage = "git add seed/native/final/v1/part*.b64 seed/native/final/v1/SHA256SUMS"
if workflow_stage in text:
    text = text.replace(workflow_stage, seed_stage, 1)

path.write_text(text)
PY

bash "$fixed"
