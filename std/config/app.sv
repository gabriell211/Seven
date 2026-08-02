modulo std.config.app

usa std.base.resultado
usa std.base.convert
usa std.env.runtime

molde ConfigApp ::
  nome: Texto
  ambiente: Texto
  porta: U32
  banco_url: Texto
  segredo: Texto
fecha

campo config_carrega(nome: Texto) -> Resultado<ConfigApp, Falha> toca ambiente ::
  guarda ambiente := env_ou("SEVEN_ENV", "dev")
  guarda porta := numero(env_ou("PORT", "7070"))
  guarda banco := env_ou("DATABASE_URL", "")
  guarda segredo := env_ou("APP_SECRET", "dev-secret")

  devolve Valor(ConfigApp {
    nome: nome,
    ambiente: ambiente,
    porta: porta,
    banco_url: banco,
    segredo: segredo
  })
fecha
