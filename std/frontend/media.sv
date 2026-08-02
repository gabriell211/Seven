modulo std.frontend.media

usa std.frontend.css

molde MediaCss ::
  consulta: Texto
  regras: Lista<RegraCss>
fecha

campo media(consulta: Texto) -> MediaCss ::
  devolve MediaCss {
    consulta: consulta,
    regras: lista<RegraCss>()
  }
fecha

campo media_regra(m: MediaCss, seletor: Texto, declaracoes: Lista<DeclaracaoCss>) -> MediaCss ::
  lista_coloca(m.regras, regra(seletor, declaracoes))
  devolve m
fecha

campo breakpoint_min(largura: Num) -> Texto ::
  devolve "(min-width: " + px(largura) + ")"
fecha

campo breakpoint_max(largura: Num) -> Texto ::
  devolve "(max-width: " + px(largura) + ")"
fecha

campo css_media(folha: FolhaCss, m: MediaCss) -> FolhaCss ::
  lista_coloca(folha.regras, RegraCss {
    seletor: "@media " + m.consulta,
    declaracoes: sys_css_media_declaracoes(m)
  })

  devolve folha
fecha
