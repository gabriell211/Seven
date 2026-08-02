modulo seven.runtime.svbc.vm

usa std.base.resultado
usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode
usa seven.runtime.svbc.value
usa seven.runtime.svbc.syscall

molde QuadroVm ::
  campo: U32
  ip_retorno: U64
  locais: Lista<ValorVm>
fecha

molde EstadoVm ::
  imagem: ImagemSvbc
  ip: U64
  pilha: Lista<ValorVm>
  quadros: Lista<QuadroVm>
  memoria: Lista<BlocoMemoria>
  syscalls: TabelaSyscall
  rodando: Bit
  codigo_saida: Num
fecha

campo vm_nova(imagem: ImagemSvbc) -> EstadoVm ::
  devolve EstadoVm {
    imagem: imagem,
    ip: campo_entrada(imagem, "inicio"),
    pilha: lista<ValorVm>(),
    quadros: lista<QuadroVm>(),
    memoria: lista<BlocoMemoria>(),
    syscalls: syscall_tabela_padrao(),
    rodando: sim,
    codigo_saida: 0
  }
fecha

campo vm_executa(imagem: ImagemSvbc) -> Resultado<Num, Falha> toca rede, disco, terminal, tempo, ambiente, frontend ::
  solta vm := vm_nova(imagem)

  gira vm.rodando ::
    guarda passo := vm_passo(vm)

    veja passo e Falha ::
      devolve passo
    fecha
  fecha

  devolve Valor(vm.codigo_saida)
fecha

campo vm_passo(vm: EstadoVm) -> Resultado<Nada, Falha> toca rede, disco, terminal, tempo, ambiente, frontend ::
  guarda instr := lista_pega(vm.imagem.codigo, vm.ip)
  vira vm.ip := vm.ip + 1

  veja instr.opcode e Pare ::
    vira vm.rodando := nao
    devolve Valor(nulo)
  fecha

  veja instr.opcode e Const ::
    lista_coloca(vm.pilha, lista_pega(vm.imagem.constantes, instr.a))
    devolve Valor(nulo)
  fecha

  veja instr.opcode e Soma ::
    devolve vm_binaria(vm, "+")
  fecha

  veja instr.opcode e Sub ::
    devolve vm_binaria(vm, "-")
  fecha

  veja instr.opcode e Mul ::
    devolve vm_binaria(vm, "*")
  fecha

  veja instr.opcode e Div ::
    devolve vm_binaria(vm, "/")
  fecha

  veja instr.opcode e Salta ::
    vira vm.ip := instr.a
    devolve Valor(nulo)
  fecha

  veja instr.opcode e SaltaSeNao ::
    guarda cond := pilha_pop(vm)
    veja valor_verdadeiro(cond) == nao ::
      vira vm.ip := instr.a
    fecha
    devolve Valor(nulo)
  fecha

  veja instr.opcode e Syscall ::
    devolve vm_syscall(vm, instr)
  fecha

  veja instr.opcode e Volta ::
    devolve vm_retorna(vm)
  fecha

  devolve Falha(nova_falha("SVBC-VM-OP", "instrucao ainda nao implementada"))
fecha

campo campo_entrada(imagem: ImagemSvbc, nome: Texto) -> U64 ::
  para cada campo em imagem.campos ::
    veja campo.nome == nome ::
      devolve campo.entrada
    fecha
  fecha

  devolve 0
fecha

campo pilha_pop(vm: EstadoVm) -> ValorVm ::
  devolve sys_lista_pop(vm.pilha)
fecha

campo vm_binaria(vm: EstadoVm, operador: Texto) -> Resultado<Nada, Falha> ::
  guarda direita := pilha_pop(vm)
  guarda esquerda := pilha_pop(vm)
  guarda resultado := sys_vm_binaria(esquerda, operador, direita)

  veja resultado e Falha ::
    devolve resultado
  fecha

  lista_coloca(vm.pilha, resultado.valor)
  devolve Valor(nulo)
fecha

campo vm_syscall(vm: EstadoVm, instr: Instrucao) -> Resultado<Nada, Falha> toca rede, disco, terminal, tempo, ambiente, frontend ::
  guarda nome := lista_pega(vm.imagem.nomes, instr.a)
  guarda args := sys_vm_coleta_args(vm.pilha, instr.b)
  guarda saida := syscall_chama(vm.syscalls, nome, args)

  veja saida e Falha ::
    devolve saida
  fecha

  lista_coloca(vm.pilha, saida.valor)
  devolve Valor(nulo)
fecha

campo vm_retorna(vm: EstadoVm) -> Resultado<Nada, Falha> ::
  veja lista_tamanho(vm.quadros) == 0 ::
    guarda valor := pilha_pop(vm)
    vira vm.codigo_saida := valor_para_num(valor)
    vira vm.rodando := nao
    devolve Valor(nulo)
  fecha

  guarda quadro := sys_lista_pop(vm.quadros)
  vira vm.ip := quadro.ip_retorno
  devolve Valor(nulo)
fecha

campo valor_para_num(valor: ValorVm) -> Num ::
  veja valor e VmNum ::
    devolve valor.valor
  fecha
  veja valor e VmU64 ::
    devolve valor.valor
  fecha
  veja valor e VmBit ::
    veja valor.valor ::
      devolve 1
    outro ::
      devolve 0
    fecha
  fecha

  devolve 0
fecha
