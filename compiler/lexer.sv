modulo seven.compiler.lexer

usa seven.compiler.source
usa seven.compiler.token
usa seven.compiler.diagnostic

molde EstadoVarredura ::
  fonte: Fonte
  cursor: U64
  linha: U32
  coluna: U32
  tokens: Lista<Token>
  diagnosticos: Lista<Diagnostico>
fecha

campo varre_unidade(unidade: UnidadeFonte) -> Lista<FluxoTokens> ::
  solta saida := lista<FluxoTokens>()

  para cada fonte em unidade.arquivos ::
    lista_coloca(saida, varre(fonte))
  fecha

  devolve saida
fecha

campo varre(fonte: Fonte) -> FluxoTokens ::
  solta estado := EstadoVarredura {
    fonte: fonte,
    cursor: 0,
    linha: 1,
    coluna: 1,
    tokens: lista<Token>(),
    diagnosticos: lista<Diagnostico>()
  }

  gira nao varredura_fim(estado) ::
    guarda c := atual(estado)

    veja branco(c) ::
      avanca(estado)
    outro ::
      veja letra(c) ::
        le_nome(estado)
      outro ::
        veja digito(c) ::
          le_numero(estado)
        outro ::
          veja c == "\"" ::
            le_texto(estado)
          outro ::
            le_sinal(estado)
          fecha
        fecha
      fecha
    fecha
  fecha

  adiciona_fim(estado)

  devolve FluxoTokens {
    fonte: fonte,
    tokens: estado.tokens
  }
fecha
