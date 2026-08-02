modulo std.web.server

usa std.base.resultado
usa std.net.tcp
usa std.web.http
usa std.web.router

molde ServidorHttp ::
  host: Texto
  porta: U32
  roteador: Roteador
fecha

campo servidor(host: Texto, porta: U32, roteador: Roteador) -> ServidorHttp ::
  devolve ServidorHttp {
    host: host,
    porta: porta,
    roteador: roteador
  }
fecha

campo servir(app: ServidorHttp) -> Resultado<Nada, Falha> toca rede, terminal ::
  guarda listener := tcp_escuta(app.host, app.porta)

  veja listener e Falha ::
    devolve listener
  fecha

  gira sim ::
    guarda conexao := tcp_aceita(listener.valor)
    guarda req := http_ler_requisicao(conexao.valor)
    guarda res := resolver(app.roteador, req)
    http_escreve_resposta(conexao.valor, res)
    tcp_fecha(conexao.valor)
  fecha

  devolve Valor(nulo)
fecha
