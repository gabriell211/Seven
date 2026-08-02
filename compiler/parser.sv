modulo seven.compiler.parser

usa seven.compiler.token
usa seven.compiler.ast
usa seven.compiler.diagnostic

molde CursorTokens ::
  fluxo: FluxoTokens
  posicao: U64
  diagnosticos: Lista<Diagnostico>
fecha

campo monta_unidade(fluxos: Lista<FluxoTokens>) -> Lista<Programa> ::
  solta programas := lista<Programa>()

  para cada fluxo em fluxos ::
    lista_coloca(programas, monta(fluxo))
  fecha

  devolve programas
fecha

campo monta(fluxo: FluxoTokens) -> Programa ::
  solta cursor := CursorTokens {
    fluxo: fluxo,
    posicao: 0,
    diagnosticos: lista<Diagnostico>()
  }

  guarda modulo_nome := ler_modulo_opcional(cursor)
  guarda usos := ler_usos(cursor)
  solta itens := lista<Item>()

  gira nao fim(cursor) ::
    lista_coloca(itens, ler_item(cursor))
  fecha

  devolve Programa {
    modulo: modulo_nome,
    usos: usos,
    itens: itens
  }
fecha

campo ler_item(cursor: CursorTokens) -> Item ::
  veja proximo_e(cursor, "campo") ::
    devolve ItemCampo(ler_campo(cursor))
  outro ::
    veja proximo_e(cursor, "molde") ::
      devolve ItemMolde(ler_molde(cursor))
    outro ::
      veja proximo_e(cursor, "selo") ::
        devolve ItemSelo(ler_selo(cursor))
      outro ::
        devolve ItemConst(ler_constante(cursor))
      fecha
    fecha
  fecha
fecha
