modulo conformance.libs.valid.serialization

usa std.serial.csv
usa std.serial.yaml
usa std.web.json

campo cria_json() -> Texto ::
  solta campos := lista<JsonCampo>()
  lista_coloca(campos, json_campo("ok", JBit(sim)))
  devolve yaml_codifica(json_objeto(campos))
fecha
