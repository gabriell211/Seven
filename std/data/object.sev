modulo std.data.object

usa std.base.resultado
usa std.web.json

molde ObjetoDinamico ::
  id: U64
fecha

selo ValorDinamico ::
  DynNulo
  DynBit(valor: Bit)
  DynNum(valor: Num)
  DynTexto(valor: Texto)
  DynLista(valor: Lista<ValorDinamico>)
  DynObjeto(valor: ObjetoDinamico)
fecha

campo objeto() -> ObjetoDinamico ::
  devolve sys_obj_novo()
fecha

campo objeto_coloca(obj: ObjetoDinamico, chave: Texto, valor: ValorDinamico) -> ObjetoDinamico ::
  devolve sys_obj_coloca(obj, chave, valor)
fecha

campo objeto_pega(obj: ObjetoDinamico, chave: Texto) -> Resultado<ValorDinamico, Falha> ::
  devolve sys_obj_pega(obj, chave)
fecha

campo objeto_tem(obj: ObjetoDinamico, chave: Texto) -> Bit ::
  devolve sys_obj_tem(obj, chave)
fecha

campo objeto_remove(obj: ObjetoDinamico, chave: Texto) -> ObjetoDinamico ::
  devolve sys_obj_remove(obj, chave)
fecha

campo objeto_chaves(obj: ObjetoDinamico) -> Lista<Texto> ::
  devolve sys_obj_chaves(obj)
fecha

campo dyn_de_json(valor: Json) -> ValorDinamico ::
  devolve sys_obj_de_json(valor)
fecha

campo dyn_para_json(valor: ValorDinamico) -> Json ::
  devolve sys_obj_para_json(valor)
fecha
