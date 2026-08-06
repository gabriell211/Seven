from __future__ import annotations

import base64
import gzip
import hashlib
import re
from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise RuntimeError(f"missing block: {label}")
    return text.replace(old, new, 1)


def patch_seven0() -> None:
    parse = Path("compiler0/parse.sev")
    text = parse.read_text(encoding="utf-8")
    old = '''    veja parse_aceita(p, "(") ::
      veja nao parse_proximo(p, ")") ::
        lista_no_coloca(no_variante.filhos, no("carga", "", parse_tipo(p), "", variante.linha, variante.coluna))
        gira parse_aceita(p, ",") ::
          lista_no_coloca(no_variante.filhos, no("carga", "", parse_tipo(p), "", variante.linha, variante.coluna))
        fecha
      fecha
      parse_espera(p, ")", "S0-PARSE-VARIANTE", "esperado ) na variante")
    fecha'''
    new = '''    veja parse_aceita(p, "(") ::
      veja nao parse_proximo(p, ")") ::
        lista_no_coloca(no_variante.filhos, parse_carga_variante(p, variante))
        gira parse_aceita(p, ",") ::
          lista_no_coloca(no_variante.filhos, parse_carga_variante(p, variante))
        fecha
      fecha
      parse_espera(p, ")", "S0-PARSE-VARIANTE", "esperado ) na variante")
    fecha'''
    text = replace_once(text, old, new, "named seal payload parser")
    if "campo parse_carga_variante(" not in text:
        marker = "\ncampo parse_externo(p: Parser) -> No ::"
        helper = '''
campo parse_carga_variante(p: Parser, variante: Token) -> No ::
  solta nome := ""

  veja parse_atual(p).tipo == "nome" e parse_olha(p, 1).marca == ":" ::
    vira nome := parse_avanca(p).marca
    parse_espera(p, ":", "S0-PARSE-VARIANTE-CAMPO", "esperado : no campo da variante")
  fecha

  devolve no("carga", nome, parse_tipo(p), "", variante.linha, variante.coluna)
fecha
'''
        if marker not in text:
            raise RuntimeError("missing parse_externo marker")
        text = text.replace(marker, "\n" + helper + marker, 1)
    parse.write_text(text, encoding="utf-8")

    emit = Path("compiler0/emit.sev")
    text = emit.read_text(encoding="utf-8")
    old = '''campo emite_variante(contexto: ContextoCampo, expr: No) -> Nada ::
  emite_const_texto(contexto, "__tipo")
  emite_const_texto(contexto, expr.nome)
  emite_const_texto(contexto, "tag")
  emite_const_texto(contexto, expr.nome)
  solta argumentos: U32 := 4
  solta indice: U64 := 0

  para cada valor em expr.filhos ::
    veja lista_no_tamanho(expr.filhos) == 1 ::
      emite_const_texto(contexto, "valor")
    outro ::
      emite_const_texto(contexto, texto_u64(indice))
    fecha
    emite_expressao(contexto, valor)
    vira argumentos := argumentos + 2
    vira indice := indice + 1
  fecha

  emite_syscall(contexto, "sys_obj_novo", argumentos)
fecha'''
    new = '''campo emite_variante(contexto: ContextoCampo, expr: No) -> Nada ::
  emite_const_texto(contexto, "__tipo")
  emite_const_texto(contexto, expr.nome)
  emite_const_texto(contexto, "tag")
  emite_const_texto(contexto, expr.nome)
  solta argumentos: U32 := 4
  solta indice: U64 := 0
  guarda declaracao := variante_por_nome(contexto.emissao.unidade.programa, expr.nome)

  para cada valor em expr.filhos ::
    solta campo := ""
    veja declaracao.especie == "variante" e indice < lista_no_tamanho(declaracao.filhos) ::
      vira campo := lista_no_pega(declaracao.filhos, indice).nome
    fecha
    veja campo == "" e lista_no_tamanho(expr.filhos) == 1 :: vira campo := "valor" fecha
    veja campo == "" :: vira campo := texto_u64(indice) fecha

    emite_const_texto(contexto, campo)
    emite_expressao(contexto, valor)
    vira argumentos := argumentos + 2
    vira indice := indice + 1
  fecha

  emite_syscall(contexto, "sys_obj_novo", argumentos)
fecha'''
    text = replace_once(text, old, new, "named seal payload emitter")
    if "campo variante_por_nome(" not in text:
        marker = "\ncampo chamada_lista(nome: Texto) -> Bit ::"
        helper = '''
campo variante_por_nome(programa: Programa, nome: Texto) -> No ::
  solta indice_item: U64 := 0
  gira indice_item < lista_no_tamanho(programa.itens) ::
    guarda item := lista_no_pega(programa.itens, indice_item)
    veja item.especie == "selo" ::
      solta indice_variante: U64 := 0
      gira indice_variante < lista_no_tamanho(item.filhos) ::
        guarda variante := lista_no_pega(item.filhos, indice_variante)
        veja variante.especie == "variante" e variante.nome == nome :: devolve variante fecha
        vira indice_variante := indice_variante + 1
      fecha
    fecha
    vira indice_item := indice_item + 1
  fecha
  devolve no("ausente", "", "", "", 0, 0)
fecha
'''
        if marker not in text:
            raise RuntimeError("missing chamada_lista marker")
        text = text.replace(marker, "\n" + helper + marker, 1)
    emit.write_text(text, encoding="utf-8")


