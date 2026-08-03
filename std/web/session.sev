modulo std.web.session

usa std.base.resultado
usa std.crypto.token
usa std.web.cookie
usa std.web.http

molde Sessao ::
  id: Texto
  usuario: Texto
  expira_em: U64
fecha

campo sessao_cookie(sessao: Sessao, segredo: Texto) -> Cookie toca tempo ::
  guarda token := token_novo(sessao.id + ":" + sessao.usuario, segredo, sessao.expira_em)
  guarda c := cookie("seven_session", token.valor)
  vira c.max_idade := sessao.expira_em - tempo_agora()
  devolve c
fecha

campo sessao_ler(req: Requisicao, segredo: Texto) -> Resultado<Sessao, Falha> toca tempo ::
  guarda valor := cookie_requisicao(req, "seven_session")

  veja valor e Falha ::
    devolve valor
  fecha

  guarda token := TokenSeguro {
    valor: valor.valor,
    expira_em: tempo_agora() + 1
  }

  guarda carga := token_confere(token, segredo)

  veja carga e Falha ::
    devolve carga
  fecha

  devolve sessao_parse(carga.valor)
fecha

campo cookie_requisicao(req: Requisicao, nome: Texto) -> Resultado<Texto, Falha> ::
  devolve sys_cookie_requisicao(req, nome)
fecha

campo sessao_parse(carga: Texto) -> Resultado<Sessao, Falha> ::
  devolve sys_sessao_parse(carga)
fecha
