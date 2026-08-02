modulo std.net.websocket

usa std.base.resultado
usa std.mem.bytes
usa std.web.http

molde WebSocket ::
  id: U64
fecha

selo FrameWs ::
  TextoFrame(valor: Texto)
  BytesFrame(valor: Bytes)
  Ping(valor: Bytes)
  Pong(valor: Bytes)
  Fecha(codigo: U32, motivo: Texto)
fecha

campo ws_aceita(req: Requisicao) -> Resultado<WebSocket, Falha> toca rede ::
  devolve sys_ws_aceita(req)
fecha

campo ws_conecta(url: Texto) -> Resultado<WebSocket, Falha> toca rede ::
  devolve sys_ws_conecta(url)
fecha

campo ws_envia(socket: WebSocket, frame: FrameWs) -> Resultado<Nada, Falha> toca rede ::
  devolve sys_ws_envia(socket, frame)
fecha

campo ws_recebe(socket: WebSocket) -> Resultado<FrameWs, Falha> toca rede ::
  devolve sys_ws_recebe(socket)
fecha
