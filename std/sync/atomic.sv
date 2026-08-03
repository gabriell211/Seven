modulo std.sync.atomic

molde AtomicoU64 ::
  id: U64
fecha

molde AtomicoBit ::
  id: U64
fecha

campo atomico_u64(valor: U64) -> AtomicoU64 toca tempo ::
  devolve sys_atomic_u64(valor)
fecha

campo atomico_carrega_u64(atomico: AtomicoU64) -> U64 toca tempo ::
  devolve sys_atomic_carrega_u64(atomico)
fecha

campo atomico_guarda_u64(atomico: AtomicoU64, valor: U64) -> Nada toca tempo ::
  sys_atomic_guarda_u64(atomico, valor)
fecha

campo atomico_soma_u64(atomico: AtomicoU64, valor: U64) -> U64 toca tempo ::
  devolve sys_atomic_soma_u64(atomico, valor)
fecha

campo atomico_troca_u64(atomico: AtomicoU64, esperado: U64, novo: U64) -> Bit toca tempo ::
  devolve sys_atomic_troca_u64(atomico, esperado, novo)
fecha

campo atomico_bit(valor: Bit) -> AtomicoBit toca tempo ::
  devolve sys_atomic_bit(valor)
fecha

campo atomico_carrega_bit(atomico: AtomicoBit) -> Bit toca tempo ::
  devolve sys_atomic_carrega_bit(atomico)
fecha

campo atomico_guarda_bit(atomico: AtomicoBit, valor: Bit) -> Nada toca tempo ::
  sys_atomic_guarda_bit(atomico, valor)
fecha
