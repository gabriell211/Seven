modulo conformance.fullstack.valid.http_route

usa std.web.http
usa std.web.router

campo home(ctx: Contexto) -> Resposta ::
  devolve resposta(200, "ok")
fecha

campo cria() -> Roteador ::
  solta r := roteador()
  vira r := adiciona_rota(r, GET, "/", home)
  devolve r
fecha
