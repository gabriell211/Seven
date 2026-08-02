modulo std.frontend.layout

usa std.frontend.css

campo flex_linha() -> Lista<DeclaracaoCss> ::
  devolve lista_de(
    decl("display", "flex"),
    decl("flex-direction", "row")
  )
fecha

campo flex_coluna() -> Lista<DeclaracaoCss> ::
  devolve lista_de(
    decl("display", "flex"),
    decl("flex-direction", "column")
  )
fecha

campo grid_colunas(colunas: Texto) -> Lista<DeclaracaoCss> ::
  devolve lista_de(
    decl("display", "grid"),
    decl("grid-template-columns", colunas)
  )
fecha

campo centraliza() -> Lista<DeclaracaoCss> ::
  devolve lista_de(
    decl("display", "grid"),
    decl("place-items", "center")
  )
fecha

campo espacamento(valor: Texto) -> DeclaracaoCss ::
  devolve decl("gap", valor)
fecha

campo tamanho_total() -> Lista<DeclaracaoCss> ::
  devolve lista_de(
    decl("width", "100%"),
    decl("min-height", "100vh")
  )
fecha
