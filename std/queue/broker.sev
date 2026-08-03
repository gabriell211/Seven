modulo std.queue.broker

usa std.base.resultado
usa std.mem.bytes

molde MensagemFila ::
  topico: Texto
  chave: Texto
  corpo: Bytes
fecha

molde BrokerFila ::
  id: U64
  fornecedor: Texto
fecha

campo fila_conecta(url: Texto) -> Resultado<BrokerFila, Falha> toca rede ::
  devolve sys_fila_conecta(url)
fecha

campo fila_publica(broker: BrokerFila, msg: MensagemFila) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_fila_publica(broker, msg)
fecha

campo fila_consumir(broker: BrokerFila, topico: Texto, handler: Campo<MensagemFila, Nada>) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_fila_consumir(broker, topico, handler)
fecha
