modulo examples.frontend_counter.styles

usa std.frontend.css
usa std.frontend.layout
usa std.frontend.media
usa std.frontend.theme

campo counter_styles() -> FolhaCss ::
  solta folha := css("frontend-counter")
  vira folha := tema_aplica(folha, tema_padrao())

  vira folha := css_regra(folha, "body", lista_de(
    decl("margin", "0"),
    decl("font-family", "Inter, system-ui, sans-serif"),
    decl("background", var_css("cor-fundo")),
    decl("color", var_css("cor-texto"))
  ))

  vira folha := css_regra(folha, ".counter-shell", lista_de(
    decl("min-height", "100vh"),
    decl("display", "grid"),
    decl("place-items", "center"),
    decl("padding", "24px")
  ))

  vira folha := css_regra(folha, ".counter-panel", lista_de(
    decl("width", "min(420px, 100%)"),
    decl("border", "1px solid rgba(148, 163, 184, 0.24)"),
    decl("border-radius", var_css("raio")),
    decl("background", var_css("cor-painel")),
    decl("padding", "24px"),
    decl("box-shadow", "0 24px 80px rgba(0, 0, 0, 0.35)")
  ))

  vira folha := css_regra(folha, ".eyebrow", lista_de(
    decl("margin", "0 0 8px"),
    decl("color", var_css("cor-acao")),
    decl("font-size", "12px"),
    decl("text-transform", "uppercase")
  ))

  vira folha := css_regra(folha, ".counter-value", lista_de(
    decl("font-size", "64px"),
    decl("font-weight", "800"),
    decl("margin", "24px 0")
  ))

  vira folha := css_regra(folha, ".primary-button", lista_de(
    decl("width", "100%"),
    decl("height", "44px"),
    decl("border", "0"),
    decl("border-radius", var_css("raio")),
    decl("background", var_css("cor-acao")),
    decl("color", "#052e16"),
    decl("font-weight", "700"),
    decl("cursor", "pointer")
  ))

  vira folha := css_media(folha, media_regra(media(breakpoint_max(520)), ".counter-panel", lista_de(
    decl("padding", "18px")
  )))

  devolve folha
fecha
