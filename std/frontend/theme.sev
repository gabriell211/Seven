modulo std.frontend.theme

usa std.frontend.css

molde Tema ::
  nome: Texto
  tokens: Lista<DeclaracaoCss>
fecha

campo tema(nome: Texto) -> Tema ::
  devolve Tema {
    nome: nome,
    tokens: lista<DeclaracaoCss>()
  }
fecha

campo token(t: Tema, nome: Texto, valor: Texto) -> Tema ::
  lista_coloca(t.tokens, decl("--" + nome, valor))
  devolve t
fecha

campo tema_aplica(folha: FolhaCss, t: Tema) -> FolhaCss ::
  para cada item em t.tokens ::
    lista_coloca(folha.variaveis, item)
  fecha

  devolve folha
fecha

campo tema_padrao() -> Tema ::
  solta t := tema("seven")

  vira t := token(t, "cor-fundo", "#0f172a")
  vira t := token(t, "cor-painel", "#111827")
  vira t := token(t, "cor-texto", "#f8fafc")
  vira t := token(t, "cor-suave", "#94a3b8")
  vira t := token(t, "cor-acao", "#22c55e")
  vira t := token(t, "raio", "8px")
  vira t := token(t, "espaco", "16px")

  devolve t
fecha
