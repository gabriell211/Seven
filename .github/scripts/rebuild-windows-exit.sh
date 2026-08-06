#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-windows-exit"
rm -rf "$work"
mkdir -p "$work"

git show 7038b8e2412c6c42da756a362726c2272aac88e3:.github/scripts/rebuild-windows-args.sh > "$work/rebuild-windows-args.sh"

BASE_SCRIPT="$work/rebuild-windows-args.sh" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["BASE_SCRIPT"])
text = path.read_text()
marker = '\nbash .github/scripts/rebuild-semantic-seeds.sh\n'
patch = r'''
python - <<'PYEXIT'
from pathlib import Path

path = Path('.github/scripts/rebuild-semantic-seeds.sh')
text = path.read_text()
marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
entry_patch = r'''
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PYENTRY'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
old = 'void mainCRTStartup(void){char*cmd=GetCommandLineA();char*argv[128];int argc=parse_cmdline(cmd,argv,128);ExitProcess((unsigned)core_main(argc,argv));}'
new = 'int mainCRTStartup(void){char*cmd=GetCommandLineA();char*argv[128];int argc=parse_cmdline(cmd,argv,128);return core_main(argc,argv);}'
if old not in source:
    raise SystemExit('Windows mainCRTStartup target not found')
path.write_text(source.replace(old, new, 1))
PYENTRY
'''
if marker not in text:
    raise SystemExit('semantic compiler build marker not found')
text = text.replace(marker, '\n' + entry_patch + marker, 1)
text = text.replace(
    "git commit -m 'fix Windows bootstrap command-line parsing'",
    "git commit -m 'return Windows bootstrap exit codes directly'",
    1,
)
path.write_text(text)
PYEXIT
'''
if marker not in text:
    raise SystemExit('Windows argument rebuild execution marker not found')
path.write_text(text.replace(marker, '\n' + patch + marker, 1))
PY

bash "$work/rebuild-windows-args.sh"
