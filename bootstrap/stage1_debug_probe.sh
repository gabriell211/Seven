#!/usr/bin/env bash
set -euo pipefail

mkdir -p build
python bootstrap/stage1_nao_adapt.py
python bootstrap/stage1_adapt.py
python bootstrap/stage1_debug_adapt.py

cat bootstrap/seed/v2/part*.b64 | tr -d '\r\n\t ' | base64 --decode | gzip --decompress > build/seven0.seed.svbc
echo '123f5b513bcae7774671898f471441b3c71efd570acad91fa634cbc5f33bb223  build/seven0.seed.svbc' | sha256sum --check
base64 --decode bootstrap/staging/genesis-host.c.gz.b64 | gzip --decompress > build/genesis-host.c
echo '2f71509466eee470a5379d750b067a7e1733c0a4c1c8dd56542eb6bd5d0ec1d1  build/genesis-host.c' | sha256sum --check
python bootstrap/stage1_host_adapt.py build/genesis-host.c
gcc -O2 -std=c11 -Wall -Wextra -Werror build/genesis-host.c -o build/genesis-host

{
  printf 'modulo seven0_bootstrap_monolith\n\n'
  for arquivo in $(find compiler0 -maxdepth 1 -type f -name '*.sev' | LC_ALL=C sort); do
    printf '// BEGIN %s\n' "$(basename "$arquivo")"
    sed '/^modulo /d; /^usa /d' "$arquivo"
    printf '// END %s\n\n' "$(basename "$arquivo")"
  done
} > build/seven0.monolith.sev

build/genesis-host build/seven0.seed.svbc build/seven0.monolith.sev build/seven0.svbc
build/genesis-host build/seven0.svbc build/seven0.monolith.sev build/seven0.self.svbc
cmp build/seven0.svbc build/seven0.self.svbc

cat > build/stage1.sources <<'EOF'
std/base/lista.sev
std/base/resultado.sev
std/base/talvez.sev
std/base/mapa.sev
std/base/texto.sev
std/mem/bytes.sev
std/fs/file.sev
compiler/ast.sev
compiler/bytecode.sev
compiler/diagnostic.sev
compiler/driver.sev
compiler/effects.sev
compiler/emitter.sev
compiler/ffi.sev
compiler/ir.sev
compiler/lexer.sev
compiler/memory.sev
compiler/package.sev
compiler/parser.sev
compiler/parser_cursor.sev
compiler/semantic.sev
compiler/source.sev
compiler/symbols.sev
compiler/token.sev
compiler/types.sev
EOF

{
  printf 'modulo seven_stage1_monolith\n\n'
  while IFS= read -r arquivo; do
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
  done < build/stage1.sources

  cat <<'EOF'
campo inicio(argumentos: Lista<Texto>) -> Num toca terminal, disco, ambiente ::
  guarda pedido := pedido_de_compilacao(argumentos)
  guarda saida := compila(pedido)
  veja saida e Sucesso ::
    devolve 0
  outro ::
    mostra_diagnosticos(saida.diagnosticos)
    devolve 1
  fecha
fecha
EOF
} > build/seven.stage1.monolith.sev

build/genesis-host build/seven0.svbc build/seven.stage1.monolith.sev build/seven.stage1.svbc

cat > build/stage1-proof.sev <<'EOF'
modulo stage1.prova

campo inicio() -> Num ::
  devolve 42
fecha
EOF
printf '%s\n' 'build/stage1-proof.sev' > build/stage1-proof.sources
cat > build/stage1-proof.pkg <<'EOF'
pacote stage1-proof
versao 0.0.1
criador Gabriel Barcelos
entrada stage1.prova.inicio
alvo svbc
indice build/stage1-proof.sources
EOF

set +e
build/genesis-host build/seven.stage1.svbc build/stage1-proof.pkg build/stage1-proof.svbc 2>&1 | tee build/stage1-debug.log
code=${PIPESTATUS[0]}
set -e
printf '%s\n' "$code" > build/stage1-debug.exit

if test -f build/stage1-proof.svbc; then
  wc -c build/stage1-proof.svbc
  sha256sum build/stage1-proof.svbc
  od -An -tx1 -N32 build/stage1-proof.svbc
fi

exit 0
