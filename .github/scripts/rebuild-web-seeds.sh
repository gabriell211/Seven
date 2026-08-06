#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-web-seed"
rm -rf "$work"
mkdir -p "$work" .github/scripts

git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/rebuild-semantic-seeds.sh > "$work/rebuild-semantic-seeds.sh"
git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/enable-generic-fields.py > .github/scripts/enable-generic-fields.py
python .github/scripts/enable-generic-fields.py

REBUILD_SCRIPT="$work/rebuild-semantic-seeds.sh" python - <<'PY'
import json
import os
import re
from pathlib import Path

path = Path(os.environ["REBUILD_SCRIPT"])
text = path.read_text()
build_marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'

html = """<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="generator" content="Seven web build 0.1">
  <title>Seven Web</title>
  <style>html{font-family:system-ui,sans-serif;background:#0b0d10;color:#f5f7fa}body{margin:0;min-height:100vh;display:grid;place-items:center}main{width:min(760px,calc(100% - 32px));padding:24px;border:1px solid #2c3440;border-radius:16px;background:#12161c;box-shadow:0 16px 60px #0008}pre{white-space:pre-wrap;margin:0;line-height:1.6}</style>
  <script type="module" src="./seven-runtime.js"></script>
</head>
<body>
  <main id="seven-app"><pre id="seven-output">Carregando aplicação Seven...</pre></main>
</body>
</html>
"""

runtime = r"""const decoder=new TextDecoder();
const output=document.getElementById('seven-output');
const setOutput=value=>{if(output)output.textContent=value;};
const be32=(bytes,offset)=>((bytes[offset]<<24)>>>0)|(bytes[offset+1]<<16)|(bytes[offset+2]<<8)|bytes[offset+3];
const hex=bytes=>Array.from(bytes,value=>value.toString(16).padStart(2,'0')).join('');
const decodeSevenString=value=>value.replace(/\\n/g,'\n').replace(/\\r/g,'\r').replace(/\\t/g,'\t').replace(/\\"/g,'"').replace(/\\\\/g,'\\');
const collectMessages=source=>{const messages=[];const pattern=/\bdiga\s*(?:\(\s*)?"((?:\\.|[^"\\])*)"/g;let match;while((match=pattern.exec(source))!==null)messages.push(decodeSevenString(match[1]));return messages;};
async function boot(){
  const response=await fetch('./app.svbc',{cache:'no-store'});
  if(!response.ok)throw new Error(`não foi possível carregar app.svbc (${response.status})`);
  const bytes=new Uint8Array(await response.arrayBuffer());
  const magic=[0x53,0x56,0x42,0x43,0,0,0,1];
  if(bytes.length<44||magic.some((value,index)=>bytes[index]!==value))throw new Error('imagem SVBC-v1 inválida');
  const sourceLength=be32(bytes,8);
  if(sourceLength>bytes.length-44)throw new Error('comprimento SVBC inválido');
  const sourceBytes=bytes.slice(44,44+sourceLength);
  const expectedDigest=bytes.slice(12,44);
  if(globalThis.crypto&&crypto.subtle){
    const actualDigest=new Uint8Array(await crypto.subtle.digest('SHA-256',sourceBytes));
    if(hex(actualDigest)!==hex(expectedDigest))throw new Error('checksum interno do SVBC não confere');
  }
  const source=decoder.decode(sourceBytes);
  const messages=collectMessages(source);
  setOutput(messages.length?messages.join('\n'):'Aplicação Seven carregada com sucesso.');
  const api=Object.freeze({format:'SVBC-v1',bytes,source,messages,sourceLength});
  globalThis.SevenWeb=api;
  globalThis.dispatchEvent(new CustomEvent('seven:ready',{detail:api}));
}
boot().catch(error=>{console.error('[Seven Web]',error);setOutput(`Falha ao iniciar Seven: ${error.message}`);});
"""

manifest_format = """{
  "format": "seven-web-1",
  "target": "web",
  "runtime": "seven-runtime.js",
  "entry": "app.svbc",
  "svbc": "SVBC-v1",
  "sha256": "%s"
}
"""

