#!/usr/bin/env bash
set -euo pipefail

resolver=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/seven-source-closure.sh
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cd "$scratch"
mkdir -p app std extra
printf 'modulo app.main\nusa std.one\ncampo inicio() -> Num ::\n devolve 0\nfecha\n' > app/main.sev
printf 'modulo std.one\nusa std.two\n' > std/one.sev
printf 'modulo std.two\n' > std/two_part00.sev
printf 'modulo std.two\n' > std/two_part01.sev
printf 'modulo extra.unrelated\n' > extra/unrelated.sev
printf 'app/main.sev\nstd/one.sev\nstd/two_part00.sev\nstd/two_part01.sev\nextra/unrelated.sev\n' > all.sources
"$resolver" all.sources app/main.sev selected.sources
printf 'app/main.sev\nstd/one.sev\nstd/two_part00.sev\nstd/two_part01.sev\n' > expected.sources
cmp expected.sources selected.sources
"$resolver" all.sources app/main.sev again.sources
cmp selected.sources again.sources

printf 'modulo std.one\nusa std.missing\n' > std/one.sev
if "$resolver" all.sources app/main.sev must-fail.sources > /dev/null 2>&1; then
  echo 'missing imports must be rejected' >&2
  exit 1
fi

echo 'Seven source closure: passed'
