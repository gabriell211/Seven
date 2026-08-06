from __future__ import annotations

import sys
from pathlib import Path


def inject_base(path: Path) -> None:
    text = path.read_text()
    marker = "\nbash .github/scripts/rebuild-semantic-seeds.sh\n"
    command = (
        "\npython .github/scripts/patch-windows-entry.py inject-semantic "
        ".github/scripts/rebuild-semantic-seeds.sh\n"
    )
    if marker not in text:
        raise SystemExit("Windows argument rebuild execution marker not found")
    path.write_text(text.replace(marker, command + marker, 1))


def inject_semantic(path: Path) -> None:
    text = path.read_text()
    marker = (
        '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter '
        '"$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
    )
    command = (
        '\npython .github/scripts/patch-windows-entry.py patch-c '
        '"$work/seven-bootstrap.c"\n'
    )
    if marker not in text:
        raise SystemExit("semantic compiler build marker not found")
    text = text.replace(marker, command + marker, 1)
    text = text.replace(
        "git commit -m 'fix Windows bootstrap command-line parsing'",
        "git commit -m 'return Windows bootstrap exit codes directly'",
        1,
    )
    path.write_text(text)


def patch_c(path: Path) -> None:
    text = path.read_text()
    old = (
        "void mainCRTStartup(void){char*cmd=GetCommandLineA();char*argv[128];"
        "int argc=parse_cmdline(cmd,argv,128);"
        "ExitProcess((unsigned)core_main(argc,argv));}"
    )
    new = (
        "int mainCRTStartup(void){char*cmd=GetCommandLineA();char*argv[128];"
        "int argc=parse_cmdline(cmd,argv,128);return core_main(argc,argv);}"
    )
    if old not in text:
        raise SystemExit("Windows mainCRTStartup target not found")
    path.write_text(text.replace(old, new, 1))


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: patch-windows-entry.py <inject-base|inject-semantic|patch-c> <path>")
    mode, raw_path = sys.argv[1], sys.argv[2]
    path = Path(raw_path)
    actions = {
        "inject-base": inject_base,
        "inject-semantic": inject_semantic,
        "patch-c": patch_c,
    }
    action = actions.get(mode)
    if action is None:
        raise SystemExit(f"unknown mode: {mode}")
    action(path)


if __name__ == "__main__":
    main()
