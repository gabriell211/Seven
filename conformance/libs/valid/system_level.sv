modulo conformance.libs.valid.system_level

usa std.base.resultado
usa std.mem.alloc
usa std.mem.ptr
usa std.sync.atomic
usa std.system.bits

campo mascara_execucao(flags: U64) -> U64 ::
  devolve bit_ou(flags, 8)
fecha

campo reserva_sistema(tamanho: U64) -> Resultado<BlocoAlocado, Falha> toca cru ::
  devolve aloca(tamanho)
fecha

campo ponteiro_byte_nulo() -> Ponteiro<Byte> toca cru ::
  devolve ptr_nulo<Byte>()
fecha

campo incremento_atomico(contador: AtomicoU64) -> U64 toca tempo ::
  devolve atomico_soma_u64(contador, 1)
fecha
