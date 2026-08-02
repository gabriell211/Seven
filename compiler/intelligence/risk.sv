modulo seven.compiler.intelligence.risk

usa seven.compiler.ast
usa seven.compiler.ir
usa seven.compiler.intelligence.index

selo TipoRisco ::
  Seguranca
  Performance
  Memoria
  Concorrencia
  Efeito
fecha

molde Risco ::
  tipo: TipoRisco
  codigo: Texto
  mensagem: Texto
  arquivo: Texto
  linha: U32
  coluna: U32
fecha

campo riscos_programa(indice: IndiceSemantico, ir: UnidadeIr) -> Lista<Risco> ::
  solta riscos := lista<Risco>()

  riscos_codigo_cru(indice, riscos)
  riscos_n_mais_um(indice, riscos)
  riscos_alocacao_loop(ir, riscos)
  riscos_efeito_publico(indice, riscos)

  devolve riscos
fecha
