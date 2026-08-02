modulo conformance.valid.types

molde Usuario ::
  id: U64
  nome: Texto
  ativo: Bit
fecha

campo cria_usuario() -> Usuario ::
  devolve Usuario {
    id: 7,
    nome: "Seven",
    ativo: sim
  }
fecha
