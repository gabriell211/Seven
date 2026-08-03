modulo std.frontend.css

molde DeclaracaoCss ::
  nome: Texto
  valor: Texto
fecha

molde RegraCss ::
  seletor: Texto
  declaracoes: Lista<DeclaracaoCss>
fecha

molde FolhaCss ::
  nome: Texto
  regras: Lista<RegraCss>
  variaveis: Lista<DeclaracaoCss>
fecha

campo css(nome: Texto) -> FolhaCss ::
  devolve FolhaCss {
    nome: nome,
    regras: lista<RegraCss>(),
    variaveis: lista<DeclaracaoCss>()
  }
fecha

campo decl(nome: Texto, valor: Texto) -> DeclaracaoCss ::
  devolve DeclaracaoCss {
    nome: nome,
    valor: valor
  }
fecha

campo regra(seletor: Texto, declaracoes: Lista<DeclaracaoCss>) -> RegraCss ::
  devolve RegraCss {
    seletor: seletor,
    declaracoes: declaracoes
  }
fecha

campo css_var(folha: FolhaCss, nome: Texto, valor: Texto) -> FolhaCss ::
  lista_coloca(folha.variaveis, decl("--" + nome, valor))
  devolve folha
fecha

campo css_regra(folha: FolhaCss, seletor: Texto, declaracoes: Lista<DeclaracaoCss>) -> FolhaCss ::
  lista_coloca(folha.regras, regra(seletor, declaracoes))
  devolve folha
fecha

campo css_renderiza(folha: FolhaCss) -> Texto ::
  devolve sys_css_renderiza(folha)
fecha

campo css_injeta(folha: FolhaCss) -> Nada toca frontend ::
  frontend_injeta_css(folha.nome, css_renderiza(folha))
fecha

campo px(valor: Num) -> Texto ::
  devolve texto(valor) + "px"
fecha

campo rem(valor: Real64) -> Texto ::
  devolve texto(valor) + "rem"
fecha

campo pct(valor: Num) -> Texto ::
  devolve texto(valor) + "%"
fecha

campo cor_hex(valor: Texto) -> Texto ::
  devolve valor
fecha

campo var_css(nome: Texto) -> Texto ::
  devolve "var(--" + nome + ")"
fecha
