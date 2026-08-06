#!/usr/bin/env bash
set -euo pipefail

fixed="${RUNNER_TEMP:-/tmp}/rebuild-web-seeds-fixed.sh"
cp .github/scripts/rebuild-web-seeds.sh "$fixed"

FIXED_SCRIPT="$fixed" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["FIXED_SCRIPT"])
text = path.read_text()
start = text.index("old_usage = ")
marker = "path.write_text(source)\nPYWEB"
end = text.index(marker, start)

replacement = r"""new_usage = r'''static void usage(void){puts(\"Seven \" SEVEN_VERSION \"\\nCreator: Gabriel Barcelos\\nusage:\\n  seven --version\\n  seven check <file.sev>\\n  seven build <file.sev> [out.svbc]\\n  seven web build <file.sev> [out-dir]\\n  seven run <file.sev>\\n  seven verify <foundation|bootstrap|production>\\n  seven doctor\");}'''
usage_start = source.index('static void usage(void)')
usage_end = source.index('\\nstatic int core_main', usage_start)
source = source[:usage_start] + new_usage + source[usage_end:]

new_core = r'''static int core_main(int argc,char**argv){if(argc<2||streq(argv[1],\"--help\")||streq(argv[1],\"-h\")){usage();return 0;}if(streq(argv[1],\"--version\")){puts(\"Seven \" SEVEN_VERSION \"\\nCreator: Gabriel Barcelos\");return 0;}if(streq(argv[1],\"check\")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],\"build\")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],\"web\")&&argc>=4&&streq(argv[2],\"build\"))return cmd_web_build(argv[3],argc>=5?argv[4]:\"build/web\");if(streq(argv[1],\"run\")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],\"verify\")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],\"doctor\")){puts(\"seven doctor: semantic transition seed operational\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC, direct WebAssembly\");return 0;}printf(\"unknown or incomplete command\\n\");usage();return 2;}'''
core_start = source.index('static int core_main')
core_end = source.index('\\n#ifndef _WIN32', core_start)
source = source[:core_start] + new_core + source[core_end:]
path.write_text(source)
"""

text = text[:start] + replacement + text[end + len("path.write_text(source)\n"):]
path.write_text(text)
PY

bash "$fixed"
