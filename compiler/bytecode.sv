modulo seven.compiler.bytecode

usa seven.compiler.ir
usa std.base.lista
usa std.mem.bytes

const SvbcMagic: Texto := "SVBC"
const SvbcVersao: U32 := 1

selo Opcode ::
  Pare
  Const
  Carrega
  Guarda
  Soma
  Sub
  Mul
  Div
  Igual
  Diferente
  Menor
  MenorIgual
  Maior
  MaiorIgual
  Salta
  SaltaSeNao
  Chama
  Volta
  Caixa
  MarcaByte
  PegaByte
  Efeito
  Syscall
fecha

molde ImagemBytecode ::
  bytes: Bytes
  mapa: Mapa<U64, Texto>
fecha

campo emite_svbc(unidade: UnidadeIr) -> Bytes ::
  solta bytes := bytes_novo()

  bytes_coloca_texto(bytes, SvbcMagic)
  bytes_coloca_u32(bytes, SvbcVersao)
  emite_nomes(bytes, unidade)
  emite_tabela_constantes(bytes, unidade)
  emite_campos(bytes, unidade)
  emite_codigo(bytes, unidade)

  devolve bytes
fecha

campo emite_nomes(bytes: Bytes, unidade: UnidadeIr) -> Nada ::
  bytes_coloca_u32(bytes, lista_tamanho(unidade.campos))

  para cada item em unidade.campos ::
    bytes_coloca_texto_com_tamanho(bytes, item.nome)
  fecha
fecha

campo emite_tabela_constantes(bytes: Bytes, unidade: UnidadeIr) -> Nada ::
  bytes_coloca_u32(bytes, lista_tamanho(unidade.constantes))

  para cada constante em unidade.constantes ::
    emite_constante(bytes, constante.valor)
  fecha
fecha

campo emite_constante(bytes: Bytes, valor: ValorIr) -> Nada ::
  veja valor e ValorNum ::
    bytes_coloca_byte(bytes, 3)
    bytes_coloca_u64(bytes, valor.valor)
  fecha

  veja valor e ValorTexto ::
    bytes_coloca_byte(bytes, 4)
    bytes_coloca_texto_com_tamanho(bytes, valor.valor)
  fecha

  veja valor e ValorBit ::
    bytes_coloca_byte(bytes, 2)
    veja valor.valor ::
      bytes_coloca_byte(bytes, 1)
    outro ::
      bytes_coloca_byte(bytes, 0)
    fecha
  fecha

  veja valor e ValorNulo ::
    bytes_coloca_byte(bytes, 0)
  fecha
fecha

campo emite_campos(bytes: Bytes, unidade: UnidadeIr) -> Nada ::
  bytes_coloca_u32(bytes, lista_tamanho(unidade.campos))

  solta indice := 0
  solta entrada := 0
  para cada item em unidade.campos ::
    bytes_coloca_u32(bytes, indice)
    bytes_coloca_u64(bytes, entrada)
    bytes_coloca_u32(bytes, lista_tamanho(item.locais))
    bytes_coloca_u32(bytes, 0)
    bytes_coloca_u32(bytes, 0)
    vira entrada := entrada + conta_instrucoes(item)
    vira indice := indice + 1
  fecha
fecha

campo emite_codigo(bytes: Bytes, unidade: UnidadeIr) -> Nada ::
  solta total := 0

  para cada item em unidade.campos ::
    vira total := total + conta_instrucoes(item)
  fecha

  veja total == 0 ::
    bytes_coloca_u32(bytes, 1)
    emite_instrucao_svbc(bytes, Pare, 0, 0, 0, 0)
    devolve nulo
  fecha

  bytes_coloca_u32(bytes, total)
  solta ip := 0

  para cada item em unidade.campos ::
    para cada bloco em item.blocos ::
      para cada instr em bloco.instrucoes ::
        emite_ir(bytes, unidade, item, instr, ip)
        vira ip := ip + conta_instrucao_ir(instr)
      fecha
    fecha
  fecha
fecha

