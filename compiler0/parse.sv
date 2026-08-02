modulo seven0.parse

usa seven0.primitives
usa seven0.token
usa seven0.ast
usa seven0.diagnostic

molde Parser ::
  fluxo: Fluxo
  pos: U64
  diagnosticos: ListaDiagnostico
fecha

campo montar(fluxo: Fluxo) -> Programa ::
  solta p := Parser {
    fluxo: fluxo,
    pos: 0,
    diagnosticos: lista_diagnostico()
  }

  guarda modulo_nome := parse_modulo(p)
  guarda usos := parse_usos(p)
  solta itens := lista_no()

  gira parse_fim(p) == nao ::
    lista_no_coloca(itens, parse_item(p))
  fecha

  devolve Programa {
    modulo: modulo_nome,
    usos: usos,
    itens: itens
  }
fecha

campo parse_item(p: Parser) -> No ::
  guarda t := parse_atual(p)

  veja t.marca == "const" ::
    devolve parse_const(p)
  outro ::
    veja t.marca == "molde" ::
      devolve parse_molde(p)
    outro ::
      veja t.marca == "selo" ::
        devolve parse_selo(p)
      outro ::
        veja t.marca == "campo" ::
          devolve parse_campo(p)
        outro ::
          falha "S0-PARSE-ESPERADO" "esperado item"
        fecha
      fecha
    fecha
  fecha
fecha
