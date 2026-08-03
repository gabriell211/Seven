modulo conformance.frontend.valid.css_sheet

usa std.frontend.css

campo cria() -> FolhaCss ::
  solta folha := css("teste")
  vira folha := css_var(folha, "cor", "#22c55e")
  vira folha := css_regra(folha, ".btn", lista_de(
    decl("color", var_css("cor"))
  ))
  devolve folha
fecha
