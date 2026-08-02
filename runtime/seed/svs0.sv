modulo seven.runtime.seed.svs0

usa seven0.ast
usa seven0.check
usa seven0.token
usa std.fs.file
usa std.mem.bytes

selo OpSeed ::
  SeedPare
  SeedFalha
  SeedEmpilhaU8
  SeedEmpilhaU32
  SeedEmpilhaTexto
  SeedLeArquivo
  SeedGravaArquivo
  SeedTokeniza
  SeedMonta
  SeedConfere
  SeedEmiteSvbc0
  SeedJuntaCaminho
  SeedMostra
  SeedRetorna
fecha

molde FitaSvs0 ::
  codigo: Bytes
fecha

molde EstadoSeed ::
  fita: FitaSvs0
  ip: U64
  pilha: Lista<ValorSeed>
  rodando: Bit
  codigo_saida: Num
fecha

selo ValorSeed ::
  SeedNada
  SeedU32(valor: U32)
  SeedTexto(valor: Texto)
  SeedBytes(valor: Bytes)
  SeedTokens(valor: ListaToken)
  SeedArvore(valor: Programa)
  SeedUnidade(valor: Unidade)
fecha

campo svs0_carrega(caminho: Texto) -> Resultado<FitaSvs0, Falha> toca disco ::
  guarda dados := arquivo_bytes(caminho)

  veja dados e Falha ::
    devolve dados
  fecha

  devolve svs0_parse(dados.valor)
fecha

campo svs0_executa(fita: FitaSvs0) -> Resultado<Num, Falha> toca disco, terminal ::
  solta estado := EstadoSeed {
    fita: fita,
    ip: 0,
    pilha: lista<ValorSeed>(),
    rodando: sim,
    codigo_saida: 0
  }

  gira estado.rodando ::
    guarda r := svs0_passo(estado)

    veja r e Falha ::
      devolve r
    fecha
  fecha

  devolve Valor(estado.codigo_saida)
fecha

campo svs0_passo(estado: EstadoSeed) -> Resultado<Nada, Falha> toca disco, terminal ::
  guarda op := bytes_pega(estado.fita.codigo, estado.ip)
  vira estado.ip := estado.ip + 1

  veja op == 0 ::
    vira estado.rodando := nao
    devolve Valor(nulo)
  fecha

  veja op == 5 ::
    devolve seed_le_arquivo(estado)
  fecha

  veja op == 6 ::
    devolve seed_grava_arquivo(estado)
  fecha

  veja op == 7 ::
    devolve seed_tokeniza(estado)
  fecha

  veja op == 8 ::
    devolve seed_monta(estado)
  fecha

  veja op == 9 ::
    devolve seed_confere(estado)
  fecha

  veja op == 10 ::
    devolve seed_emite_svbc0(estado)
  fecha

  veja op == 13 ::
    guarda codigo := bytes_pega(estado.fita.codigo, estado.ip)
    vira estado.ip := estado.ip + 1
    vira estado.codigo_saida := codigo
    vira estado.rodando := nao
    devolve Valor(nulo)
  fecha

  devolve Falha(nova_falha("SVS0-OP", "instrucao do seed desconhecida"))
fecha

campo svs0_parse(dados: Bytes) -> Resultado<FitaSvs0, Falha> ::
  guarda magic := sys_bytes_texto_intervalo(dados, 0, 4)

  veja magic != "SVS0" ::
    devolve Falha(nova_falha("SVS0-MAGIC", "fita seed invalida"))
  fecha

  devolve Valor(FitaSvs0 {
    codigo: sys_svs0_codigo(dados)
  })
fecha

campo seed_le_arquivo(estado: EstadoSeed) -> Resultado<Nada, Falha> toca disco ::
  guarda caminho := valor_seed_texto(sys_lista_pop(estado.pilha))
  guarda conteudo := arquivo_texto(caminho)

  veja conteudo e Falha ::
    devolve conteudo
  fecha

  lista_coloca(estado.pilha, SeedTexto(conteudo.valor))
  devolve Valor(nulo)
fecha

campo seed_grava_arquivo(estado: EstadoSeed) -> Resultado<Nada, Falha> toca disco ::
  guarda conteudo := valor_seed_bytes(sys_lista_pop(estado.pilha))
  guarda caminho := valor_seed_texto(sys_lista_pop(estado.pilha))
  guarda r := arquivo_salva_texto(caminho, bytes_texto(conteudo))

  veja r e Falha ::
    devolve r
  fecha

  devolve Valor(nulo)
fecha

campo seed_tokeniza(estado: EstadoSeed) -> Resultado<Nada, Falha> ::
  guarda fonte := valor_seed_texto(sys_lista_pop(estado.pilha))
  lista_coloca(estado.pilha, SeedTokens(sys_seed_tokeniza(fonte)))
  devolve Valor(nulo)
fecha

campo seed_monta(estado: EstadoSeed) -> Resultado<Nada, Falha> ::
  guarda tokens := valor_seed_tokens(sys_lista_pop(estado.pilha))
  lista_coloca(estado.pilha, SeedArvore(sys_seed_monta(tokens)))
  devolve Valor(nulo)
fecha

campo seed_confere(estado: EstadoSeed) -> Resultado<Nada, Falha> ::
  guarda arvore := valor_seed_arvore(sys_lista_pop(estado.pilha))
  lista_coloca(estado.pilha, SeedUnidade(sys_seed_confere(arvore)))
  devolve Valor(nulo)
fecha

campo seed_emite_svbc0(estado: EstadoSeed) -> Resultado<Nada, Falha> ::
  guarda unidade := valor_seed_unidade(sys_lista_pop(estado.pilha))
  lista_coloca(estado.pilha, SeedBytes(sys_seed_emite_svbc0(unidade)))
  devolve Valor(nulo)
fecha

campo valor_seed_texto(valor: ValorSeed) -> Texto ::
  veja valor e SeedTexto ::
    devolve valor.valor
  fecha

  devolve ""
fecha

campo valor_seed_bytes(valor: ValorSeed) -> Bytes ::
  veja valor e SeedBytes ::
    devolve valor.valor
  fecha

  devolve bytes_novo()
fecha

campo valor_seed_tokens(valor: ValorSeed) -> ListaToken ::
  veja valor e SeedTokens ::
    devolve valor.valor
  fecha

  devolve lista_token()
fecha

campo valor_seed_arvore(valor: ValorSeed) -> Programa ::
  veja valor e SeedArvore ::
    devolve valor.valor
  fecha

  devolve Programa {
    modulo: "",
    usos: lista_texto(),
    itens: lista_no()
  }
fecha

campo valor_seed_unidade(valor: ValorSeed) -> Unidade ::
  veja valor e SeedUnidade ::
    devolve valor.valor
  fecha

  devolve Unidade {
    programa: valor_seed_arvore(SeedArvore(Programa {
      modulo: "",
      usos: lista_texto(),
      itens: lista_no()
    })),
    simbolos: lista_simbolo(),
    diagnosticos: lista_diagnostico()
  }
fecha
