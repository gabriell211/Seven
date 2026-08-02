modulo std.web.router

usa std.web.http

molde ParametroRota ::
  nome: Texto
  valor: Texto
fecha

molde Contexto ::
  requisicao: Requisicao
  parametros: Lista<ParametroRota>
fecha

molde Rota ::
  metodo: MetodoHttp
  padrao: Texto
  acao: Campo<Contexto, Resposta>
fecha

molde Roteador ::
  rotas: Lista<Rota>
  fallback: Campo<Contexto, Resposta>
fecha

campo roteador() -> Roteador ::
  devolve Roteador {
    rotas: lista<Rota>(),
    fallback: rota_404
  }
fecha

campo rota_404(ctx: Contexto) -> Resposta ::
  devolve nao_encontrado()
fecha

campo adiciona_rota(router: Roteador, metodo: MetodoHttp, padrao: Texto, acao: Campo<Contexto, Resposta>) -> Roteador ::
  lista_coloca(router.rotas, Rota {
    metodo: metodo,
    padrao: padrao,
    acao: acao
  })

  devolve router
fecha

campo resolver(router: Roteador, req: Requisicao) -> Resposta ::
  para cada rota em router.rotas ::
    veja rota.metodo == req.metodo e caminho_combina(rota.padrao, req.caminho) ::
      guarda ctx := Contexto {
        requisicao: req,
        parametros: parametros_extrai(rota.padrao, req.caminho)
      }
      devolve rota.acao(ctx)
    fecha
  fecha

  devolve router.fallback(Contexto {
    requisicao: req,
    parametros: lista<ParametroRota>()
  })
fecha

campo caminho_combina(padrao: Texto, caminho: Texto) -> Bit ::
  devolve sys_rota_combina(padrao, caminho)
fecha

campo parametros_extrai(padrao: Texto, caminho: Texto) -> Lista<ParametroRota> ::
  devolve sys_rota_parametros(padrao, caminho)
fecha
