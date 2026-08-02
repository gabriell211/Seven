modulo std.web.http

usa std.base.resultado
usa std.mem.bytes
usa std.net.tcp

selo MetodoHttp ::
  GET
  POST
  PUT
  PATCH
  DELETE
  OPTIONS
fecha

molde Cabecalho ::
  nome: Texto
  valor: Texto
fecha

molde Requisicao ::
  metodo: MetodoHttp
  caminho: Texto
  consulta: Texto
  cabecalhos: Lista<Cabecalho>
  corpo: Bytes
fecha

molde Resposta ::
  status: U32
  cabecalhos: Lista<Cabecalho>
  corpo: Bytes
fecha

campo cabecalho(nome: Texto, valor: Texto) -> Cabecalho ::
  devolve Cabecalho {
    nome: nome,
    valor: valor
  }
fecha

campo resposta(status: U32, corpo: Texto) -> Resposta ::
  solta headers := lista<Cabecalho>()
  lista_coloca(headers, cabecalho("content-type", "text/plain; charset=utf-8"))

  devolve Resposta {
    status: status,
    cabecalhos: headers,
    corpo: texto_bytes(corpo)
  }
fecha

campo html(corpo: Texto) -> Resposta ::
  solta r := resposta(200, corpo)
  lista_coloca(r.cabecalhos, cabecalho("content-type", "text/html; charset=utf-8"))
  devolve r
fecha

campo json(corpo: Texto) -> Resposta ::
  solta r := resposta(200, corpo)
  lista_coloca(r.cabecalhos, cabecalho("content-type", "application/json; charset=utf-8"))
  devolve r
fecha

campo nao_encontrado() -> Resposta ::
  devolve resposta(404, "nao encontrado")
fecha

campo http_ler_requisicao(conexao: ConexaoTcp) -> Requisicao toca rede ::
  devolve sys_http_ler_requisicao(conexao)
fecha

campo http_escreve_resposta(conexao: ConexaoTcp, res: Resposta) -> Nada toca rede ::
  sys_http_escreve_resposta(conexao, res)
fecha
