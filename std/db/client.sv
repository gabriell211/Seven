modulo std.db.client

usa std.base.resultado
usa std.db.query
usa std.mem.bytes

molde ConexaoDb ::
  id: U64
  fornecedor: Texto
fecha

molde LinhaDb ::
  campos: Lista<ValorDb>
fecha

selo ValorDb ::
  DbNulo
  DbTexto(valor: Texto)
  DbNum(valor: Num)
  DbBit(valor: Bit)
  DbBytes(valor: Bytes)
fecha

molde ResultadoConsulta ::
  linhas: Lista<LinhaDb>
  afetadas: U64
fecha

campo db_conecta(url: Texto) -> Resultado<ConexaoDb, Falha> toca rede, disco ::
  devolve sys_db_conecta(url)
fecha

campo db_executa(conexao: ConexaoDb, query: QueryDb) -> Resultado<ResultadoConsulta, Falha> toca rede, disco ::
  devolve sys_db_executa(conexao, query)
fecha

campo db_fecha(conexao: ConexaoDb) -> Nada toca rede, disco ::
  sys_db_fecha(conexao)
fecha
