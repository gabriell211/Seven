modulo std.async.task

usa std.base.resultado

selo EstadoTarefa ::
  Criada
  Rodando
  Completa
  Cancelada
  Falhou
fecha

molde Tarefa<T> ::
  id: U64
  estado: EstadoTarefa
fecha

molde GrupoTarefas ::
  id: U64
fecha

campo grupo_novo() -> GrupoTarefas toca tempo ::
  devolve sys_grupo_novo()
fecha

campo tarefa_inicia<T>(grupo: GrupoTarefas, acao: Campo<Nada, T>) -> Tarefa<T> toca tempo ::
  devolve sys_tarefa_inicia(grupo, acao)
fecha

campo tarefa_aguarda<T>(tarefa: Tarefa<T>) -> Resultado<T, Falha> toca tempo ::
  devolve sys_tarefa_aguarda(tarefa)
fecha

campo grupo_aguarda(grupo: GrupoTarefas) -> Resultado<Nada, Falha> toca tempo ::
  devolve sys_grupo_aguarda(grupo)
fecha
