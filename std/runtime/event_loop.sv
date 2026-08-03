modulo std.runtime.event_loop

usa std.base.resultado

selo EstadoLoop ::
  LoopCriado
  LoopRodando
  LoopParado
fecha

molde EventLoop ::
  id: U64
  estado: EstadoLoop
fecha

molde Temporizador ::
  id: U64
  ativo: Bit
fecha

campo loop_atual() -> EventLoop toca tempo ::
  devolve sys_loop_atual()
fecha

campo agenda_microtarefa(loop: EventLoop, acao: Campo<Nada, Nada>) -> Resultado<Nada, Falha> toca tempo ::
  devolve sys_loop_microtarefa(loop, acao)
fecha

campo agenda_timeout(loop: EventLoop, ms: U64, acao: Campo<Nada, Nada>) -> Resultado<Temporizador, Falha> toca tempo ::
  devolve sys_loop_timeout(loop, ms, acao)
fecha

campo cancela_timeout(timer: Temporizador) -> Resultado<Nada, Falha> toca tempo ::
  devolve sys_loop_cancela_timeout(timer)
fecha

campo loop_roda(loop: EventLoop) -> Resultado<Nada, Falha> toca tempo ::
  devolve sys_loop_roda(loop)
fecha

campo loop_para(loop: EventLoop) -> Resultado<Nada, Falha> toca tempo ::
  devolve sys_loop_para(loop)
fecha
