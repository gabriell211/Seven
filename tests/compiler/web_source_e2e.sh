#!/usr/bin/env bash
set -euo pipefail

mkdir -p build/web-e2e

cat bootstrap/seed/v2/part*.b64 | tr -d '\r\n\t ' | base64 --decode | gzip --decompress > build/seven0.seed.svbc
echo '123f5b513bcae7774671898f471441b3c71efd570acad91fa634cbc5f33bb223  build/seven0.seed.svbc' | sha256sum --check
(cd bootstrap/host/v2 && sha256sum --check SHA256SUMS)

# O compilador Web atual usa o intrinseco sys_num_mod para codificar LEB/U32.
# Genesis ja implementa modulo no operador binario, mas o dispatcher historico
# nao expos esse alias. O gate adiciona somente esse alias em uma copia temporaria
# para executar o compilador atual sem mutar a raiz de confianca versionada.
cp -R bootstrap/host/v2 build/genesis-web-host
sed -i '/#define IS(x) str_eq_c(name,x)/a\ if(IS("sys_num_mod")){if(argc<2){vm_fail(vm,"sys_num_mod expects two arguments");return v_null();}int64_t d=number(args[1]);if(!d){vm_fail(vm,"modulo by zero");return v_null();}return v_int(number(args[0])%d);}' \
  build/genesis-web-host/genesis-host.part02.inc
gcc -O2 -std=c11 -Wall -Wextra -Werror build/genesis-web-host/genesis-host.c -o build/genesis-host

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
test "$(od -An -tx1 -N4 build/seven0.svbc | tr -d ' \n')" = '53564230'

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
compiler/parser_part00.sev
compiler/parser_part01.sev
compiler/parser_part02.sev
compiler/parser_part03.sev
compiler/parser_part04.sev
compiler/parser_part05.sev
compiler/parser_cursor.sev
compiler/semantic.sev
compiler/source.sev
compiler/symbols.sev
compiler/token.sev
compiler/types_part00.sev
compiler/types_part01.sev
compiler/types_part02.sev
compiler/types_part03.sev
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
test -s build/seven.stage1.svbc
test "$(od -An -tx1 -N4 build/seven.stage1.svbc | tr -d ' \n')" = '53564230'

cat > build/web-e2e.parts <<'EOF'
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
compiler/parser_part00.sev
compiler/parser_part01.sev
compiler/parser_part02.sev
compiler/parser_part03.sev
compiler/parser_part04.sev
compiler/parser_part05.sev
compiler/parser_cursor.sev
compiler/semantic.sev
compiler/source.sev
compiler/symbols.sev
compiler/token.sev
compiler/types_part00.sev
compiler/types_part01.sev
compiler/types_part02.sev
compiler/types_part03.sev
compiler/wasm.sev
compiler/web_ir.sev
tests/compiler/web_source_e2e.sev
EOF

{
  printf 'modulo seven_web_e2e_monolith\n\n'
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
  done < build/web-e2e.parts
} > build/web-e2e.monolith.sev

printf '%s\n' 'build/web-e2e.monolith.sev' > build/web-e2e.sources
cat > build/web-e2e.pkg <<'EOF'
pacote seven-web-source-e2e
versao 0.2.0
criador Gabriel Barcelos
entrada seven_web_e2e_monolith.inicio
alvo svbc
indice build/web-e2e.sources
EOF

build/genesis-host build/seven.stage1.svbc build/web-e2e.pkg build/web-e2e.svbc
test -s build/web-e2e.svbc
test "$(od -An -tx1 -N4 build/web-e2e.svbc | tr -d ' \n')" = '53564243'

build/genesis-host build/web-e2e.svbc examples/web_app.sev build/web-e2e/web_app.wasm
build/genesis-host build/web-e2e.svbc website/site.sev build/web-e2e/site.wasm

test -s build/web-e2e/web_app.wasm
test -s build/web-e2e/site.wasm
test "$(od -An -tx1 -N4 build/web-e2e/web_app.wasm | tr -d ' \n')" = '0061736d'
test "$(od -An -tx1 -N4 build/web-e2e/site.wasm | tr -d ' \n')" = '0061736d'

web_hash=$(sha256sum build/web-e2e/web_app.wasm | awk '{print $1}')
site_hash=$(sha256sum build/web-e2e/site.wasm | awk '{print $1}')
echo "web_app_sha256=$web_hash"
echo "site_sha256=$site_hash"
test "$web_hash" != "$site_hash"

node - build/web-e2e/web_app.wasm build/web-e2e/site.wasm <<'JS'
const fs = require('fs');

const importNames = [
  'terminal_diga',
  'frontend_monta',
  'frontend_texto',
  'frontend_atributo',
  'frontend_classe_adiciona',
  'frontend_classe_remove',
  'frontend_escuta',
  'frontend_navega',
  'frontend_injeta_css',
  'frontend_fetch_texto',
  'frontend_resposta_texto',
  'frontend_resposta_status',
  'frontend_evento_valor',
  'frontend_armazena',
  'frontend_carrega',
  'frontend_remove',
  'sys_numero',
  'sys_texto_num',
  'sys_texto_u64',
  'sys_texto_concat',
  'sys_obj_novo',
  'sys_obj_pega',
  'sys_obj_define',
  'sys_lista_coloca',
  'sys_lista_pega',
  'sys_lista_define',
  'sys_lista_insere',
  'sys_lista_remove',
  'sys_lista_pop',
  'sys_css_renderiza',
  'sys_html_renderiza'
];

