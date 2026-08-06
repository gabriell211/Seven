from pathlib import Path


def patch_parser() -> None:
    path = Path("compiler0/parse.sev")
    text = path.read_text(encoding="utf-8")
    if "campo parse_carga_variante(" in text:
        return

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
    if old not in text:
        raise RuntimeError("variant parser block not found")
    text = text.replace(old, new)

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
        raise RuntimeError("parse_externo marker not found")
    path.write_text(text.replace(marker, "\n" + helper + marker, 1), encoding="utf-8")


def patch_emitter() -> None:
    path = Path("compiler0/emit.sev")
    text = path.read_text(encoding="utf-8")
    if "campo variante_por_nome(" in text:
        return

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
    if old not in text:
        raise RuntimeError("variant emitter block not found")
    text = text.replace(old, new)

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
        raise RuntimeError("chamada_lista marker not found")
    path.write_text(text.replace(marker, "\n" + helper + marker, 1), encoding="utf-8")


patch_parser()
patch_emitter()
