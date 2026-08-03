modulo seven.compiler.effects

usa seven.compiler.ast
usa seven.compiler.symbols
usa seven.compiler.diagnostic

selo Efeito ::
  Terminal
  Disco
  Rede
  Tempo
  Ambiente
  Cru
  Teste
fecha

molde AssinaturaEfeitos ::
  campo: Texto
  efeitos: Lista<Efeito>
fecha

molde TabelaEfeitos ::
  assinaturas: Mapa<Texto, AssinaturaEfeitos>
  diagnosticos: Lista<Diagnostico>
fecha

campo mede_efeitos(programas: Lista<Programa>, simbolos: TabelaSimbolos) -> TabelaEfeitos ::
  solta tabela := TabelaEfeitos {
    assinaturas: mapa<Texto, AssinaturaEfeitos>(),
    diagnosticos: lista<Diagnostico>()
  }

  para cada programa em programas ::
    confere_efeitos_programa(programa, simbolos, tabela)
  fecha

  devolve tabela
fecha
