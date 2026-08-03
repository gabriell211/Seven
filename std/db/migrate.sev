modulo std.db.migrate

usa std.base.resultado
usa std.db.client
usa std.db.query

molde Migracao ::
  versao: U64
  nome: Texto
  sobe: Texto
  desce: Texto
fecha

campo migracao(versao: U64, nome: Texto, sobe: Texto, desce: Texto) -> Migracao ::
  devolve Migracao {
    versao: versao,
    nome: nome,
    sobe: sobe,
    desce: desce
  }
fecha

campo migracoes_aplica(db: ConexaoDb, migracoes: Lista<Migracao>) -> Resultado<Nada, Falha> toca rede, disco ::
  para cada m em migracoes ::
    guarda r := db_executa(db, query(m.sobe))

    veja r e Falha ::
      devolve r
    fecha
  fecha

  devolve Valor(nulo)
fecha