campo conta_instrucoes(campo: CampoIr) -> U64 ::
  solta total := 0

  para cada bloco em campo.blocos ::
    para cada instr em bloco.instrucoes ::
      vira total := total + conta_instrucao_ir(instr)
    fecha
  fecha

  devolve total
fecha

campo conta_instrucoes_bloco(bloco: BlocoIr) -> U32 ::
  solta total := 0

  para cada instr em bloco.instrucoes ::
    vira total := total + conta_instrucao_ir(instr)
  fecha

  devolve total
fecha

campo conta_instrucao_ir(instr: InstrucaoIr) -> U64 ::
  veja instr e IrConst ::
    devolve 2
  fecha
  veja instr e IrMove ::
    devolve 2
  fecha
  veja instr e IrBin ::
    devolve 4
  fecha
  veja instr e IrChama ::
    devolve lista_tamanho(instr.argumentos) + 2
  fecha
  veja instr e IrSaltaSeNao ::
    devolve 2
  fecha
  veja instr e IrRetorna ::
    devolve 2
  fecha

  devolve 1
fecha

campo emite_ir(bytes: Bytes, unidade: UnidadeIr, campo_atual: CampoIr, instr: InstrucaoIr, ip: U64) -> Nada ::
  veja instr e IrConst ::
    emite_instrucao_svbc(bytes, Const, indice_constante(unidade.constantes, instr.valor), 0, 0, ip)
    emite_instrucao_svbc(bytes, Guarda, instr.destino, 0, 0, ip + 1)
    devolve nulo
  fecha

  veja instr e IrMove ::
    emite_instrucao_svbc(bytes, Carrega, instr.origem, 0, 0, ip)
    emite_instrucao_svbc(bytes, Guarda, instr.destino, 0, 0, ip + 1)
    devolve nulo
  fecha

  veja instr e IrBin ::
    emite_instrucao_svbc(bytes, Carrega, instr.esquerda, 0, 0, ip)
    emite_instrucao_svbc(bytes, Carrega, instr.direita, 0, 0, ip + 1)
    emite_instrucao_svbc(bytes, opcode_binario(instr.operador), 0, 0, 0, ip + 2)
    emite_instrucao_svbc(bytes, Guarda, instr.destino, 0, 0, ip + 3)
    devolve nulo
  fecha

  veja instr e IrChama ::
    solta deslocamento := 0
    para cada arg em instr.argumentos ::
      emite_instrucao_svbc(bytes, Carrega, arg, 0, 0, ip + deslocamento)
      vira deslocamento := deslocamento + 1
    fecha
    emite_instrucao_svbc(bytes, Chama, indice_campo(unidade.campos, instr.campo), lista_tamanho(instr.argumentos), 0, ip + deslocamento)
    emite_instrucao_svbc(bytes, Guarda, instr.destino, 0, 0, ip + deslocamento + 1)
    devolve nulo
  fecha

  veja instr e IrSalta ::
    emite_instrucao_svbc(bytes, Salta, ip_do_bloco(unidade, campo_atual.nome, instr.bloco), 0, 0, ip)
    devolve nulo
  fecha

  veja instr e IrSaltaSeNao ::
    emite_instrucao_svbc(bytes, Carrega, instr.condicao, 0, 0, ip)
    emite_instrucao_svbc(bytes, SaltaSeNao, ip_do_bloco(unidade, campo_atual.nome, instr.bloco), 0, 0, ip + 1)
    devolve nulo
  fecha

  veja instr e IrRetorna ::
    emite_instrucao_svbc(bytes, Carrega, instr.origem, 0, 0, ip)
    emite_instrucao_svbc(bytes, Volta, 0, 0, 0, ip + 1)
    devolve nulo
  fecha

  emite_instrucao_svbc(bytes, Pare, 0, 0, 0, ip)
fecha

campo ip_do_bloco(unidade: UnidadeIr, campo_nome: Texto, bloco_nome: Texto) -> U32 ::
  solta base := 0

  para cada campo em unidade.campos ::
    veja campo.nome == campo_nome ::
      solta deslocamento := 0

      para cada bloco em campo.blocos ::
        veja bloco.nome == bloco_nome ::
          devolve base + deslocamento
        fecha

        vira deslocamento := deslocamento + conta_instrucoes_bloco(bloco)
      fecha

      devolve base
    fecha

    vira base := base + conta_instrucoes(campo)
  fecha

  devolve 0
