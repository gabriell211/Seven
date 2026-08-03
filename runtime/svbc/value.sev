modulo seven.runtime.svbc.value

selo ValorVm ::
  VmNada
  VmBit(valor: Bit)
  VmU64(valor: U64)
  VmNum(valor: Num)
  VmReal(valor: Real64)
  VmTexto(valor: Texto)
  VmArgs(valores: Lista<Texto>)
  VmBytes(valor: Bytes)
  VmBloco(id: U64)
fecha

molde BlocoMemoria ::
  id: U64
  dados: Bytes
  tamanho: U64
fecha

campo valor_verdadeiro(valor: ValorVm) -> Bit ::
  veja valor e VmNada ::
    devolve nao
  fecha
  veja valor e VmBit ::
    devolve valor.valor
  fecha
  veja valor e VmU64 ::
    devolve valor.valor != 0
  fecha
  veja valor e VmNum ::
    devolve valor.valor != 0
  fecha
  veja valor e VmTexto ::
    devolve tamanho(valor.valor) > 0
  fecha
  veja valor e VmArgs ::
    devolve lista_tamanho(valor.valores) > 0
  fecha

  devolve sim
fecha

campo valor_texto(valor: ValorVm) -> Texto ::
  veja valor e VmNada ::
    devolve "nulo"
  fecha
  veja valor e VmBit ::
    veja valor.valor ::
      devolve "sim"
    outro ::
      devolve "nao"
    fecha
  fecha
  veja valor e VmU64 ::
    devolve texto_u64(valor.valor)
  fecha
  veja valor e VmNum ::
    devolve texto(valor.valor)
  fecha
  veja valor e VmTexto ::
    devolve valor.valor
  fecha
  veja valor e VmArgs ::
    devolve "<args>"
  fecha

  devolve "<valor>"
fecha
