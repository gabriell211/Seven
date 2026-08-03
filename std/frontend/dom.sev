modulo std.frontend.dom

molde Evento ::
  nome: Texto
  alvo: Texto
fecha

molde Componente ::
  nome: Texto
  estado: Mapa<Texto, Texto>
  render: Campo<Componente, Texto>
fecha

campo componente(nome: Texto, render: Campo<Componente, Texto>) -> Componente ::
  devolve Componente {
    nome: nome,
    estado: mapa<Texto, Texto>(),
    render: render
  }
fecha

campo monta(seletor: Texto, componente: Componente) -> Nada toca frontend ::
  frontend_monta(seletor, componente.render(componente))
fecha

campo atualiza(seletor: Texto, html: Texto) -> Nada toca frontend ::
  frontend_monta(seletor, html)
fecha

campo escuta(seletor: Texto, evento: Texto, acao: Campo<Evento, Nada>) -> Nada toca frontend ::
  frontend_escuta(seletor, evento, acao)
fecha

campo classe(condicao: Bit, nome: Texto) -> Texto ::
  veja condicao ::
    devolve nome
  fecha

  devolve ""
fecha
