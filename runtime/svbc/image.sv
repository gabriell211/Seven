modulo seven.runtime.svbc.image

usa seven.runtime.svbc.opcode
usa seven.runtime.svbc.value

const MagicSvbc: Texto := "SVBC"
const VersaoSvbc: U32 := 1

molde Instrucao ::
  opcode: Opcode
  a: U32
  b: U32
  c: U32
  ip: U64
fecha

molde CampoImagem ::
  nome: Texto
  entrada: U64
  locais: U32
  parametros: U32
  efeitos: Lista<Texto>
fecha

molde ImagemSvbc ::
  versao: U32
  nomes: Lista<Texto>
  constantes: Lista<ValorVm>
  campos: Lista<CampoImagem>
  codigo: Lista<Instrucao>
fecha

campo imagem_vazia() -> ImagemSvbc ::
  devolve ImagemSvbc {
    versao: VersaoSvbc,
    nomes: lista<Texto>(),
    constantes: lista<ValorVm>(),
    campos: lista<CampoImagem>(),
    codigo: lista<Instrucao>()
  }
fecha
