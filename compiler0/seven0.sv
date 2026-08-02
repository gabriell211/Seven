modulo seven0

usa seven0.primitives
usa seven0.driver

campo inicio(argumentos: ListaTexto) -> Num toca terminal, disco, ambiente ::
  guarda pedido := pedido_ler(argumentos)
  guarda saida := compilar(pedido)

  veja saida.ok ::
    devolve 0
  outro ::
    diagnosticos_mostrar(saida.diagnosticos)
    devolve 1
  fecha
fecha