fecha

campo indice_campo(campos: Lista<CampoIr>, nome: Texto) -> U32 ::
  solta indice := 0

  para cada item em campos ::
    veja item.nome == nome ::
      devolve indice
    fecha

    vira indice := indice + 1
  fecha

  devolve 0
fecha

campo indice_constante(constantes: Lista<ConstanteIr>, valor: ValorIr) -> U32 ::
  solta indice := 0

  para cada item em constantes ::
    veja valor_ir_igual(item.valor, valor) ::
      devolve indice
    fecha

    vira indice := indice + 1
  fecha

  devolve 0
fecha

campo valor_ir_igual(a: ValorIr, b: ValorIr) -> Bit ::
  veja a e ValorNum ::
    veja b e ValorNum ::
      devolve a.valor == b.valor
    fecha
  fecha

  veja a e ValorTexto ::
    veja b e ValorTexto ::
      devolve a.valor == b.valor
    fecha
  fecha

  veja a e ValorBit ::
    veja b e ValorBit ::
      devolve a.valor == b.valor
    fecha
  fecha

  veja a e ValorNulo ::
    veja b e ValorNulo ::
      devolve sim
    fecha
  fecha

  devolve nao
fecha

campo opcode_binario(operador: Texto) -> Opcode ::
  veja operador == "+" ::
    devolve Soma
  fecha
  veja operador == "-" ::
    devolve Sub
  fecha
  veja operador == "*" ::
    devolve Mul
  fecha
  veja operador == "/" ::
    devolve Div
  fecha
  veja operador == "==" ::
    devolve Igual
  fecha
  veja operador == "!=" ::
    devolve Diferente
  fecha
  veja operador == "<" ::
    devolve Menor
  fecha
  veja operador == "<=" ::
    devolve MenorIgual
  fecha
  veja operador == ">" ::
    devolve Maior
  fecha
  veja operador == ">=" ::
    devolve MaiorIgual
  fecha

  devolve Pare
fecha

campo opcode_byte(op: Opcode) -> Byte ::
  veja op e Pare ::
    devolve 0
  fecha
  veja op e Const ::
    devolve 1
  fecha
  veja op e Carrega ::
    devolve 2
  fecha
  veja op e Guarda ::
    devolve 3
  fecha
  veja op e Soma ::
    devolve 4
  fecha
  veja op e Sub ::
    devolve 5
  fecha
  veja op e Mul ::
    devolve 6
  fecha
  veja op e Div ::
    devolve 7
  fecha
  veja op e Igual ::
    devolve 8
  fecha
  veja op e Diferente ::
    devolve 9
  fecha
  veja op e Menor ::
    devolve 10
  fecha
  veja op e MenorIgual ::
    devolve 11
  fecha
  veja op e Maior ::
    devolve 12
  fecha
  veja op e MaiorIgual ::
    devolve 13
  fecha
  veja op e Salta ::
    devolve 14
  fecha
  veja op e SaltaSeNao ::
    devolve 15
  fecha
  veja op e Chama ::
    devolve 16
  fecha
  veja op e Volta ::
    devolve 17
  fecha
  veja op e Caixa ::
    devolve 18
  fecha
  veja op e MarcaByte ::
    devolve 19
  fecha
  veja op e PegaByte ::
    devolve 20
  fecha
  veja op e Efeito ::
    devolve 21
  fecha
  veja op e Syscall ::
    devolve 22
  fecha

  devolve 0
fecha

campo emite_instrucao_svbc(bytes: Bytes, op: Opcode, a: U32, b: U32, c: U32, ip: U64) -> Nada ::
  bytes_coloca_byte(bytes, opcode_byte(op))
  bytes_coloca_u32(bytes, a)
  bytes_coloca_u32(bytes, b)
  bytes_coloca_u32(bytes, c)
  bytes_coloca_u64(bytes, ip)
fecha