patch = f'''\nCHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PYWEB'\nimport json\nimport os\nimport re\nfrom pathlib import Path\n\npath = Path(os.environ["CHECKER_SOURCE"])\nsource = path.read_text()\n\nold_entry = \'''#ifndef _WIN32\nint main(int argc,char**argv){{return core_main(argc,argv);}}\n#else\nstatic int parse_cmdline(char*s,char**argv,int max){{int argc=0;while(*s&&argc<max){{while(*s==' '||*s=='\\\\t')s++;if(!*s)break;char*out=s;argv[argc++]=out;int q=0;while(*s){{if(*s=='"'){{q=!q;s++;continue;}}if(!q&&(*s==' '||*s=='\\\\t'))break;*out++=*s++;}}*out=0;if(*s)s++;}}return argc;}}\nvoid mainCRTStartup(void){{char*cmd=GetCommandLineA();char*argv[128];int argc=parse_cmdline(cmd,argv,128);ExitProcess((unsigned)core_main(argc,argv));}}\n#endif\'''\nnew_entry = 'int main(int argc,char**argv){{return core_main(argc,argv);}}'\nif old_entry not in source:\n    raise SystemExit('Windows CRT entrypoint target not found')\nsource = source.replace(old_entry, new_entry, 1)\n\nio_pattern = re.compile(r'#ifdef _WIN32\\n(?:(?!#else).)*GetFileAttributesA(?:(?!#else).)*#else', re.S)\nnew_io = \'''#ifdef _WIN32\n#include <stdio.h>\n#include <stdlib.h>\n#include <stdint.h>\n#include <stddef.h>\n#include <string.h>\n#include <ctype.h>\n#include <windows.h>\n#define strtoll _strtoi64\n#define snprintf _snprintf\n#else\'''\nsource, count = io_pattern.subn(new_io, source, count=1)\nif count != 1:\n    raise SystemExit(f'Windows native import block count was {{count}}')\n\nold_run = 'static int cmd_run(const char*path)'\nif old_run not in source:\n    raise SystemExit('cmd_run insertion target not found')\n\nhtml = {json.dumps(html)}\nruntime = {json.dumps(runtime)}\nmanifest_format = {json.dumps(manifest_format)}\n\ndef c_string(value):\n    return json.dumps(value, ensure_ascii=True)\n\nweb_code = f\'''static int web_path(char*out,size_t cap,const char*dir,const char*name){{int n=snprintf(out,cap,"%s/%s",dir,name);if(n<0||(size_t)n>=cap){{puts("SV-WEB-CAMINHO: output path is too long");return 0;}}return 1;}}\nstatic int cmd_web_build(const char*in,const char*out_dir){{if(!out_dir||!*out_dir)out_dir="build/web";char app[MAX_PATH_LEN],index[MAX_PATH_LEN],runtime_path[MAX_PATH_LEN],manifest_path[MAX_PATH_LEN];if(!web_path(app,sizeof(app),out_dir,"app.svbc")||!web_path(index,sizeof(index),out_dir,"index.html")||!web_path(runtime_path,sizeof(runtime_path),out_dir,"seven-runtime.js")||!web_path(manifest_path,sizeof(manifest_path),out_dir,"seven.web.json"))return 1;if(cmd_build(in,app))return 1;size_t image_n=0;char*image=read_file(app,&image_n);if(!image)return 1;char digest[65];hash_hex(image,image_n,digest);free(image);const char*html={{c_string(html)}};const char*runtime={{c_string(runtime)}};const char*manifest_format={{c_string(manifest_format)}};char manifest[1024];int manifest_n=snprintf(manifest,sizeof(manifest),manifest_format,digest);if(manifest_n<0||(size_t)manifest_n>=sizeof(manifest)){{puts("SV-WEB-MANIFESTO: manifest is too large");return 1;}}if(!write_file(index,html,strlen(html))||!write_file(runtime_path,runtime,strlen(runtime))||!write_file(manifest_path,manifest,(size_t)manifest_n))return 1;printf("web built: %s\\n",out_dir);return 0;}}\n\'''\nsource = source.replace(old_run, web_code + old_run, 1)\n\nold_usage = 'static void usage(void){{puts("Seven " SEVEN_VERSION "\\\\nCreator: Gabriel Barcelos\\\\nusage:\\\\n  seven --version\\\\n  seven check <file.sev>\\\\n  seven build <file.sev> [out.svbc]\\\\n  seven run <file.sev>\\\\n  seven verify <foundation|bootstrap|production>\\\\n  seven doctor");}}'\nnew_usage = 'static void usage(void){{puts("Seven " SEVEN_VERSION "\\\\nCreator: Gabriel Barcelos\\\\nusage:\\\\n  seven --version\\\\n  seven check <file.sev>\\\\n  seven build <file.sev> [out.svbc]\\\\n  seven web build <file.sev> [out-dir]\\\\n  seven run <file.sev>\\\\n  seven verify <foundation|bootstrap|production>\\\\n  seven doctor");}}'\nif old_usage not in source:\n    raise SystemExit('usage target not found')\nsource = source.replace(old_usage, new_usage, 1)\n\nold_core = 'static int core_main(int argc,char**argv){{if(argc<2||streq(argv[1],"--help")||streq(argv[1],"-h")){{usage();return 0;}}if(streq(argv[1],"--version")){{puts("Seven " SEVEN_VERSION "\\\\nCreator: Gabriel Barcelos");return 0;}}if(streq(argv[1],"check")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],"build")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],"run")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],"verify")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],"doctor")){{puts("seven doctor: semantic native bootstrap operational\\\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC");return 0;}}printf("unknown or incomplete command\\\\n");usage();return 2;}}'\nnew_core = 'static int core_main(int argc,char**argv){{if(argc<2||streq(argv[1],"--help")||streq(argv[1],"-h")){{usage();return 0;}}if(streq(argv[1],"--version")){{puts("Seven " SEVEN_VERSION "\\\\nCreator: Gabriel Barcelos");return 0;}}if(streq(argv[1],"check")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],"build")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],"web")&&argc>=4&&streq(argv[2],"build"))return cmd_web_build(argv[3],argc>=5?argv[4]:"build/web");if(streq(argv[1],"run")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],"verify")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],"doctor")){{puts("seven doctor: semantic native bootstrap operational\\\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC, web bundle");return 0;}}printf("unknown or incomplete command\\\\n");usage();return 2;}}'\nif old_core not in source:\n    raise SystemExit('core_main target not found')\nsource = source.replace(old_core, new_core, 1)\npath.write_text(source)\nPYWEB\n'''

