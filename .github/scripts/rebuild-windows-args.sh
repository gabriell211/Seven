#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-windows-args"
rm -rf "$work"
mkdir -p "$work" .github/scripts

git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/rebuild-semantic-seeds.sh > .github/scripts/rebuild-semantic-seeds.sh
git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/enable-generic-fields.py > .github/scripts/enable-generic-fields.py
python .github/scripts/enable-generic-fields.py

python - <<'PY'
from pathlib import Path

path = Path('.github/scripts/rebuild-semantic-seeds.sh')
text = path.read_text()
marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
patch = r'''
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PYFIX'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
old = 'static int parse_cmdline(char*s,char**argv,int max){int argc=0;while(*s&&argc<max){while(*s==\' \'||*s==\'\\t\')s++;if(!*s)break;char*out=s;argv[argc++]=out;int q=0;while(*s){if(*s==\'"\'){q=!q;s++;continue;}if(!q&&(*s==\' \'||*s==\'\\t\'))break;*out++=*s++;}*out=0;if(*s)s++;}return argc;}'
new = 'static int parse_cmdline(char*s,char**argv,int max){int argc=0;while(*s&&argc<max){while(*s==\' \'||*s==\'\\t\')s++;if(!*s)break;char*out=s;argv[argc++]=out;int q=0;while(*s){if(*s==\'"\'){q=!q;s++;continue;}if(!q&&(*s==\' \'||*s==\'\\t\'))break;*out++=*s++;}if(*s)s++;*out=0;}return argc;}'
if old not in source:
    raise SystemExit('Windows parse_cmdline target not found')
path.write_text(source.replace(old, new, 1))
PYFIX
'''
if marker not in text:
    raise SystemExit('semantic compiler build marker not found')
text = text.replace(marker, '\n' + patch + marker, 1)
old_hash = 'archive_sha=$(sha256sum "$work/native-seeds.zip" | cut -d\' \' -f1)'
new_hash = '''cat seed/native/final/v1/part*.b64 | tr -d '\\r\\n\\t ' | base64 --decode > "$work/reconstructed.zip"
cmp "$work/native-seeds.zip" "$work/reconstructed.zip"
archive_sha=$(sha256sum "$work/reconstructed.zip" | cut -d' ' -f1)'''
if old_hash not in text:
    raise SystemExit('archive hash target not found')
text = text.replace(old_hash, new_hash, 1)
text = text.replace(
    "git commit -m 'rebuild semantic seeds with delimiter-aware checker'",
    "git commit -m 'fix Windows bootstrap command-line parsing'",
    1,
)
path.write_text(text)
PY

bash .github/scripts/rebuild-semantic-seeds.sh
