modulo seven.runtime.svbc0.image

usa seven.runtime.svbc0.opcode

const MagicSvbc0Runtime: Texto := "SVB0"
const VersaoSvbc0Runtime: U32 := 1

molde Instrucao0 ::
  opcode: Opcode0
  a: U32
  b: U32
  ip: U64
fecha

molde ImagemSvbc0 ::
  constantes_texto: Lista<Texto>
  constantes_u32: Lista<U32>
  codigo: Lista<Instrucao0>
fecha

campo svbc0_vazia() -> ImagemSvbc0 ::
  devolve ImagemSvbc0 {
    constantes_texto: lista<Texto>(),
    constantes_u32: lista<U32>(),
    codigo: lista<Instrucao0>()
  }
fecha
