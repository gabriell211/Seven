modulo std.web.client

usa std.base.resultado
usa std.mem.bytes
usa std.web.http

molde ClienteHttp ::
  base_url: Texto
  timeout_ms: U32
fecha

campo cliente_http(base_url: Texto) -> ClienteHttp ::
  devolve ClienteHttp {
    base_url: base_url,
    timeout_ms: 30000
  }
fecha

campo http_get(cliente: ClienteHttp, caminho: Texto) -> Resultado<Resposta, Falha> toca rede ::
  devolve sys_http_envia(cliente, GET, caminho, bytes_novo())
fecha

campo http_post(cliente: ClienteHttp, caminho: Texto, corpo: Bytes) -> Resultado<Resposta, Falha> toca rede ::
  devolve sys_http_envia(cliente, POST, caminho, corpo)
fecha

campo http_put(cliente: ClienteHttp, caminho: Texto, corpo: Bytes) -> Resultado<Resposta, Falha> toca rede ::
  devolve sys_http_envia(cliente, PUT, caminho, corpo)
fecha

campo http_delete(cliente: ClienteHttp, caminho: Texto) -> Resultado<Resposta, Falha> toca rede ::
  devolve sys_http_envia(cliente, DELETE, caminho, bytes_novo())
fecha
