modulo seven.runtime.svbc0.translator

usa seven.runtime.svbc.image
usa seven.runtime.svbc.opcode
usa seven.runtime.svbc.value
usa seven.runtime.svbc0.image
usa seven.runtime.svbc0.opcode

campo svbc0_para_svbc(img0: ImagemSvbc0) -> ImagemSvbc ::
  solta img := imagem_vazia()

  para cada texto_const em img0.constantes_texto ::
    lista_coloca(img.constantes, VmTexto(texto_const))
  fecha

  para cada n em img0.constantes_u32 ::
    lista_coloca(img.constantes, VmU64(n))
  fecha

  para cada instr0 em img0.codigo ::
    lista_coloca(img.codigo, traduz_instrucao(instr0))
  fecha

  devolve img
fecha

campo traduz_instrucao(instr0: Instrucao0) -> Instrucao ::
  devolve Instrucao {
    opcode: traduz_opcode(instr0.opcode),
    a: instr0.a,
    b: instr0.b,
    c: 0,
    ip: instr0.ip
  }
fecha

campo traduz_opcode(op: Opcode0) -> Opcode ::
  veja op e Pare0 ::
    devolve Pare
  fecha
  veja op e ConstU32 ::
    devolve Const
  fecha
  veja op e Soma0 ::
    devolve Soma
  fecha
  veja op e Retorna0 ::
    devolve Volta
  fecha

  devolve Syscall
fecha
