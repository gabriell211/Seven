modulo std.text.regex

usa std.base.resultado
usa std.base.talvez

molde Regex ::
  padrao: Texto
  flags: Texto
fecha

molde Match ::
  inicio: U64
  fim: U64
  grupos: Lista<Texto>
fecha

campo regex(padrao: Texto) -> Resultado<Regex, Falha> ::
  devolve sys_regex_compila(padrao, "")
fecha

campo regex_flags(padrao: Texto, flags: Texto) -> Resultado<Regex, Falha> ::
  devolve sys_regex_compila(padrao, flags)
fecha

campo regex_testa(r: Regex, texto: Texto) -> Bit ::
  devolve sys_regex_testa(r, texto)
fecha

campo regex_busca(r: Regex, texto: Texto) -> Talvez<Match> ::
  devolve sys_regex_busca(r, texto)
fecha
