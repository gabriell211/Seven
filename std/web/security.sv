modulo std.web.security

usa std.web.http
usa std.web.router

campo headers_seguros(ctx: Contexto, proximo: Campo<Contexto, Resposta>) -> Resposta ::
  solta res := proximo(ctx)

  lista_coloca(res.cabecalhos, cabecalho("x-content-type-options", "nosniff"))
  lista_coloca(res.cabecalhos, cabecalho("x-frame-options", "deny"))
  lista_coloca(res.cabecalhos, cabecalho("referrer-policy", "strict-origin-when-cross-origin"))
  lista_coloca(res.cabecalhos, cabecalho("content-security-policy", "default-src 'self'"))

  devolve res
fecha

campo cors(origem: Texto) -> Campo<Contexto, Campo<Contexto, Resposta>, Resposta> ::
  devolve campo(ctx: Contexto, proximo: Campo<Contexto, Resposta>) -> Resposta ::
    solta res := proximo(ctx)
    lista_coloca(res.cabecalhos, cabecalho("access-control-allow-origin", origem))
    lista_coloca(res.cabecalhos, cabecalho("access-control-allow-headers", "content-type, authorization"))
    lista_coloca(res.cabecalhos, cabecalho("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS"))
    devolve res
  fecha
fecha
