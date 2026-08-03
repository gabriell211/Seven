modulo seven.runtime.platform.svbc.pure

usa seven.runtime.svbc.value

campo intr_lista_coloca(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_lista_coloca(lista_pega(args, 0), lista_pega(args, 1)))
fecha

campo intr_lista_pega(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_lista_pega(lista_pega(args, 0), lista_pega(args, 1)))
fecha

campo intr_lista_pop(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_lista_pop_valor(lista_pega(args, 0)))
fecha

campo intr_lista_define(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_lista_define(lista_pega(args, 0), lista_pega(args, 1), lista_pega(args, 2)))
fecha

campo intr_mapa_coloca(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_mapa_coloca(lista_pega(args, 0), lista_pega(args, 1), lista_pega(args, 2)))
fecha

campo intr_mapa_pega(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(sys_vm_mapa_pega(lista_pega(args, 0), lista_pega(args, 1)))
fecha

campo intr_texto_tamanho(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmU64(tamanho(valor_texto(lista_pega(args, 0)))))
fecha

campo intr_texto_comeca(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmBit(sys_texto_comeca(valor_texto(lista_pega(args, 0)), valor_texto(lista_pega(args, 1)))))
fecha

campo intr_numero(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmNum(numero(valor_texto(lista_pega(args, 0)))))
fecha

campo intr_texto_num(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmTexto(valor_texto(lista_pega(args, 0))))
fecha

campo intr_vm_binaria(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve sys_vm_binaria(lista_pega(args, 0), valor_texto(lista_pega(args, 1)), lista_pega(args, 2))
fecha
