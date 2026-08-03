modulo std.env.runtime

usa std.base.resultado

campo env(nome: Texto) -> Resultado<Texto, Falha> toca ambiente ::
  guarda valor := sys_env(nome)

  veja valor e Vazio ::
    devolve Falha(nova_falha("SV-ENV-AUSENTE", "variavel ausente: " + nome))
  outro ::
    devolve Valor(valor.valor)
  fecha
fecha

campo args() -> Lista<Texto> toca ambiente ::
  devolve sys_args()
fecha

campo env_ou(nome: Texto, padrao: Texto) -> Texto toca ambiente ::
  guarda valor := env(nome)

  veja valor e Falha ::
    devolve padrao
  outro ::
    devolve valor.valor
  fecha
fecha
