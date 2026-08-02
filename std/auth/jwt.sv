modulo std.auth.jwt

usa std.base.resultado
usa std.crypto.token
usa std.web.json

molde Jwt ::
  header: Json
  payload: Json
  assinatura: Texto
fecha

campo jwt_assina(payload: Json, segredo: Texto, expira_em: U64) -> TokenSeguro toca tempo ::
  guarda carga := json_codifica(payload)
  devolve token_novo(carga, segredo, expira_em)
fecha

campo jwt_confere(token: TokenSeguro, segredo: Texto) -> Resultado<Json, Falha> toca tempo ::
  guarda carga := token_confere(token, segredo)

  veja carga e Falha ::
    devolve carga
  fecha

  devolve json_parse(carga.valor)
fecha
