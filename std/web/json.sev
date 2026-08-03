modulo std.web.json

usa std.base.resultado

selo Json ::
  JNulo
  JBit(valor: Bit)
  JNum(valor: Num)
  JTexto(valor: Texto)
  JLista(valor: Lista<Json>)
  JObjeto(valor: Lista<JsonCampo>)
fecha

molde JsonCampo ::
  nome: Texto
  valor: Json
fecha

campo json_campo(nome: Texto, valor: Json) -> JsonCampo ::
  devolve JsonCampo {
    nome: nome,
    valor: valor
  }
fecha

campo json_texto(valor: Texto) -> Json ::
  devolve JTexto(valor)
fecha

campo json_num(valor: Num) -> Json ::
  devolve JNum(valor)
fecha

campo json_objeto(campos: Lista<JsonCampo>) -> Json ::
  devolve JObjeto(campos)
fecha

campo json_codifica(valor: Json) -> Texto ::
  veja valor e JNulo ::
    devolve "null"
  outro ::
    veja valor e JBit ::
      veja valor.valor ::
        devolve "true"
      outro ::
        devolve "false"
      fecha
    outro ::
      veja valor e JNum ::
        devolve texto(valor.valor)
      outro ::
        veja valor e JTexto ::
          devolve "\"" + json_escape(valor.valor) + "\""
        outro ::
          devolve json_composto(valor)
        fecha
      fecha
    fecha
  fecha
fecha

campo json_parse(texto_json: Texto) -> Resultado<Json, Falha> ::
  devolve json_parser(texto_json)
fecha

campo json_composto(valor: Json) -> Texto ::
  devolve sys_json_codifica(valor)
fecha

campo json_parser(texto_json: Texto) -> Resultado<Json, Falha> ::
  devolve sys_json_parse(texto_json)
fecha
