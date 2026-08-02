modulo std.frontend.animation

usa std.frontend.css

molde QuadroCss ::
  ponto: Texto
  declaracoes: Lista<DeclaracaoCss>
fecha

molde AnimacaoCss ::
  nome: Texto
  quadros: Lista<QuadroCss>
fecha

campo animacao(nome: Texto) -> AnimacaoCss ::
  devolve AnimacaoCss {
    nome: nome,
    quadros: lista<QuadroCss>()
  }
fecha

campo quadro(anim: AnimacaoCss, ponto: Texto, declaracoes: Lista<DeclaracaoCss>) -> AnimacaoCss ::
  lista_coloca(anim.quadros, QuadroCss {
    ponto: ponto,
    declaracoes: declaracoes
  })

  devolve anim
fecha

campo css_animacao(folha: FolhaCss, anim: AnimacaoCss) -> FolhaCss ::
  lista_coloca(folha.regras, RegraCss {
    seletor: "@keyframes " + anim.nome,
    declaracoes: sys_css_animacao_declaracoes(anim)
  })

  devolve folha
fecha

campo transicao(valor: Texto) -> DeclaracaoCss ::
  devolve decl("transition", valor)
fecha
