modulo conformance.frontend.valid.theme_media

usa std.frontend.css
usa std.frontend.media
usa std.frontend.theme

campo cria() -> FolhaCss ::
  solta folha := css("responsive")
  vira folha := tema_aplica(folha, tema_padrao())
  vira folha := css_media(folha, media_regra(media(breakpoint_max(700)), ".grid", lista_de(
    decl("grid-template-columns", "1fr")
  )))
  devolve folha
fecha
