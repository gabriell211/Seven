modulo conformance.runtime.valid.svbc0_return

usa seven.runtime.svbc0.image
usa seven.runtime.svbc0.opcode
usa seven.runtime.svbc0.vm

campo cria_imagem() -> ImagemSvbc0 ::
  solta img := svbc0_vazia()

  lista_coloca(img.codigo, Instrucao0 {
    opcode: ConstU32,
    a: 0,
    b: 0,
    ip: 0
  })

  lista_coloca(img.codigo, Instrucao0 {
    opcode: Retorna0,
    a: 0,
    b: 0,
    ip: 1
  })

  devolve img
fecha

campo inicio() -> Num ::
  guarda saida := vm0_executa(cria_imagem())

  veja saida e Falha ::
    devolve 1
  fecha

  devolve saida.valor
fecha
