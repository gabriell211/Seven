modulo std.serial.toml

usa std.base.resultado
usa std.web.json

campo toml_parse(texto_toml: Texto) -> Resultado<Json, Falha> ::
  devolve sys_toml_parse(texto_toml)
fecha

campo toml_codifica(valor: Json) -> Texto ::
  devolve sys_toml_codifica(valor)
fecha
