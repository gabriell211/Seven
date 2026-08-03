modulo seven.compiler.types

usa seven.compiler.ast
usa seven.compiler.symbols
usa seven.compiler.diagnostic

selo Tipo ::
  TipoBase(nome: Texto)
  TipoMolde(nome: Texto)
  TipoSelo(nome: Texto)
  TipoLista(item: Tipo)
  TipoFatia(item: Tipo)
  TipoPonteiro(item: Tipo)
  TipoGenerico(nome: Texto)
  TipoNada
fecha

molde TabelaTipos ::
  tipos: Mapa<Texto, Tipo>
  diagnosticos: Lista<Diagnostico>
fecha

campo tabela_tipos_base() -> TabelaTipos ::
  solta tabela := TabelaTipos {
    tipos: mapa<Texto, Tipo>(),
    diagnosticos: lista<Diagnostico>()
  }

  registra_tipo_base(tabela, "Bit")
  registra_tipo_base(tabela, "Byte")
  registra_tipo_base(tabela, "Num")
  registra_tipo_base(tabela, "U32")
  registra_tipo_base(tabela, "U64")
  registra_tipo_base(tabela, "Texto")
  registra_tipo_base(tabela, "Nada")

  devolve tabela
fecha

campo mede_tipos(programas: Lista<Programa>, simbolos: TabelaSimbolos) -> TabelaTipos ::
  guarda tabela := tabela_tipos_base()

  para cada programa em programas ::
    mede_programa(programa, simbolos, tabela)
  fecha

  devolve tabela
fecha
