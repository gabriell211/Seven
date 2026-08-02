modulo examples.frontend_counter.app

usa examples.frontend_counter.styles
usa std.frontend.css
usa std.frontend.dom
usa std.frontend.state
usa std.web.html

campo render_counter(app: Componente) -> Texto ::
  guarda atual := app.estado["contador"]

  devolve pagina("Seven Counter", lista_de(
    elem("main", lista_de(attr("id", "app"), attr("class", "counter-shell")), lista_de(
      elem("section", lista_de(attr("class", "counter-panel")), lista_de(
        elem("p", lista_de(attr("class", "eyebrow")), lista_de(texto_no("Seven UI"))),
        elem("h1", lista<Atributo>(), lista_de(texto_no("Frontend com CSS nativo"))),
        elem("p", lista_de(attr("class", "counter-value")), lista_de(texto_no(atual))),
        elem("button", lista_de(attr("id", "incrementa"), attr("class", "primary-button")), lista_de(texto_no("+1")))
      ))
    ))
  ))
fecha

campo inicio() -> Nada toca frontend ::
  solta app := componente("Counter", render_counter)
  mapa_coloca(app.estado, "contador", "0")

  css_injeta(counter_styles())
  monta("#root", app)

  escuta("#incrementa", "click", campo(evento: Evento) -> Nada toca frontend ::
    guarda atual := numero(app.estado["contador"])
    mapa_coloca(app.estado, "contador", texto(atual + 1))
    monta("#root", app)
  fecha)
fecha
