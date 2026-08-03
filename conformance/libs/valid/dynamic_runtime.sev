modulo conformance.libs.valid.dynamic_runtime

usa std.base.resultado
usa std.data.object
usa std.runtime.event_loop
usa std.web.json

campo objeto_usuario() -> ObjetoDinamico ::
  guarda obj := objeto_coloca(objeto(), "nome", DynTexto("Seven"))
  devolve objeto_coloca(obj, "ativa", DynBit(sim))
fecha

campo valor_json() -> Json ::
  devolve dyn_para_json(DynObjeto(objeto_usuario()))
fecha

campo agenda(loop: EventLoop, acao: Campo<Nada, Nada>) -> Resultado<Nada, Falha> toca tempo ::
  devolve agenda_microtarefa(loop, acao)
fecha
