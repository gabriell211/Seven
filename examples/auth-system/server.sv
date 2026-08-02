modulo examples.auth_system.server

usa std.config.app
usa std.crypto.token
usa std.db.client
usa std.db.query
usa std.web.cookie
usa std.web.forms
usa std.web.http
usa std.web.router
usa std.web.server
usa std.web.session

campo tela_login(ctx: Contexto) -> Resposta ::
  devolve html(
    "<!doctype html><html><body><form method=\"post\" action=\"/login\"><input name=\"email\"><input name=\"senha\" type=\"password\"><button>entrar</button></form></body></html>"
  )
fecha

campo login(ctx: Contexto) -> Resposta toca ambiente, rede, disco, tempo ::
  guarda cfg := config_carrega("seven-auth")
  guarda form := formulario_ler(ctx.requisicao)
  guarda email := formulario_pega(form.valor, "email")
  guarda senha := formulario_pega(form.valor, "senha")
  guarda db := db_conecta(cfg.valor.banco_url)

  solta q := query("select id from users where email = ? and password_hash = ?")
  vira q := query_param(q, ParamTexto(email.valor))
  vira q := query_param(q, ParamTexto(hash_senha(senha.valor)))

  guarda usuario := db_executa(db.valor, q)

  veja usuario.valor.linhas.tamanho == 0 ::
    devolve resposta(401, "credenciais invalidas")
  fecha

  guarda sessao := Sessao {
    id: texto(usuario.valor.linhas[0].campos[0]),
    usuario: email.valor,
    expira_em: tempo_agora() + 86400
  }

  guarda c := sessao_cookie(sessao, cfg.valor.segredo)

  devolve Resposta {
    status: 303,
    cabecalhos: lista_de(cookie_header(c), cabecalho("location", "/app")),
    corpo: texto_bytes("")
  }
fecha

campo app(ctx: Contexto) -> Resposta toca ambiente, tempo ::
  guarda cfg := config_carrega("seven-auth")
  guarda sessao := sessao_ler(ctx.requisicao, cfg.valor.segredo)

  veja sessao e Falha ::
    devolve resposta(401, "sessao invalida")
  fecha

  devolve html("<!doctype html><html><body>Ola, " + sessao.valor.usuario + "</body></html>")
fecha

campo inicio() -> Num toca rede, terminal, ambiente, disco, tempo ::
  solta rotas := roteador()

  vira rotas := adiciona_rota(rotas, GET, "/login", tela_login)
  vira rotas := adiciona_rota(rotas, POST, "/login", login)
  vira rotas := adiciona_rota(rotas, GET, "/app", app)

  servir(servidor("0.0.0.0", 7070, rotas))
  devolve 0
fecha
