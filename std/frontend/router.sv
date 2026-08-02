modulo std.frontend.router

molde RotaTela ::
  caminho: Texto
  render: Campo<Nada, Texto>
fecha

molde RoteadorTela ::
  rotas: Lista<RotaTela>
fecha

campo roteador_tela() -> RoteadorTela ::
  devolve RoteadorTela {
    rotas: lista<RotaTela>()
  }
fecha

campo tela(router: RoteadorTela, caminho: Texto, render: Campo<Nada, Texto>) -> RoteadorTela ::
  lista_coloca(router.rotas, RotaTela {
    caminho: caminho,
    render: render
  })

  devolve router
fecha

campo navega(caminho: Texto) -> Nada toca frontend ::
  frontend_navega(caminho)
fecha
