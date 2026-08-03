modulo examples.api_server.main

usa std.config.app
usa std.log.logger
usa std.web.http
usa std.web.json
usa std.web.router
usa std.web.security
usa std.web.server

campo health(ctx: Contexto) -> Resposta ::
  solta campos := lista<JsonCampo>()
  lista_coloca(campos, json_campo("status", json_texto("ok")))
  lista_coloca(campos, json_campo("language", json_texto("Seven")))
  lista_coloca(campos, json_campo("creator", json_texto("Gabriel Barcelos")))

  devolve json(json_codifica(json_objeto(campos)))
fecha

campo inicio() -> Num toca rede, terminal, ambiente ::
  guarda cfg := config_carrega("seven-api")
  guarda log := logger("api")
  solta rotas := roteador()

  vira rotas := adiciona_rota(rotas, GET, "/health", health)

  log_info(log, "subindo servidor")
  servir(servidor("0.0.0.0", cfg.valor.porta, rotas))

  devolve 0
fecha
