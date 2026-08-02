modulo seven.compiler.bytecode

usa seven.compiler.ir
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
  Salta
  SaltaSeNao
  Chama
  Volta
  Caixa
  MarcaByte
  PegaByte
  Efeito
fecha

molde ImagemBytecode ::
  bytes: Bytes
  mapa: Mapa<U64, Texto>
fecha

campo emite_svbc(unidade: UnidadeIr) -> Bytes ::
  solta bytes := bytes_novo()

  bytes_coloca_texto(bytes, SvbcMagic)
  bytes_coloca_u32(bytes, SvbcVersao)
  emite_tabela_constantes(bytes, unidade)
  emite_campos(bytes, unidade)
  emite_codigo(bytes, unidade)

  devolve bytes
fecha
