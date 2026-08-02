modulo std.net.tcp

usa std.base.resultado
usa std.mem.bytes

molde ListenerTcp ::
  id: U64
fecha

molde ConexaoTcp ::
  id: U64
fecha

campo tcp_escuta(host: Texto, porta: U32) -> Resultado<ListenerTcp, Falha> toca rede ::
  devolve sys_tcp_escuta(host, porta)
fecha

campo tcp_aceita(listener: ListenerTcp) -> Resultado<ConexaoTcp, Falha> toca rede ::
  devolve sys_tcp_aceita(listener)
fecha

campo tcp_le(conexao: ConexaoTcp) -> Resultado<Bytes, Falha> toca rede ::
  devolve sys_tcp_le(conexao)
fecha

campo tcp_escreve(conexao: ConexaoTcp, dados: Bytes) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_tcp_escreve(conexao, dados)
fecha

campo tcp_fecha(conexao: ConexaoTcp) -> Nada toca rede ::
  sys_tcp_fecha(conexao)
fecha
