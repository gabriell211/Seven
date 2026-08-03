modulo seven.compiler.intelligence.autofix

usa std.base.talvez
usa seven.compiler.source
usa seven.compiler.intelligence.suggest

molde EdicaoTexto ::
  arquivo: Texto
  inicio: U64
  fim: U64
  texto: Texto
fecha

molde Autofix ::
  titulo: Texto
  sugestao: Sugestao
  edicoes: Lista<EdicaoTexto>
fecha

campo autofix_calcula(sugestao: Sugestao, fonte: Fonte) -> Talvez<Autofix> ::
  veja sugestao.aplicavel == nao ::
    devolve Vazio
  fecha

  veja sugestao.codigo == "SIA-MUTAVEL" ::
    devolve Algo(autofix_troca_guarda_por_solta(sugestao, fonte))
  fecha

  veja sugestao.codigo == "SIA-EFEITO-DECLARAR" ::
    devolve Algo(autofix_adiciona_efeito(sugestao, fonte))
  fecha

  devolve Vazio
fecha