if build_marker not in text:
    raise SystemExit('Linux compiler build marker not found')
text = text.replace(build_marker, patch + build_marker, 1)

start = text.index('cat > "$work/kernel32.def"')
end_line = '"$link" /subsystem:console /entry:mainCRTStartup /nodefaultlib /out:"$work/seven-windows.exe" "$work/seven-windows.obj" "$work/kernel32.lib" "$work/msvcrt.lib"\n'
end = text.index(end_line, start) + len(end_line)
mingw = (
    'x86_64-w64-mingw32-gcc -std=c11 -O2 -s -Wall -Wextra '
    '-Wno-unused-parameter "$work/seven-bootstrap.c" '
    '-Wl,--stack,16777216 -o "$work/seven-windows.exe"\n'
)
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

web_test = '''"$seven" web build examples/hello.sev "$work/web"\ntest -s "$work/web/app.svbc"\ntest -s "$work/web/index.html"\ntest -s "$work/web/seven-runtime.js"\ntest -s "$work/web/seven.web.json"\ngrep -q '"format": "seven-web-1"' "$work/web/seven.web.json"\nnode --check "$work/web/seven-runtime.js"\n'''
marker = '"$seven" doctor\n'
if marker not in text:
    raise SystemExit('web test insertion target not found')
text = text.replace(marker, marker + web_test, 1)
text = text.replace(
    "git commit -m 'rebuild semantic seeds with delimiter-aware checker'",
    "git commit -m 'rebuild native seeds with Seven web build'",
    1,
)
path.write_text(text)
PY

bash "$work/rebuild-semantic-seeds.sh"
