#!/usr/bin/env bash
set -euo pipefail

mkdir -p build

if [[ ! -s build/seven.stage1.svbc || ! -x build/genesis-host ]]; then
  bash tests/compiler/web_source_e2e.sh
fi

{
  printf 'modulo seven_transition_monolith\n\n'
  while IFS= read -r arquivo; do
    [[ -n "$arquivo" ]] || continue
    printf '// BEGIN %s\n' "$arquivo"
    case "$arquivo" in
      compiler/bytecode.sev)
        sed '/^modulo /d; /^usa /d; s/emite_constante(/bytecode_emite_constante(/g' "$arquivo"
        ;;
      compiler/emitter.sev)
        sed '/^modulo /d; /^usa /d; s/^campo emite(/campo emite_formato(/' "$arquivo"
        ;;
      *)
        sed '/^modulo /d; /^usa /d' "$arquivo"
        ;;
    esac
    printf '// END %s\n\n' "$arquivo"
  done < compiler/toolchain/transition.sources
} > build/seven.transition.monolith.sev

printf '%s\n' 'build/seven.transition.monolith.sev' > build/transition.sources
cat > build/transition.pkg <<'EOF'
pacote seven-transition
versao 0.2.0
criador Gabriel Barcelos
entrada seven_transition_monolith.inicio
alvo svbc
indice build/transition.sources
EOF

build/genesis-host build/seven.stage1.svbc build/transition.pkg build/seven.transition.svbc
build/genesis-host build/seven.stage1.svbc build/transition.pkg build/seven.transition.self.svbc

cmp build/seven.transition.svbc build/seven.transition.self.svbc
test -s build/seven.transition.svbc
test "$(od -An -tx1 -N4 build/seven.transition.svbc | tr -d ' \n')" = '53564243'

sha256sum build/seven.transition.svbc
