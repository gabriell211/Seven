modulo conformance.fullstack.invalid.frontend_effect

usa std.frontend.dom

campo render(app: Componente) -> Texto ::
  devolve "<main>ok</main>"
fecha

// espera: SV-EFEITO-VAZOU
campo inicia() -> Nada ::
  guarda app := componente("App", render)
  monta("#root", app)
fecha
