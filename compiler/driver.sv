modulo seven.compiler.driver

usa seven.compiler.source
usa seven.compiler.lexer
usa seven.compiler.parser
usa seven.compiler.symbols
usa seven.compiler.types
usa seven.compiler.effects
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
  guarda simbolos := liga_unidade(arvore, pedido.pacote)
  guarda tipos := mede_tipos(arvore, simbolos)
  guarda efeitos := mede_efeitos(arvore, simbolos)
  guarda meio := baixa_ir(arvore, tipos, efeitos)
  guarda otimizado := otimiza_ir(meio, pedido.modo)
  guarda imagem := emite_svbc(otimizado)
  guarda caminho := caminho_saida(pedido)

  arquivo_grava(caminho, imagem)
  devolve Sucesso(caminho)
fecha

campo mostra_diagnosticos(diagnosticos: Lista<Diagnostico>) -> Nada toca terminal ::
  para cada diag em diagnosticos ::
    diga formatar_diagnostico(diag)
  fecha
fecha
