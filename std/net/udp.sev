modulo std.net.udp

usa std.base.resultado
usa std.mem.bytes

molde EnderecoUdp ::
  host: Texto
  porta: U32
fecha

molde SocketUdp ::
  id: U64
fecha

molde PacoteUdp ::
  origem: EnderecoUdp
  dados: Bytes
fecha

campo udp_abre(host: Texto, porta: U32) -> Resultado<SocketUdp, Falha> toca rede ::
  devolve sys_udp_abre(host, porta)
fecha

campo udp_envia(socket: SocketUdp, destino: EnderecoUdp, dados: Bytes) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_udp_envia(socket, destino, dados)
fecha

campo udp_recebe(socket: SocketUdp) -> Resultado<PacoteUdp, Falha> toca rede ::
  devolve sys_udp_recebe(socket)
fecha

campo udp_fecha(socket: SocketUdp) -> Nada toca rede ::
  sys_udp_fecha(socket)
fecha
