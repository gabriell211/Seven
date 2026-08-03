modulo std.db.query

usa std.mem.bytes

selo ParametroDb ::
  ParamTexto(valor: Texto)
  ParamNum(valor: Num)
  ParamBit(valor: Bit)
  ParamBytes(valor: Bytes)
  ParamNulo
fecha

molde QueryDb ::
  texto: Texto
  parametros: Lista<ParametroDb>
fecha

campo query(texto: Texto) -> QueryDb ::
  devolve QueryDb {
    texto: texto,
    parametros: lista<ParametroDb>()
  }
fecha

campo query_param(query_db: QueryDb, valor: ParametroDb) -> QueryDb ::
  lista_coloca(query_db.parametros, valor)
  devolve query_db
fecha
