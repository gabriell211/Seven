modulo examples.fullstack_blog.server

usa std.config.app
usa std.db.client
usa std.db.query
usa std.log.logger
usa std.web.forms
usa std.web.html
usa std.web.http
usa std.web.router
usa std.web.server

campo pagina_home(ctx: Contexto) -> Resposta toca rede, disco ::
  guarda cfg := config_carrega("seven-blog")
  guarda db := db_conecta(cfg.valor.banco_url)
  guarda posts := db_executa(db.valor, query("select title, body from posts order by id desc"))

  guarda corpo := lista_de(
    elem("h1", lista<Atributo>(), lista_de(texto_no("Seven Blog"))),
    elem("form", lista_de(attr("method", "post"), attr("action", "/posts")), lista_de(
      elem("input", lista_de(attr("name", "title"), attr("placeholder", "titulo")), lista<NoHtml>()),
      elem("textarea", lista_de(attr("name", "body")), lista<NoHtml>()),
      elem("button", lista<Atributo>(), lista_de(texto_no("publicar")))
    )),
    render_posts(posts.valor)
  )

  devolve html(pagina("Seven Blog", corpo))
fecha

campo cria_post(ctx: Contexto) -> Resposta toca rede, disco ::
  guarda cfg := config_carrega("seven-blog")
  guarda db := db_conecta(cfg.valor.banco_url)
  guarda form := formulario_ler(ctx.requisicao)
  guarda titulo := formulario_pega(form.valor, "title")
  guarda corpo := formulario_pega(form.valor, "body")

  solta q := query("insert into posts(title, body) values(?, ?)")
  vira q := query_param(q, ParamTexto(titulo.valor))
  vira q := query_param(q, ParamTexto(corpo.valor))

  db_executa(db.valor, q)

  devolve Resposta {
    status: 303,
    cabecalhos: lista_de(cabecalho("location", "/")),
    corpo: texto_bytes("")
  }
fecha

campo inicio() -> Num toca rede, terminal, ambiente, disco ::
  guarda log := logger("blog")
  solta rotas := roteador()

  vira rotas := adiciona_rota(rotas, GET, "/", pagina_home)
  vira rotas := adiciona_rota(rotas, POST, "/posts", cria_post)

  log_info(log, "blog pronto")
  servir(servidor("0.0.0.0", 7070, rotas))

  devolve 0
fecha
