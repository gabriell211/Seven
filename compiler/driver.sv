modulo seven.compiler.driver

usa seven.compiler.source
usa seven.compiler.lexer
usa seven.compiler.parser
usa seven.compiler.symbols
usa seven.compiler.types
usa seven.compiler.effects
usa seven.compiler.semantic
usa seven.compiler.ir
usa seven.compiler.bytecode
usa seven.compiler.diagnostic
usa seven.compiler.package
usa std.io.console

molde PedidoCompilacao ::
  pacote: Pacote
  entrada: Texto
  alvo: Texto
  modo: Texto
fecha

selo SaidaCompilacao ::
  Sucesso(caminho: Texto)
  Falhou(diagnosticos: Lista<Diagnostico>)
fecha

campo pedido_de_compilacao(argumentos: Lista<Texto>) -> PedidoCompilacao toca ambiente, disco ::
  guarda pacote := pacote_carrega("seven.pkg")
  guarda entrada := pacote.entrada

  devolve PedidoCompilacao {
    pacote: pacote,
    entrada: entrada,
    alvo: pacote.alvo,
    modo: "seguro"
  }
fecha

campo compila(pedido: PedidoCompilacao) -> SaidaCompilacao toca disco ::
  guarda fontes := fonte_carrega_pacote(pedido.pacote)
  guarda tokens := varre_unidade(fontes)
  guarda arvore := monta_unidade(tokens)
  guarda semantica := mede(arvore, pedido.pacote)
  guarda diagnosticos := junta_diagnosticos(semantica)

  veja lista_tamanho(diagnosticos) > 0 ::
    devolve Falhou(diagnosticos)
  fecha

  guarda meio := baixa_ir(arvore, semantica.tipos, semantica.efeitos)
  guarda otimizado := otimiza_ir(meio, pedido.modo)
  guarda imagem := emite_svbc(otimizado)
  guarda caminho := caminho_saida(pedido)

  arquivo_grava(caminho, imagem)
  devolve Sucesso(caminho)
fecha

campo junta_diagnosticos(semantica: UnidadeSemantica) -> Lista<Diagnostico> ::
  solta saida := lista<Diagnostico>()

  lista_junta(saida, semantica.simbolos.diagnosticos)
  lista_junta(saida, semantica.tipos.diagnosticos)
  lista_junta(saida, semantica.efeitos.diagnosticos)
  lista_junta(saida, semantica.memoria.diagnosticos)
  lista_junta(saida, semantica.ffi.diagnosticos)

  devolve saida
fecha

campo mostra_diagnosticos(diagnosticos: Lista<Diagnostico>) -> Nada toca terminal ::
  para cada diag em diagnosticos ::
    diga formatar_diagnostico(diag)
  fecha
fecha
