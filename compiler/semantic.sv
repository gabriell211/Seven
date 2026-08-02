modulo seven.compiler.semantic

usa seven.compiler.ast
usa seven.compiler.symbols
usa seven.compiler.types
usa seven.compiler.effects

molde UnidadeSemantica ::
  programas: Lista<Programa>
  simbolos: TabelaSimbolos
  tipos: TabelaTipos
  efeitos: TabelaEfeitos
fecha

campo mede(programas: Lista<Programa>, pacote: Pacote) -> UnidadeSemantica ::
  guarda simbolos := liga_unidade(programas, pacote)
  guarda tipos := mede_tipos(programas, simbolos)
  guarda efeitos := mede_efeitos(programas, simbolos)

  devolve UnidadeSemantica {
    programas: programas,
    simbolos: simbolos,
    tipos: tipos,
    efeitos: efeitos
  }
fecha
