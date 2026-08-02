modulo std.web.middleware

usa std.web.http
usa std.web.router

molde Middleware ::
  nome: Texto
  aplica: Campo<Contexto, Campo<Contexto, Resposta>, Resposta>
fecha

campo middleware(nome: Texto, aplica: Campo<Contexto, Campo<Contexto, Resposta>, Resposta>) -> Middleware ::
  devolve Middleware {
    nome: nome,
    aplica: aplica
  }
fecha

campo encadeia(middlewares: Lista<Middleware>, final: Campo<Contexto, Resposta>) -> Campo<Contexto, Resposta> ::
  devolve campo(ctx: Contexto) -> Resposta ::
    solta proximo := final

    para cada item em reverso(middlewares) ::
      guarda anterior := proximo
      vira proximo := campo(interno: Contexto) -> Resposta ::
        devolve item.aplica(interno, anterior)
      fecha
    fecha

    devolve proximo(ctx)
  fecha
fecha
