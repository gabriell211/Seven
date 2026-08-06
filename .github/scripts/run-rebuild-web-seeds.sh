#!/usr/bin/env bash
set -euo pipefail

fixed="${RUNNER_TEMP:-/tmp}/rebuild-web-seeds-fixed.sh"
cp .github/scripts/rebuild-web-seeds.sh "$fixed"

FIXED_SCRIPT="$fixed" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["FIXED_SCRIPT"])
text = path.read_text()

text = text.replace("SIZE_MAX/2", "((size_t)-1)/2")
text = text.replace("UINT32_MAX", "0xffffffffu")
text = text.replace("int32_t", "int")
old_ident = "static int seven_web_ident(int c){return isalnum((unsigned char)c)||c=='_';}"
new_ident = """static int seven_web_ascii_alnum(int c){return (c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9');}
static int seven_web_espaco(int c){return c==' '||c=='\\t'||c=='\\r'||c=='\\n';}
static int seven_web_ident(int c){return seven_web_ascii_alnum(c)||c=='_';}"""
if old_ident not in text:
    raise SystemExit("web identifier helper target not found")
text = text.replace(old_ident, new_ident, 1)
text = text.replace("isspace((unsigned char)*p)", "seven_web_espaco((unsigned char)*p)")

start = text.index("old_usage = ")
marker = "path.write_text(source)\nPYWEB"
end = text.index(marker, start)

replacement = r'''new_usage = r"""static void usage(void){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos\\nusage:\\n  seven --version\\n  seven check <file.sev>\\n  seven build <file.sev> [out.svbc]\\n  seven web build <file.sev> [out-dir]\\n  seven run <file.sev>\\n  seven verify <foundation|bootstrap|production>\\n  seven doctor");}}"""
usage_start = source.index('static void usage(void)')
usage_end = source.index('\\nstatic int core_main', usage_start)
source = source[:usage_start] + new_usage + source[usage_end:]

new_core = r"""static int core_main(int argc,char**argv){{if(argc<2||streq(argv[1],"--help")||streq(argv[1],"-h")){{usage();return 0;}}if(streq(argv[1],"--version")){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos");return 0;}}if(streq(argv[1],"check")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],"build")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],"web")&&argc>=4&&streq(argv[2],"build"))return cmd_web_build(argv[3],argc>=5?argv[4]:"build/web");if(streq(argv[1],"run")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],"verify")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],"doctor")){{puts("seven doctor: semantic transition seed operational\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC, direct WebAssembly");return 0;}}printf("unknown or incomplete command\\n");usage();return 2;}}"""
core_start = source.index('static int core_main')
core_end = source.index('\\n#ifndef _WIN32', core_start)
source = source[:core_start] + new_core + source[core_end:]
path.write_text(source)
'''

text = text[:start] + replacement + text[end + len("path.write_text(source)\n"):]
path.write_text(text)
PY

bash "$fixed"
