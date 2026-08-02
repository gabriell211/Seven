modulo seven.runtime.platform.svbc.bytes

usa seven.runtime.svbc.value

campo intr_bytes_novo(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmBytes(sys_bytes_novo()))
fecha

campo intr_texto_bytes(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  devolve Valor(VmBytes(sys_texto_bytes(valor_texto(lista_pega(args, 0)))))
fecha

campo intr_bytes_texto(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  guarda valor := lista_pega(args, 0)
  veja valor e VmBytes ::
    devolve Valor(VmTexto(sys_bytes_texto(valor.valor)))
  fecha
  devolve Falha(nova_falha("SVBC-TIPO", "esperado Bytes"))
fecha

campo intr_bytes_hex(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  guarda valor := lista_pega(args, 0)
  veja valor e VmBytes ::
    devolve Valor(VmTexto(sys_bytes_hex(valor.valor)))
  fecha
  devolve Falha(nova_falha("SVBC-TIPO", "esperado Bytes"))
fecha

campo intr_bytes_pega(args: Lista<ValorVm>) -> Resultado<ValorVm, Falha> ::
  guarda dados := lista_pega(args, 0)
  guarda indice := valor_vm_u64(lista_pega(args, 1))
  veja dados e VmBytes ::
    devolve Valor(VmU64(sys_bytes_pega(dados.valor, indice)))
  fecha
  devolve Falha(nova_falha("SVBC-TIPO", "esperado Bytes"))
fecha

campo valor_vm_u64(valor: ValorVm) -> U64 ::
  veja valor e VmU64 ::
    devolve valor.valor
  fecha
  veja valor e VmNum ::
    devolve valor.valor
  fecha
  devolve 0
fecha
