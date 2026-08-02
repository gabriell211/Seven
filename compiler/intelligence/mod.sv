modulo seven.compiler.intelligence

usa seven.compiler.ast
usa seven.compiler.symbols
usa seven.compiler.types
usa seven.compiler.effects
usa seven.compiler.ir
usa seven.compiler.diagnostic
usa seven.compiler.intelligence.index
usa seven.compiler.intelligence.suggest
usa seven.compiler.intelligence.risk

molde RelatorioInteligencia ::
  indice: IndiceSemantico
  sugestoes: Lista<Sugestao>
  riscos: Lista<Risco>
fecha

campo analisa_inteligencia(
  programas: Lista<Programa>,
  simbolos: TabelaSimbolos,
  tipos: TabelaTipos,
  efeitos: TabelaEfeitos,
  ir: UnidadeIr,
  diagnosticos: Lista<Diagnostico>
) -> RelatorioInteligencia ::
  guarda indice := indice_cria(programas, simbolos, tipos, efeitos)
  solta sugestoes := lista<Sugestao>()

  para cada diag em diagnosticos ::
    para cada s em sugestoes_para(diag, indice) ::
      lista_coloca(sugestoes, s)
    fecha
  fecha

  devolve RelatorioInteligencia {
    indice: indice,
    sugestoes: sugestoes,
    riscos: riscos_programa(indice, ir)
  }
fecha
