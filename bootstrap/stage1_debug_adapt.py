from pathlib import Path


def replace_function(text: str, name: str, replacement: str) -> str:
    start = text.find(f"campo {name}(")
    if start < 0:
        raise RuntimeError(f"function not found: {name}")
    end = text.find("\nfecha", start)
    if end < 0:
        raise RuntimeError(f"function end not found: {name}")
    end += len("\nfecha")
    return text[:start] + replacement + text[end:]


def patch_text_token_detection() -> None:
    token = Path("compiler/token.sev")
    text = token.read_text(encoding="utf-8")
    replacement = '''campo token_marca_texto(valor: Token) -> Bit ::
  devolve sys_texto_tamanho(valor.marca) >= 2 e valor.literal != valor.marca
fecha'''
    text = replace_function(text, "token_marca_texto", replacement)
    token.write_text(text, encoding="utf-8")

    parser = Path("compiler/parser.sev")
    text = parser.read_text(encoding="utf-8")
    text = text.replace("token_marca_texto(atual.marca)", "token_marca_texto(atual)")
    parser.write_text(text, encoding="utf-8")

    cursor = Path("compiler/parser_cursor.sev")
    text = cursor.read_text(encoding="utf-8")
    text = text.replace("token_marca_texto(encontrado.marca)", "token_marca_texto(encontrado)")
    cursor.write_text(text, encoding="utf-8")


def patch_pipeline_trace() -> None:
    path = Path("compiler/driver.sev")
    text = path.read_text(encoding="utf-8")

    flow_marker = '  diga "stage1-fluxos=" + texto(lista_tamanho(tokens))\n'
    flow_debug = '''  diga "stage1-fluxos=" + texto(lista_tamanho(tokens))
  veja lista_tamanho(tokens) > 0 ::
    guarda fluxo_debug := lista_pega(tokens, 0)
    diga "stage1-tokens=" + texto(lista_tamanho(fluxo_debug.tokens))
    solta indice_debug: U64 := 0
    gira indice_debug < lista_tamanho(fluxo_debug.tokens) e indice_debug < 12 ::
      diga "stage1-token=" + texto(indice_debug) + ":" + lista_pega(fluxo_debug.tokens, indice_debug).marca
      vira indice_debug := indice_debug + 1
    fecha
  fecha
'''
    if "stage1-tokens=" not in text:
        if flow_marker not in text:
            raise RuntimeError("flow trace marker not found")
        text = text.replace(flow_marker, flow_debug, 1)

    program_marker = '  diga "stage1-programas=" + texto(lista_tamanho(sintaxe.programas))\n'
    program_debug = '''  diga "stage1-programas=" + texto(lista_tamanho(sintaxe.programas))
  veja lista_tamanho(sintaxe.programas) > 0 ::
    guarda programa_debug := lista_pega(sintaxe.programas, 0)
    diga "stage1-modulo=" + programa_debug.modulo
    diga "stage1-itens=" + texto(lista_tamanho(programa_debug.itens))
  fecha
'''
    if "stage1-itens=" not in text:
        if program_marker not in text:
            raise RuntimeError("program trace marker not found")
        text = text.replace(program_marker, program_debug, 1)

    path.write_text(text, encoding="utf-8")


patch_text_token_detection()
patch_pipeline_trace()
