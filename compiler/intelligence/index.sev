modulo seven.compiler.intelligence.index

usa seven.compiler.ast
usa seven.compiler.diagnostic
usa seven.compiler.symbols
usa seven.compiler.types
usa seven.compiler.effects

molde NoIndice ::
  id: Texto
  nome: Texto
  especie: Texto
  modulo: Texto
  tipo: Texto
fecha

molde ArestaIndice ::
  origem: Texto
  destino: Texto
  especie: Texto
fecha

molde IndiceSemantico ::
  nos: Lista<NoIndice>
  arestas: Lista<ArestaIndice>
  simbolos: TabelaSimbolos
  tipos: TabelaTipos
  efeitos: TabelaEfeitos
fecha

campo indice_vazio() -> IndiceSemantico ::
  devolve IndiceSemantico {
    nos: lista<NoIndice>(),
    arestas: lista<ArestaIndice>(),
    simbolos: TabelaSimbolos {
      simbolos: mapa<Texto, Simbolo>(),
      diagnosticos: lista<Diagnostico>()
    },
    tipos: tabela_tipos_base(),
    efeitos: TabelaEfeitos {
      assinaturas: mapa<Texto, AssinaturaEfeitos>(),
      diagnosticos: lista<Diagnostico>()
    }
  }
fecha

campo indice_cria(programas: Lista<Programa>, simbolos: TabelaSimbolos, tipos: TabelaTipos, efeitos: TabelaEfeitos) -> IndiceSemantico ::
  solta indice := IndiceSemantico {
    nos: lista<NoIndice>(),
    arestas: lista<ArestaIndice>(),
    simbolos: simbolos,
    tipos: tipos,
    efeitos: efeitos
  }

  para cada programa em programas ::
    indice_programa(indice, programa)
  fecha

  devolve indice
fecha

campo indice_busca(indice: IndiceSemantico, nome: Texto) -> Lista<NoIndice> ::
  solta achados := lista<NoIndice>()

  para cada no em indice.nos ::
    veja no.nome == nome ::
      lista_coloca(achados, no)
    fecha
  fecha

  devolve achados
fecha
