modulo seven0.scan

usa seven0.primitives
usa seven0.source
usa seven0.token
usa seven0.diagnostic

molde Scanner ::
  fonte: Fonte
  pos: U64
  linha: U32
  coluna: U32
  tokens: ListaToken
  diagnosticos: ListaDiagnostico
fecha

campo tokenizar(fonte: Fonte) -> Fluxo ::
  solta s := Scanner {
    fonte: fonte,
    pos: 0,
    linha: 1,
    coluna: 1,
    tokens: lista_token(),
    diagnosticos: lista_diagnostico()
  }

  gira s.pos < tamanho(s.fonte.texto) ::
    guarda c := texto_byte(s.fonte.texto, s.pos)

    veja branco(c) ::
      scanner_avanca(s)
    outro ::
      veja letra(c) ::
        scanner_nome(s)
      outro ::
        veja digito(c) ::
          scanner_numero(s)
        outro ::
          veja c == 34 ::
            scanner_texto(s)
          outro ::
            scanner_sinal(s)
          fecha
        fecha
      fecha
    fecha
  fecha

  lista_token_coloca(s.tokens, token("fim", "", s.linha, s.coluna))

  devolve Fluxo {
    fonte: fonte.caminho,
    tokens: s.tokens
  }
fecha
