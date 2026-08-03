modulo seven.compiler.debugger

usa seven.compiler.source
usa seven.runtime.svbc.image
usa seven.runtime.svbc.value

molde Breakpoint ::
  arquivo: Texto
  linha: U32
  coluna: U32
  ativo: Bit
fecha

molde FrameDebug ::
  campo: Texto
  ip: U64
  locais: Mapa<Texto, ValorVm>
fecha

molde SessaoDebug ::
  imagem: ImagemSvbc
  breakpoints: Lista<Breakpoint>
  frames: Lista<FrameDebug>
  pausado: Bit
  trace: Bit
  mostrar_locais: Bit
fecha

selo EventoDebug ::
  DebugIniciado
  DebugParou(bp: Breakpoint)
  DebugPasso(frame: FrameDebug)
  DebugSaiu(codigo: Num)
fecha

campo debug_sessao(imagem: ImagemSvbc) -> SessaoDebug ::
  devolve SessaoDebug {
    imagem: imagem,
    breakpoints: lista<Breakpoint>(),
    frames: lista<FrameDebug>(),
    pausado: nao,
    trace: nao,
    mostrar_locais: nao
  }
fecha

campo debug_breakpoint(sessao: SessaoDebug, arquivo: Texto, linha: U32) -> SessaoDebug ::
  lista_coloca(sessao.breakpoints, Breakpoint {
    arquivo: arquivo,
    linha: linha,
    coluna: 1,
    ativo: sim
  })

  devolve sessao
fecha

campo debug_trace(sessao: SessaoDebug, ativo: Bit) -> SessaoDebug ::
  vira sessao.trace := ativo
  devolve sessao
fecha

campo debug_locais(sessao: SessaoDebug, ativo: Bit) -> SessaoDebug ::
  vira sessao.mostrar_locais := ativo
  devolve sessao
fecha
