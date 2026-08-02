modulo conformance.frontend.valid.bundle

usa std.frontend.assets
usa std.frontend.bundle
usa std.frontend.css

campo cria() -> PacoteFrontend ::
  solta folha := css("app")
  solta pacote := pacote_frontend("app", "<main>ok</main>")
  vira pacote := pacote_css(pacote, folha)
  vira pacote := pacote_asset(pacote, asset("/logo.png", "image/png"))
  devolve pacote
fecha
