modulo seven.compiler

usa seven.compiler.driver

campo inicio(argumentos: Lista<Texto>) -> Num toca terminal, disco, ambiente ::
  guarda pedido := pedido_de_compilacao(argumentos)
  guarda saida := compila(pedido)

  veja saida e Sucesso ::
    devolve 0
  outro ::
    mostra_diagnosticos(saida.diagnosticos)
    devolve 1
  fecha
fecha