async function execute(path) {
  const bytes = fs.readFileSync(path);
  if (!WebAssembly.validate(bytes)) throw new Error(`${path}: WebAssembly invalido`);

  let memory;
  const calls = [];
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();
  const decode = descriptor => {
    if (!descriptor) return '';
    const view = new DataView(memory.buffer);
    const pointer = view.getUint32(descriptor, true);
    const length = view.getUint32(descriptor + 4, true);
    return decoder.decode(new Uint8Array(memory.buffer, pointer, length));
  };
  const writeInbox = value => {
    const bytes = encoder.encode(String(value));
    const pointer = 32776;
    new Uint8Array(memory.buffer, pointer, bytes.length).set(bytes);
    const view = new DataView(memory.buffer);
    view.setUint32(32768, pointer, true);
    view.setUint32(32772, bytes.length, true);
    return 32768;
  };
  const handles = new Map();
  let nextHandle = 1048576;
  const storeHandle = value => {
    const handle = nextHandle++;
    handles.set(handle, value);
    return handle;
  };
  const isHandle = value => handles.has(value);
  const ref = value => handles.get(value);
  const looksText = value => {
    if (!value || isHandle(value) || value < 0 || value + 8 > memory.buffer.byteLength) return false;
    const view = new DataView(memory.buffer);
    const pointer = view.getUint32(value, true);
    const length = view.getUint32(value + 4, true);
    return pointer >= 8 && pointer + length <= memory.buffer.byteLength;
  };
  const fromSeven = value => isHandle(value) ? value : (looksText(value) ? decode(value) : (value | 0));
  const toSeven = value => typeof value === 'string' ? writeInbox(value) : (value || 0);
  const textFields = new Set(['__tipo', 'tag', 'nome', 'valor', 'seletor', 'consulta', 'ponto', 'alvo']);
  const fieldFromSeven = (key, value) => isHandle(value) ? value : (textFields.has(key) ? decode(value) : fromSeven(value));
  const escapeHtml = value => String(value ?? '').replace(/[&<>"]/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
  const createObject = args => {
    const object = { type: 'objeto', fields: Object.create(null), items: [] };
    for (let i = 0; i + 1 < args.length; i += 2) {
      const key = decode(args[i]);
      const value = fieldFromSeven(key, args[i + 1]);
      object.fields[key] = value;
      if (key === '__tipo') object.type = String(value);
    }
    if (object.type === 'Lista') object.items = [];
    if (object.fields.tamanho === undefined && object.items) object.fields.tamanho = object.items.length;
    return storeHandle(object);
  };
  const field = (object, name) => {
    const target = isHandle(object) ? ref(object) : object;
    if (!target) return 0;
    if (name === 'tamanho' && target.items) return target.items.length;
    return target.fields?.[name] ?? 0;
  };
  const asArray = value => {
    const target = isHandle(value) ? ref(value) : value;
    return target?.items ?? [];
  };
  const cssDecls = list => asArray(list).map(item => {
    const decl = ref(item);
    return `${field(decl, 'nome')}:${field(decl, 'valor')};`;
  }).join('');
  const renderCss = folhaHandle => {
    const folha = ref(folhaHandle);
    if (!folha) return '';
    let css = '';
    const variaveis = cssDecls(field(folha, 'variaveis'));
    if (variaveis) css += `:root{${variaveis}}`;
    for (const regraHandle of asArray(field(folha, 'regras'))) {
      const regra = ref(regraHandle);
      css += `${field(regra, 'seletor')}{${cssDecls(field(regra, 'declaracoes'))}}`;
    }
    return css;
  };
  const renderHtmlNode = nodeHandle => {
    if (!isHandle(nodeHandle)) return escapeHtml(nodeHandle);
    const node = ref(nodeHandle);
    if (!node) return '';
    if (node.type === 'TextoNo') return escapeHtml(field(node, 'valor'));
    if (node.type === 'ElementoNo') return renderElement(field(node, 'valor'));
    if (node.type === 'Elemento') return renderElement(nodeHandle);
    return '';
  };
  const renderElement = elementHandle => {
    const element = isHandle(elementHandle) ? ref(elementHandle) : elementHandle;
    if (!element) return '';
    const name = String(field(element, 'nome') || 'div');
    const attrs = asArray(field(element, 'atributos')).map(attrHandle => {
      const attr = ref(attrHandle);
      return ` ${field(attr, 'nome')}="${escapeHtml(field(attr, 'valor'))}"`;
    }).join('');
    const children = asArray(field(element, 'filhos')).map(renderHtmlNode).join('');
    return `<${name}${attrs}>${children}</${name}>`;
  };

  const seven = {};
  for (const name of importNames) {
    seven[name] = (...args) => {
      if (name === 'sys_numero') {
        calls.push({ name, args: args.map(decode) });
        return Number.parseInt(decode(args[0]), 10) || 0;
      }
      if (name === 'sys_texto_num' || name === 'sys_texto_u64') {
        calls.push({ name, args: args.map(String) });
        return writeInbox(args[0] >>> 0);
      }
      if (name === 'sys_texto_concat') {
        calls.push({ name, args: args.map(decode) });
        return writeInbox(decode(args[0]) + decode(args[1]));
      }
      if (name === 'sys_css_renderiza' || name === 'sys_html_renderiza') {
        calls.push({ name, args: args.map(String) });
        return name === 'sys_css_renderiza'
          ? writeInbox(renderCss(args[0]))
          : writeInbox(renderElement(args[0]));
      }
      if (name === 'sys_obj_novo') {
        calls.push({ name, args: args.map(value => value > 0 ? String(value) : '0') });
        return createObject(args);
      }
      if (name.startsWith('sys_obj_') || name.startsWith('sys_lista_')) {
        calls.push({ name, args: args.map(String) });
        if (name === 'sys_obj_pega') return toSeven(field(args[0], decode(args[1])));
        if (name === 'sys_obj_define') {
          const target = ref(args[0]);
          const key = decode(args[1]);
          if (target) target.fields[key] = fieldFromSeven(key, args[2]);
          return args[0] || 0;
        }
        if (name === 'sys_lista_coloca') {
          const target = ref(args[0]);
          if (target) {
            target.items.push(fromSeven(args[1]));
            target.fields.tamanho = target.items.length;
          }
          return args[0] || 0;
        }
        if (name === 'sys_lista_pega') return toSeven(ref(args[0])?.items?.[args[1] >>> 0] ?? 0);
        if (name === 'sys_lista_define') {
          const target = ref(args[0]);
          if (target) target.items[args[1] >>> 0] = fromSeven(args[2]);
          return args[0] || 0;
        }
        if (name === 'sys_lista_insere') {
          const target = ref(args[0]);
          if (target) {
            target.items.splice(args[1] >>> 0, 0, fromSeven(args[2]));
            target.fields.tamanho = target.items.length;
          }
          return args[0] || 0;
        }
        if (name === 'sys_lista_remove') {
          const target = ref(args[0]);
          if (!target) return 0;
          const [removed] = target.items.splice(args[1] >>> 0, 1);
          target.fields.tamanho = target.items.length;
          return toSeven(removed ?? 0);
        }
        if (name === 'sys_lista_pop') {
          const target = ref(args[0]);
          if (!target) return 0;
          const removed = target.items.pop();
          target.fields.tamanho = target.items.length;
          return toSeven(removed ?? 0);
        }
        return args[0] || 0;
      }
      calls.push({ name, args: args.map(decode) });
      return 0;
    };
  }

  const { instance } = await WebAssembly.instantiate(bytes, { seven });
  memory = instance.exports.memory;
  const code = instance.exports.seven_start();
  if (code !== 0) throw new Error(`${path}: seven_start retornou ${code}`);
  return { instance, calls };
}

(async () => {
  const web = await execute(process.argv[2]);
  const webNames = web.calls.map(call => call.name);
  for (const required of ['frontend_injeta_css', 'frontend_monta', 'frontend_escuta']) {
    if (!webNames.includes(required)) throw new Error(`web_app sem chamada ${required}`);
  }
  if (web.calls.filter(call => call.name === 'frontend_escuta').length !== 2) {
    throw new Error('web_app deve registrar exatamente dois listeners');
  }
  const webMount = web.calls.find(call => call.name === 'frontend_monta');
  if (webMount.args[0] !== '#seven-app' || !webMount.args[1].includes('<h1>Seven Web</h1>')) {
    throw new Error(`web_app montou DOM inesperado: ${JSON.stringify(webMount.args)}`);
  }
  for (const handler of ['seven_saudar', 'seven_carregar', 'seven_recebe_manifesto']) {
    if (typeof web.instance.exports[handler] !== 'function') throw new Error(`handler nao exportado: ${handler}`);
  }

  const site = await execute(process.argv[3]);
  const siteNames = site.calls.map(call => call.name);
  for (const required of ['frontend_texto', 'frontend_monta', 'frontend_injeta_css', 'frontend_escuta']) {
    if (!siteNames.includes(required)) throw new Error(`website sem chamada ${required}`);
  }
  const siteMount = site.calls.find(call => call.name === 'frontend_monta');
  if (siteMount.args[0] !== '#seven-app' || !siteMount.args[1].includes('Controle de baixo nivel')) {
    throw new Error('website perdeu o HTML concatenado durante lowering');
  }
  const siteCss = site.calls.find(call => call.name === 'frontend_injeta_css');
  if (!siteCss.args[0].includes(':root{color-scheme:dark')) {
    throw new Error('website perdeu o CSS concatenado durante lowering');
  }

  console.log(`web_app calls: ${web.calls.length}`);
  console.log(`website calls: ${site.calls.length}`);
})().catch(error => {
  console.error(error);
  process.exit(1);
});
JS
