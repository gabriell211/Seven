modulo seven.compiler.symbols

usa seven.compiler.ast
usa seven.compiler.diagnostic
usa seven.compiler.package

selo SimboloTipo ::
  SimboloCampo
  SimboloMolde
  SimboloSelo
  SimboloConstante
  SimboloLocal
  SimboloExterno
fecha

molde Simbolo ::
  nome: Texto
  caminho: Texto
  tipo: SimboloTipo
  publico: Bit
fecha

molde TabelaSimbolos ::
  simbolos: Mapa<Texto, Simbolo>
  diagnosticos: Lista<Diagnostico>
fecha

campo liga_unidade(programas: Lista<Programa>, pacote: Pacote) -> TabelaSimbolos ::
  solta tabela := TabelaSimbolos {
    simbolos: mapa<Texto, Simbolo>(),
    diagnosticos: lista<Diagnostico>()
  }

  para cada programa em programas ::
    registra_itens(tabela, programa, pacote)
  fecha

  para cada programa em programas ::
    resolve_usos(tabela, programa, pacote)
  fecha

  devolve tabela
fecha
