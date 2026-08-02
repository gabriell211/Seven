modulo seven.compiler.ir

usa seven.compiler.ast
usa seven.compiler.types
usa seven.compiler.effects

molde UnidadeIr ::
  campos: Lista<CampoIr>
  constantes: Lista<ConstanteIr>
fecha

molde CampoIr ::
  nome: Texto
  locais: Lista<Tipo>
  blocos: Lista<BlocoIr>
fecha

molde BlocoIr ::
  nome: Texto
  instrucoes: Lista<InstrucaoIr>
fecha

selo InstrucaoIr ::
  IrConst(destino: U32, valor: ValorIr)
  IrMove(destino: U32, origem: U32)
  IrBin(destino: U32, operador: Texto, esquerda: U32, direita: U32)
  IrChama(destino: U32, campo: Texto, argumentos: Lista<U32>)
  IrSalta(bloco: Texto)
  IrSaltaSeNao(condicao: U32, bloco: Texto)
  IrRetorna(origem: U32)
  IrCaixa(destino: U32, tamanho: U32)
  IrMarcaByte(bloco: U32, indice: U32, valor: U32)
  IrPegaByte(destino: U32, bloco: U32, indice: U32)
fecha

selo ValorIr ::
  ValorNum(Num)
  ValorTexto(Texto)
  ValorBit(Bit)
  ValorNulo
fecha

molde ConstanteIr ::
  nome: Texto
  valor: ValorIr
fecha

campo baixa_ir(programas: Lista<Programa>, tipos: TabelaTipos, efeitos: TabelaEfeitos) -> UnidadeIr ::
  solta unidade := UnidadeIr {
    campos: lista<CampoIr>(),
    constantes: lista<ConstanteIr>()
  }

  para cada programa em programas ::
    baixa_programa(programa, tipos, efeitos, unidade)
  fecha

  devolve unidade
fecha

campo otimiza_ir(unidade: UnidadeIr, modo: Texto) -> UnidadeIr ::
  guarda sem_morto := remove_codigo_morto(unidade)
  guarda constantes := dobra_constantes(sem_morto)
  devolve constantes
fecha
