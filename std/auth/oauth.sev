modulo std.auth.oauth

usa std.base.resultado
usa std.base.texto
usa std.web.client
usa std.web.json

molde OAuthCliente ::
  client_id: Texto
  client_secret: Texto
  authorize_url: Texto
  token_url: Texto
  redirect_uri: Texto
fecha

molde OAuthToken ::
  access_token: Texto
  refresh_token: Texto
  expira_em: U64
fecha

campo oauth_url(cliente: OAuthCliente, estado: Texto, escopos: Lista<Texto>) -> Texto ::
  devolve cliente.authorize_url + "?client_id=" + url_encode(cliente.client_id) + "&redirect_uri=" + url_encode(cliente.redirect_uri) + "&state=" + url_encode(estado) + "&scope=" + url_encode(junta_com(" ", escopos))
fecha

campo oauth_token(cliente: OAuthCliente, codigo: Texto) -> Resultado<OAuthToken, Falha> toca rede ::
  devolve sys_oauth_token(cliente, codigo)
fecha
