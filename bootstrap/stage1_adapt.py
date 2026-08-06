from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    if old not in text:
        raise RuntimeError(f"adaptation point not found: {label}")
    return text.replace(old, new, 1)


def patch_seven0_checker() -> None:
    path = Path("compiler0/check.sev")
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        'veja comando.especie == "retorno" :: devolve sim fecha',
        'veja comando.especie == "retorno" ou comando.especie == "falha" :: devolve sim fecha',
        "terminal flow",
    )
    path.write_text(text, encoding="utf-8")


def patch_seven0_named_variants() -> None:
    parse = Path("compiler0/parse.sev")
    text = parse.read_text(encoding="utf-8")
    if "campo parse_carga_variante(" not in text:
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
        text = replace_once(text, old, new, "named variant parser")
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
        text = text.replace(marker, "\n" + helper + marker, 1)
        parse.write_text(text, encoding="utf-8")

    emit = Path("compiler0/emit.sev")
    text = emit.read_text(encoding="utf-8")
    if "campo variante_por_nome(" not in text:
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
        text = replace_once(text, old, new, "named variant emitter")
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
        emit.write_text(text.replace(marker, "\n" + helper + marker, 1), encoding="utf-8")


def patch_token_classification() -> None:
    parser = Path("compiler/parser.sev")
    text = parser.read_text(encoding="utf-8")
    replacements = {
        "atual.tipo == Numero": "token_marca_numero(atual.marca)",
        'atual.tipo.tag == "Numero"': "token_marca_numero(atual.marca)",
        "atual.tipo == TextoLit": "token_marca_texto(atual)",
        'atual.tipo.tag == "TextoLit"': "token_marca_texto(atual)",
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
        "encontrado.tipo == TextoLit": "token_marca_texto(encontrado)",
        'encontrado.tipo.tag == "TextoLit"': "token_marca_texto(encontrado)",
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

campo token_marca_texto(valor: Token) -> Bit ::
  devolve sys_texto_tamanho(valor.marca) >= 2 e valor.literal != valor.marca
fecha
'''
        if marker not in text:
            raise RuntimeError("token_nome marker not found")
        text = text.replace(marker, "\n" + helpers + marker, 1)
    token.write_text(text, encoding="utf-8")


def patch_driver_trace() -> None:
    path = Path("compiler/driver.sev")
    text = path.read_text(encoding="utf-8")
    if '"stage1-fontes="' in text:
        return
    old_frontend = '''  guarda fontes := fonte_carrega_pacote(pedido.pacote)
  guarda tokens := varre_unidade(fontes)
  guarda sintaxe := monta_unidade(tokens)'''
    new_frontend = '''  guarda fontes := fonte_carrega_pacote(pedido.pacote)
  diga "stage1-fontes=" + texto(lista_tamanho(fontes.arquivos))
  guarda tokens := varre_unidade(fontes)
  diga "stage1-fluxos=" + texto(lista_tamanho(tokens))
  guarda sintaxe := monta_unidade(tokens)
  diga "stage1-programas=" + texto(lista_tamanho(sintaxe.programas))
  diga "stage1-diagnosticos-sintaxe=" + texto(lista_tamanho(sintaxe.diagnosticos))
  mostra_diagnosticos(sintaxe.diagnosticos)'''
    text = replace_once(text, old_frontend, new_frontend, "driver frontend trace")
    old_ir = '''  guarda meio := baixa_ir(sintaxe.programas, semantica.tipos, semantica.efeitos)
  guarda otimizado := otimiza_ir(meio, pedido.modo)'''
    new_ir = '''  guarda meio := baixa_ir(sintaxe.programas, semantica.tipos, semantica.efeitos)
  diga "stage1-ir-campos=" + texto(lista_tamanho(meio.campos))
  diga "stage1-ir-constantes=" + texto(lista_tamanho(meio.constantes))
  guarda otimizado := otimiza_ir(meio, pedido.modo)'''
    path.write_text(replace_once(text, old_ir, new_ir, "driver IR trace"), encoding="utf-8")


patch_seven0_checker()
patch_seven0_named_variants()
patch_token_classification()
patch_driver_trace()