def patch_compiler_tokens() -> None:
    parser = Path("compiler/parser.sev")
    text = parser.read_text(encoding="utf-8")
    replacements = {
        "atual.tipo == Numero": "token_marca_numero(atual.marca)",
        'atual.tipo.tag == "Numero"': "token_marca_numero(atual.marca)",
        "atual.tipo == TextoLit": "token_marca_texto(atual.marca)",
        'atual.tipo.tag == "TextoLit"': "token_marca_texto(atual.marca)",
        "atual.tipo == Nome": "token_marca_nome(atual.marca)",
        'atual.tipo.tag == "Nome"': "token_marca_nome(atual.marca)",
        "t.tipo == Fim": 't.marca == ""',
        't.tipo.tag == "Fim"': 't.marca == ""',
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    parser.write_text(text, encoding="utf-8")

    cursor = Path("compiler/parser_cursor.sev")
    text = cursor.read_text(encoding="utf-8")
    replacements = {
        "atual_token(cursor).tipo == Fim": 'atual_token(cursor).marca == ""',
        'atual_token(cursor).tipo.tag == "Fim"': 'atual_token(cursor).marca == ""',
        "encontrado.tipo == Nome": "token_marca_nome(encontrado.marca)",
        'encontrado.tipo.tag == "Nome"': "token_marca_nome(encontrado.marca)",
        "encontrado.tipo == TextoLit": "token_marca_texto(encontrado.marca)",
        'encontrado.tipo.tag == "TextoLit"': "token_marca_texto(encontrado.marca)",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    cursor.write_text(text, encoding="utf-8")

    token = Path("compiler/token.sev")
    text = token.read_text(encoding="utf-8")
    text = text.replace("valor.tipo == Nome", "token_marca_nome(valor.marca)")
    text = text.replace('valor.tipo.tag == "Nome"', "token_marca_nome(valor.marca)")
    if "campo token_marca_nome(" not in text:
        marker = "\ncampo token_nome(valor: Token) -> Bit ::"
        helpers = '''
campo token_marca_letra(caractere: Texto) -> Bit ::
  devolve (caractere >= "a" e caractere <= "z") ou (caractere >= "A" e caractere <= "Z") ou caractere == "_"
fecha

campo token_marca_digito(caractere: Texto) -> Bit ::
  devolve caractere >= "0" e caractere <= "9"
fecha

campo token_marca_nome(marca: Texto) -> Bit ::
  guarda total := sys_texto_tamanho(marca)
  veja total == 0 ou nao token_marca_letra(sys_texto_caractere(marca, 0)) :: devolve nao fecha
  solta indice: U64 := 1
  gira indice < total ::
    guarda caractere := sys_texto_caractere(marca, indice)
    veja nao token_marca_letra(caractere) e nao token_marca_digito(caractere) :: devolve nao fecha
    vira indice := indice + 1
  fecha
  devolve sim
fecha

campo token_marca_numero(marca: Texto) -> Bit ::
  devolve sys_texto_tamanho(marca) > 0 e token_marca_digito(sys_texto_caractere(marca, 0))
fecha

campo token_marca_texto(marca: Texto) -> Bit ::
  devolve sys_texto_tamanho(marca) >= 2 e sys_texto_caractere(marca, 0) == "\""
fecha
'''
        if marker not in text:
            raise RuntimeError("missing token_nome marker")
        text = text.replace(marker, "\n" + helpers + marker, 1)
    token.write_text(text, encoding="utf-8")


def patch_genesis_host() -> tuple[str, str]:
    packed_path = Path("bootstrap/staging/genesis-host.c.gz.b64")
    packed = base64.b64decode(b"".join(packed_path.read_bytes().split()))
    source = gzip.decompress(packed).decode("utf-8")
    old = 'static int value_eq(Value a,Value b){ if(a.tag==b.tag){switch(a.tag){case V_NULL:return 1;case V_INT:return a.as.i==b.as.i;case V_BOOL:return a.as.b==b.as.b;case V_STRING:return str_eq(a.as.s,b.as.s);default:return a.as.obj==b.as.obj;}} if((a.tag==V_INT||a.tag==V_BOOL)&&(b.tag==V_INT||b.tag==V_BOOL))return number(a)==number(b);return 0; }'
    new = '''static int value_eq(Value a,Value b){
 if(a.tag==b.tag){
  switch(a.tag){
   case V_NULL:return 1;
   case V_INT:return a.as.i==b.as.i;
   case V_BOOL:return a.as.b==b.as.b;
   case V_STRING:return str_eq(a.as.s,b.as.s);
   case V_BYTES:return a.as.bytes->len==b.as.bytes->len && memcmp(a.as.bytes->data,b.as.bytes->data,a.as.bytes->len)==0;
   case V_LIST:
    if(a.as.list==b.as.list)return 1;
    if(a.as.list->len!=b.as.list->len)return 0;
    for(size_t i=0;i<a.as.list->len;i++)if(!value_eq(a.as.list->items[i],b.as.list->items[i]))return 0;
    return 1;
   case V_OBJECT:
    if(a.as.obj==b.as.obj)return 1;
    if(a.as.obj->len!=b.as.obj->len)return 0;
    for(size_t i=0;i<a.as.obj->len;i++){
     int j=obj_index(b.as.obj,a.as.obj->pairs[i].key);
     if(j<0||!value_eq(a.as.obj->pairs[i].value,b.as.obj->pairs[j].value))return 0;
    }
    return 1;
   case V_ITER:return a.as.iter==b.as.iter;
  }
 }
 if((a.tag==V_INT||a.tag==V_BOOL)&&(b.tag==V_INT||b.tag==V_BOOL))return number(a)==number(b);
 return 0;
}'''
    if old in source:
        source = source.replace(old, new, 1)
    elif "case V_BYTES:" not in source:
        raise RuntimeError("Genesis equality implementation not found")

    source_bytes = source.encode("utf-8")
    packed_bytes = gzip.compress(source_bytes, compresslevel=9, mtime=0)
    packed_path.write_bytes(base64.b64encode(packed_bytes) + b"\n")
    return hashlib.sha256(packed_path.read_bytes()).hexdigest(), hashlib.sha256(source_bytes).hexdigest()


def patch_stage0_workflow(packed_hash: str, host_hash: str) -> None:
    path = Path(".github/workflows/stage0-fixed-point.yml")
    text = path.read_text(encoding="utf-8")
    text = re.sub(r"[0-9a-f]{64}  bootstrap/staging/genesis-host\.c\.gz\.b64", packed_hash + "  bootstrap/staging/genesis-host.c.gz.b64", text)
    text = re.sub(r"[0-9a-f]{64}  build/genesis-host\.c", host_hash + "  build/genesis-host.c", text)
    text = re.sub(r"          echo '[0-9a-f]{64}  build/seven0\.monolith\.sev' \| sha256sum --check\n", "          sha256sum build/seven0.monolith.sev | tee build/seven0-source.sha256\n", text)
    text = re.sub(r"          echo '[0-9a-f]{64}  build/seven0\.svbc' \| sha256sum --check\n          test \"\$\(wc -c < build/seven0\.svbc \| tr -d ' '\)\" = '[0-9]+'\n", "          sha256sum build/seven0.svbc | tee build/seven0-output.sha256\n          wc -c build/seven0.svbc | tee build/seven0-output.size\n", text)
    text = re.sub(r"          echo '[0-9a-f]{64}  build/stage0-proof\.svbc' \| sha256sum --check\n          test \"\$\(wc -c < build/stage0-proof\.svbc \| tr -d ' '\)\" = '[0-9]+'\n", "          sha256sum build/stage0-proof.svbc | tee build/stage0-proof.sha256\n          wc -c build/stage0-proof.svbc | tee build/stage0-proof.size\n", text)
    text = text.replace("          host_hash=$(sha256sum \"${{ matrix.host }}\" | awk '{print $1}')\n", "          host_hash=$(sha256sum \"${{ matrix.host }}\" | awk '{print $1}')\n          source_hash=$(sha256sum build/seven0.monolith.sev | awk '{print $1}')\n          output_hash=$(sha256sum build/seven0.svbc | awk '{print $1}')\n          proof_hash=$(sha256sum build/stage0-proof.svbc | awk '{print $1}')\n")
    text = re.sub(r"          entrada_sha256 [0-9a-f]{64}", "          entrada_sha256 $source_hash", text)
    text = re.sub(r"          saida_sha256 [0-9a-f]{64}", "          saida_sha256 $output_hash", text)
    text = re.sub(r"          prova_sha256 [0-9a-f]{64}", "          prova_sha256 $proof_hash", text)
    path.write_text(text, encoding="utf-8")


def install_permanent_workflow(packed_hash: str, host_hash: str) -> None:
    source = Path("bootstrap/stage1-workflow.final")
    target = Path(".github/workflows/stage1-compiler-probe.yml")
    text = source.read_text(encoding="utf-8")
    marker = "          base64 --decode bootstrap/staging/genesis-host.c.gz.b64 | gzip --decompress > build/genesis-host.c\n"
    replacement = marker + f"          echo '{packed_hash}  bootstrap/staging/genesis-host.c.gz.b64' | sha256sum --check\n          echo '{host_hash}  build/genesis-host.c' | sha256sum --check\n"
    if marker not in text:
        raise RuntimeError("permanent workflow host marker not found")
    target.write_text(text.replace(marker, replacement, 1), encoding="utf-8")


def cleanup() -> None:
    for name in (
        ".github/workflows/stage1-canonicalize.yml",
        "bootstrap/stage1-workflow.final",
        "bootstrap/stage1_finalize.py",
        "bootstrap/stage1_adapt.py",
        "bootstrap/stage1_host_adapt.py",
        "bootstrap/stage1.status",
    ):
        Path(name).unlink(missing_ok=True)


patch_seven0()
patch_compiler_tokens()
packed_sha, host_sha = patch_genesis_host()
patch_stage0_workflow(packed_sha, host_sha)
install_permanent_workflow(packed_sha, host_sha)
cleanup()
