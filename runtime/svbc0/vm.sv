modulo seven.runtime.svbc0.vm

usa std.base.resultado
usa seven.runtime.svbc.value
usa seven.runtime.svbc0.image
usa seven.runtime.svbc0.opcode

molde EstadoVm0 ::
  imagem: ImagemSvbc0
  ip: U64
  pilha: Lista<ValorVm>
  rodando: Bit
  codigo_saida: Num
fecha

campo vm0_nova(imagem: ImagemSvbc0) -> EstadoVm0 ::
  devolve EstadoVm0 {
    imagem: imagem,
    ip: 0,
    pilha: lista<ValorVm>(),
    rodando: sim,
    codigo_saida: 0
  }
fecha

campo vm0_executa(imagem: ImagemSvbc0) -> Resultado<Num, Falha> ::
  solta vm := vm0_nova(imagem)

  gira vm.rodando ::
    guarda r := vm0_passo(vm)

    veja r e Falha ::
      devolve r
    fecha
  fecha

  devolve Valor(vm.codigo_saida)
fecha

campo vm0_passo(vm: EstadoVm0) -> Resultado<Nada, Falha> ::
  guarda instr := lista_pega(vm.imagem.codigo, vm.ip)
  vira vm.ip := vm.ip + 1

  veja instr.opcode e Pare0 ::
    vira vm.rodando := nao
    devolve Valor(nulo)
  fecha

  veja instr.opcode e ConstU32 ::
    lista_coloca(vm.pilha, VmU64(instr.a))
    devolve Valor(nulo)
  fecha

  veja instr.opcode e Soma0 ::
    devolve vm0_binaria(vm, "+")
  fecha

  veja instr.opcode e Retorna0 ::
    guarda valor := pilha_pop(vm)
    vira vm.codigo_saida := valor_para_num(valor)
    vira vm.rodando := nao
    devolve Valor(nulo)
  fecha

  devolve Falha(nova_falha("SVBC0-VM-OP", "instrucao Seven-0 ainda nao implementada"))
fecha

campo pilha_pop(vm: EstadoVm0) -> ValorVm ::
  devolve sys_lista_pop(vm.pilha)
fecha

campo vm0_binaria(vm: EstadoVm0, operador: Texto) -> Resultado<Nada, Falha> ::
  guarda direita := pilha_pop(vm)
  guarda esquerda := pilha_pop(vm)
  guarda resultado := sys_vm_binaria(esquerda, operador, direita)

  veja resultado e Falha ::
    devolve resultado
  fecha

  lista_coloca(vm.pilha, resultado.valor)
  devolve Valor(nulo)
fecha

campo valor_para_num(valor: ValorVm) -> Num ::
  veja valor e VmNum ::
    devolve valor.valor
  fecha
  veja valor e VmU64 ::
    devolve valor.valor
  fecha

  devolve 0
fecha
