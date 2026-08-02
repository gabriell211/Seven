modulo conformance.fullstack.valid.json_response

usa std.web.http
usa std.web.json

campo cria() -> Resposta ::
  solta campos := lista<JsonCampo>()
  lista_coloca(campos, json_campo("ok", JBit(sim)))
  devolve json(json_codifica(json_objeto(campos)))
fecha
