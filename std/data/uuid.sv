modulo std.data.uuid

usa std.base.resultado

molde Uuid ::
  valor: Texto
fecha

campo uuid_parse(valor: Texto) -> Resultado<Uuid, Falha> ::
  devolve sys_uuid_parse(valor)
fecha

campo uuid_texto(id: Uuid) -> Texto ::
  devolve id.valor
fecha
