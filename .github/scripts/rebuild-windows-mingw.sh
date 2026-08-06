#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-windows-mingw"
rm -rf "$work"
mkdir -p "$work" .github/scripts

git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/rebuild-semantic-seeds.sh > .github/scripts/rebuild-semantic-seeds.sh
git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/enable-generic-fields.py > .github/scripts/enable-generic-fields.py
python .github/scripts/enable-generic-fields.py

python - <<'PY'
from pathlib import Path

path = Path('.github/scripts/rebuild-semantic-seeds.sh')
text = path.read_text()
build_marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
entry_patch = r"""
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PYENTRY'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
old_entry = '''#ifndef _WIN32
int main(int argc,char**argv){return core_main(argc,argv);}
#else
static int parse_cmdline(char*s,char**argv,int max){int argc=0;while(*s&&argc<max){while(*s==' '||*s=='\\t')s++;if(!*s)break;char*out=s;argv[argc++]=out;int q=0;while(*s){if(*s=='"'){q=!q;s++;continue;}if(!q&&(*s==' '||*s=='\\t'))break;*out++=*s++;}*out=0;if(*s)s++;}return argc;}
void mainCRTStartup(void){char*cmd=GetCommandLineA();char*argv[128];int argc=parse_cmdline(cmd,argv,128);ExitProcess((unsigned)core_main(argc,argv));}
#endif'''
new_entry = 'int main(int argc,char**argv){return core_main(argc,argv);}'
if old_entry not in source:
    raise SystemExit('Windows CRT entrypoint target not found')
path.write_text(source.replace(old_entry, new_entry, 1))
PYENTRY
"""
if build_marker not in text:
    raise SystemExit('Linux compiler build marker not found')
text = text.replace(build_marker, '\n' + entry_patch + build_marker, 1)

start = text.index('cat > "$work/kernel32.def"')
end_line = '"$link" /subsystem:console /entry:mainCRTStartup /nodefaultlib /out:"$work/seven-windows.exe" "$work/seven-windows.obj" "$work/kernel32.lib" "$work/msvcrt.lib"\n'
end = text.index(end_line, start) + len(end_line)
mingw = 'x86_64-w64-mingw32-gcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -Wl,--enable-auto-import -lkernel32 -o "$work/seven-windows.exe"\n'
text = text[:start] + mingw + text[end:]

old_hash = 'archive_sha=$(sha256sum "$work/native-seeds.zip" | cut -d\' \' -f1)'
new_hash = (
    'cat seed/native/final/v1/part*.b64 | tr -d \'\\r\\n\\t \' | '
    'base64 --decode > "$work/reconstructed.zip"\n'
    'cmp "$work/native-seeds.zip" "$work/reconstructed.zip"\n'
    'archive_sha=$(sha256sum "$work/reconstructed.zip" | cut -d\' \' -f1)'
)
if old_hash not in text:
    raise SystemExit('archive hash target not found')
text = text.replace(old_hash, new_hash, 1)
text = text.replace(
    "git commit -m 'rebuild semantic seeds with delimiter-aware checker'",
    "git commit -m 'rebuild Windows seed with native CRT startup'",
    1,
)
path.write_text(text)
PY

bash .github/scripts/rebuild-semantic-seeds.sh
