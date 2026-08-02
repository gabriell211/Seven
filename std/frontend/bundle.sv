modulo std.frontend.bundle

usa std.base.resultado
usa std.frontend.assets
usa std.frontend.css

molde PacoteFrontend ::
  nome: Texto
  html: Texto
  css: Lista<FolhaCss>
  assets: ManifestoAssets
fecha

campo pacote_frontend(nome: Texto, html: Texto) -> PacoteFrontend ::
  devolve PacoteFrontend {
    nome: nome,
    html: html,
    css: lista<FolhaCss>(),
    assets: assets_manifesto()
  }
fecha

campo pacote_css(pacote: PacoteFrontend, folha: FolhaCss) -> PacoteFrontend ::
  lista_coloca(pacote.css, folha)
  devolve pacote
fecha

campo pacote_asset(pacote: PacoteFrontend, item: Asset) -> PacoteFrontend ::
  vira pacote.assets := assets_adiciona(pacote.assets, item)
  devolve pacote
fecha

campo pacote_emite(pacote: PacoteFrontend) -> Resultado<Bytes, Falha> ::
  devolve sys_frontend_empacota(pacote)
fecha
